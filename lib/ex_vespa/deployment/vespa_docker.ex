defmodule ExVespa.Deployment.VespaDocker do
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
    container_memory: 512,
    output_file: "Dockerfile",
    container_image: "vespaengine/vespa",
    cfgsrv_port: 19070,
    debug_port: 19071
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
      {:ok, container_id, vespa_docker.container_name}
    else
      {:ok, container} =
        Docker.Containers.start(vespa_docker.container_image, %{
          "HostConfig" => %{
            "PortBindings" => %{
              "8080/tcp" => [%{"HostPort" => "#{vespa_docker.port}"}]
            },
            "Memory" => vespa_docker.container_memory
          }
        })

      container = Docker.Containers.inspect(container)
      container_id = container["Id"]
      container_name = Docker.Names.extract_tag(container["Name"])
      {:ok, container_id, container_name}
    end
  end

  @spec check_configuration_server(VespaDocker.t()) :: true | false | {:error, String.t()}
  defp check_configuration_server(%VespaDocker{container: container}) do
    container_ip = container["NetworkSettings"]["IPAddress"]
    {:ok, response} = Req.get!("http://#{container_ip}:19071/ApplicationStatus")

    if response.status_code == 200 do
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
  def wait_for_config_server_start(%VespaDocker{container: container}, max_wait) do
    do_wait_for_config_server(%VespaDocker{container: container}, 0, max_wait)
  end

  defp _deploy_data(
         %VespaDocker{} = vespa_docker,
         %ApplicationPackage{} = app_package,
         _debug
       ) do
    run_vespa_engine_container(vespa_docker)

    container_ip = vespa_docker.container["NetworkSettings"]["IPAddress"]
    wait_for_config_server_start(app_package, @cfg_server_timeout)

    {:ok, zip_fname} = ApplicationPackage.to_zipfile(app_package, "vespa.zip")

    response =
      Req.post!(
        "http://#{container_ip}:#{vespa_docker.cfgsrv_port}/application/v2/tenant/default/prepareandactivate",
        headers: [{"Content-Type", "application/zip"}],
        data: zip_fname
      )

    if response.status_code == 200 do
      IO.puts("Deployed application #{app_package.name}")
    else
      raise RuntimeError,
            "Failed to deploy application #{app_package.name}. Response: #{inspect(response)}"
    end
  end

  def deploy(%VespaDocker{} = vespa_docker, %ApplicationPackage{} = app_package, debug \\ false) do
    _deploy_data(vespa_docker, app_package, debug)
  end

  def stop_services(%VespaDocker{container: container}) when is_nil(container) do
    raise RuntimeError, "No container to stop"
  end

  def stop_services(%VespaDocker{container: container}) do
    container["Id"] |> Docker.Containers.stop()
  end
end
