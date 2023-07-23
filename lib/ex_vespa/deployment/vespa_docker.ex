defmodule ExVespa.Deployment.VespaDocker do
  @moduledoc """
  This module is responsible for deploying a Vespa application to a Docker container.
  It will zip the contents of the supplied ApplicationPackage, and send it to the container.
  If the container is not running, it will be started.
  """

  alias __MODULE__
  alias ExVespa.Package.ApplicationPackage

  @keys [
    :port,
    :container,
    :container_name,
    :container_memory,
    :output_file,
    :container_image,
    :cfgsrv_port,
    :debug_port
  ]

  @defaults [
    port: 8080,
    container: %{},
    container_name: "vespa",
    container_memory: 512, # in MB
    output_file: "Dockerfile",
    container_image: "vespaengine/vespa",
    cfgsrv_port: 19071,
    debug_port: 5005
  ]

  @cfg_server_timeout 30_000

  @type t :: %VespaDocker{
          port: integer(),
          container: map(),
          container_name: String.t(),
          container_memory: integer(),
          output_file: String.t(),
          container_image: String.t(),
          cfgsrv_port: integer(),
          debug_port: integer()
        }

  defstruct @keys

  def new(opts \\ []) do
    opts = Keyword.merge(@defaults, opts)

    %VespaDocker{
      port: opts[:port],
      container: opts[:container],
      container_name: opts[:container_name],
      container_memory: opts[:container_memory],
      output_file: opts[:output_file],
      container_image: opts[:container_image],
      cfgsrv_port: opts[:cfgsrv_port],
      debug_port: opts[:debug_port]
    }
  end

  def from_container_name_or_id(name_or_id, output_file) do
    container_id = Docker.find_ids(name_or_id) |> List.first()
    container = Docker.Containers.inspect(container_id)

    port =
      container["HostConfig"]["PortBindings"]["8080/tcp"]
      |> List.first()
      |> Map.fetch!("HostPort")
      |> String.to_integer()

    container_memory = container["HostConfig"]["Memory"] |> String.to_integer()
    container_image = Docker.Names.extract_tag(container["Name"])

    %VespaDocker{
      port: port,
      container: container,
      container_name: container["Name"],
      container_memory: container_memory,
      container_image: container_image,
      output_file: output_file
    }
  end

  @spec run_vespa_engine_container(VespaDocker.t()) ::
          {:ok, String.t(), String.t()} | {:error, String.t()}
  defp run_vespa_engine_container(%VespaDocker{} = vespa_docker) do
    container_id = Docker.find_ids(vespa_docker.container_name) |> List.first()

    if container_id do
      container = Docker.Containers.inspect(container_id)
      {:ok, %{vespa_docker | container: container}}
    else
      %{"Id" => container_id, "Warnings" => _warnings} =
        Docker.Containers.create(
          %{
            "Image" => vespa_docker.container_image,
            "ExposedPorts" => %{
              "8080/tcp" => %{},
              "19071/tcp" => %{}
            },
            "HostConfig" => %{
              "PortBindings" => %{
                "8080/tcp" => [%{"HostPort" => "#{vespa_docker.port}"}]
              },
              "Memory" => vespa_docker.container_memory * 100_0000
            }
          },
          vespa_docker.container_name
        )

      IO.puts("Created container #{container_id}")
      IO.puts("Starting container #{container_id}")
      Docker.Containers.start(container_id)

      container = Docker.Containers.inspect(container_id)
      container_name = Docker.Names.extract_tag(container["Name"])
      {:ok, %{vespa_docker | container: container, container_name: container_name}}
    end
  end

  @doc """
  Check if the config server is running by polling the config server status page
  """
  @spec check_configuration_server(VespaDocker.t()) :: true | false | {:error, String.t()}
  defp check_configuration_server(%VespaDocker{container: container}) do
    # container_ip = container["NetworkSettings"]["IPAddress"]
    # TODO: container_ip results in timeouts for some reason. For now, since the ports are exposed
    # to the local machine, we can just use localhost
    response = Req.get!("http://localhost:19071/ApplicationStatus")

    if response.status == 200 do
      true
    else
      false
    end
  end

  defp do_wait_for_config_server(_vespa_docker, cur_counter, max_wait)
       when cur_counter > max_wait do
    raise RuntimeError,
          "Configuration server did not start in time. Waited for #{max_wait} seconds"
  end

  defp do_wait_for_config_server(vespa_docker, cur_counter, max_wait)
       when cur_counter <= max_wait do
    if not check_configuration_server(vespa_docker) do
      IO.puts("Waiting for config server, #{cur_counter}/#{max_wait} seconds..")
      :timer.sleep(5000)
      do_wait_for_config_server(vespa_docker, cur_counter + 5, max_wait)
    else
      true
    end
  end

  @doc """
  Wait for the config server to start. This is done by polling the config server
  """
  @spec wait_for_config_server_start(VespaDocker.t(), pos_integer()) :: true
  defp wait_for_config_server_start(%VespaDocker{container: container}, max_wait) do
    do_wait_for_config_server(%VespaDocker{container: container}, 0, max_wait)
  end

  defp _deploy_data(
         %VespaDocker{} = vespa_docker,
         %ApplicationPackage{} = app_package,
         _debug
       ) do
    {:ok, vd} = run_vespa_engine_container(vespa_docker)

    container_ip = vd.container["NetworkSettings"]["IPAddress"]
    wait_for_config_server_start(vd, @cfg_server_timeout)

    {:ok, zip_data} = ApplicationPackage.to_zip(app_package)

    # TODO: Same container_ip problem as above
    response =
      Req.post!(
        "http://localhost:#{vd.cfgsrv_port}/application/v2/tenant/default/prepareandactivate",
        zip_data,
        headers: [{"content-type", "application/zip"}]
      )

    if response.status == 200 do
      IO.puts("Deployed application #{app_package.name}")
      {:ok, vd}
    else
      raise RuntimeError,
            "Failed to deploy application #{app_package.name}. Response: #{inspect(response)}"
    end
  end

  @doc """
  Deploy an application package to a Vespa Docker container
  """
  def deploy(%VespaDocker{} = vespa_docker, %ApplicationPackage{} = app_package, debug \\ false) do
    _deploy_data(vespa_docker, app_package, debug)
  end

  @doc """
  Stop vespa docker container
  """
  def stop_services(%VespaDocker{container: container}) when is_nil(container) do
    raise RuntimeError, "No container to stop"
  end

  def stop_services(%VespaDocker{container: container}) do
    container["Id"] |> Docker.Containers.stop()
  end
end
