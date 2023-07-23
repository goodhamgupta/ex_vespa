defmodule ExVespa.Application.Vespa do
  @moduledoc """
  Establish a connection with an existing Vespa application.
  """

  alias __MODULE__

  @keys [
    :url,
    :port,
    :end_point,
    :search_end_point,
    :deployment_message,
    :cert,
    :key,
    :output_file,
    :application_package
  ]

  @type t :: %Vespa{
          url: String.t(),
          port: integer(),
          end_point: String.t(),
          search_end_point: String.t(),
          deployment_message: String.t(),
          cert: String.t(),
          key: String.t(),
          output_file: String.t(),
          application_package: String.t()
        }

  defstruct @keys

  @doc """
  Create a new Vespa object.

  ## Examples
    iex> alias ExVespa.Application.Vespa
    iex> Vespa.new("https://localhost", [port: 8080])
    %Vespa{
      url: "https://localhost",
      port: 8080,
      end_point: "https://localhost:8080",
      search_end_point: "https://localhost:8080/search/",
      deployment_message: nil,
      cert: nil,
      key: nil,
      output_file: nil,
      application_package: nil
    }

    iex> alias ExVespa.Application.Vespa
    iex> Vespa.new("https://localhost", [port: 4443, cert: "cert.pem", key: "key.pem"])
    %Vespa{
      url: "https://localhost",
      port: 4443,
      end_point: "https://localhost:4443",
      search_end_point: "https://localhost:4443/search/",
      deployment_message: nil,
      cert: "cert.pem",
      key: "key.pem",
      output_file: nil,
      application_package: nil
    }
  """
  def new(url, opts \\ []) do
    end_point =
      if opts[:port] == nil do
        url
      else
        String.trim_trailing(url, "/") <> ":" <> Integer.to_string(opts[:port])
      end

    search_end_point = end_point <> "/search/"

    %Vespa{
      url: url,
      port: opts[:port],
      end_point: end_point,
      search_end_point: search_end_point,
      deployment_message: opts[:deployment_message],
      cert: opts[:cert],
      key: opts[:key],
      output_file: opts[:output_file],
      application_package: opts[:application_packag]
    }
  end

  defp do_wait_for_application_up(_vespa, max_wait, waited, _try_interval)
       when waited >= max_wait do
    raise "Application not up. Waited for #{waited} seconds."
  end

  defp do_wait_for_application_up(vespa, max_wait, waited, try_interval) do
    case get_application_status(vespa) do
      {:ok, response} ->
        {:ok, response}

      {:error, _} ->
        IO.puts("Waiting for application status, #{waited}/#{max_wait} seconds...")
        :timer.sleep(try_interval)
        do_wait_for_application_up(vespa, max_wait, waited + try_interval, try_interval + 1)
    end
  end

  def get_application_status(%Vespa{} = vespa) do
    endpoint = vespa.end_point <> "/ApplicationStatus"

    response =
      if vespa.key != nil do
        case :httpc.request(
               :get,
               {endpoint, []},
               [{:ssl, [{:certfile, vespa.cert}, {:keyfile, vespa.key}]}],
               []
             ) do
          {:ok, response} ->
            response

          {:error, response} ->
            raise "Failed to connect to endpoint"
            IO.inspect(response)
        end
      else
        case :httpc.request(:get, {endpoint, []}, [], []) do
          {:ok, response} ->
            response

          {:error, response} ->
            raise "Failed to connect to endpoint"
            IO.inspect(response)
        end
      end

    {:ok, response}
  end

  def wait_for_application_up(%Vespa{} = vespa, max_wait) do
    try_interval = 5
    waited = 0
    do_wait_for_application_up(vespa, max_wait, waited, try_interval)
  end

  def get_model_endpoint(%Vespa{} = vespa) do
    :not_implemented
  end

  def query(%Vespa{} = vespa, body) do
    :not_implemented
  end

  def query_batch(%Vespa{} = vespa, body_batch) do
    Enum.map(body_batch, fn body -> query(vespa, body) end)
  end
end
