defmodule ExVespa.Application.VespaSync do
  @moduledoc """
  Synchronous client for Vespa
  """

  alias __MODULE__
  alias ExVespa.Application.Vespa
  alias ExVespa.IO.VespaResponse

  @keys [
    :app,
    :pool_maxsize,
    :cert
  ]

  defstruct @keys

  @type t :: %VespaSync{
          app: Vespa.t(),
          pool_maxsize: integer(),
          cert: String.t()
        }

  def new(app, pool_maxsize \\ 10) do
    # TODO: Set the cert

    %VespaSync{
      app: app,
      pool_maxsize: pool_maxsize,
      cert: app.cert
    }
  end

  def get_model_endpoint(%VespaSync{} = vespa_sync, model_id \\ nil) do
    base_url = "#{vespa_sync.app.end_point}/model-evaluation/v1/"

    endpoint =
      if model_id != nil do
        "#{base_url}#{model_id}"
      else
        base_url
      end

    {:ok, {{http_method, status_code, msg}, headers, response}} =
      :httpc.request(:get, {endpoint, []}, [], [{:ssl, [{:certfile, vespa_sync.cert}]}])

    if status_code == 200 do
      {:ok, Jason.encode!(response)}
    else
      {:error, response}
    end
  end

  def predict(%VespaSync{} = vespa_sync, model_id, function_name, encoded_tokens) do
    base_url = "#{vespa_sync.app.end_point}/model-evaluation/v1"
    endpoint = "#{base_url}/#{model_id}/#{function_name}/eval?#{encoded_tokens}"

    {:ok, {{http_method, status_code, msg}, headers, response}} =
      :httpc.request(
        :post,
        {endpoint, []},
        [],
        [{:ssl, [{:certfile, vespa_sync.cert}]}],
        Jason.encode!(encoded_tokens)
      )

    if status_code == 200 do
      {:ok, Jason.encode!(response)}
    else
      {:error, response}
    end
  end

  def feed_data_point(%VespaSync{} = vespa_sync, schema, data_id, fields, namespace \\ nil) do
    base_url = "#{vespa_sync.app.end_point}/document/v1"

    cur_namespace =
      if namespace == nil do
        schema
      else
        namespace
      end

    endpoint = "#{base_url}/#{cur_namespace}/#{schema}/docid/#{data_id}"

    req_headers = [{"Content-Type", "application/json"}]

    {:ok, {{http_method, status_code, msg}, headers, response}} =
      :httpc.request(
        :put,
        {endpoint, req_headers},
        [],
        [{:ssl, [{:certfile, vespa_sync.cert}]}],
        Jason.encode!(%{fields: fields})
      )

    if status_code == 200 do
      {:ok,
       %VespaResponse{
         json: Jason.encode!(response),
         status_code: status_code,
         url: endpoint,
         operation_type: "feed"
       }}
    else
      {:error, response}
    end
  end

  def query(%VespaSync{} = vespa_sync, body \\ %{}) do
    # Make post request to search_end_point
    {:ok, {{http_method, status_code, msg}, headers, response}} =
      :httpc.request(
        :post,
        {vespa_sync.app.search_end_point, []},
        [],
        [{:ssl, [{:certfile, vespa_sync.cert}]}],
        Jason.encode!(body)
      )

    {:ok,
     %VespaResponse{
       json: Jason.encode!(response),
       status_code: status_code,
       url: vespa_sync.app.search_end_point,
       operation_type: "query"
     }}
  end

  def delete_data(%VespaSync{} = vespa_sync, schema, data_id, namespace \\ nil) do
    base_url = "#{vespa_sync.app.end_point}/document/v1"

    cur_namespace =
      if namespace == nil do
        schema
      else
        namespace
      end

    endpoint = "#{base_url}/#{cur_namespace}/#{schema}/docid/#{data_id}"

    {:ok, {{http_method, status_code, msg}, headers, response}} =
      :httpc.request(
        :delete,
        {endpoint, []},
        [],
        [{:ssl, [{:certfile, vespa_sync.cert}]}]
      )

    if status_code == 200 do
      {:ok,
       %VespaResponse{
         json: Jason.encode!(response),
         status_code: status_code,
         url: endpoint,
         operation_type: "delete"
       }}
    else
      {:error, response}
    end
  end

  def delete_all_docs(%VespaSync{} = vespa_sync, content_cluster_name, schema, namespace \\ nil) do
    base_url = "#{vespa_sync.app.end_point}/document/v1"

    cur_namespace =
      if namespace == nil do
        schema
      else
        namespace
      end

    endpoint =
      "#{base_url}/#{cur_namespace}/#{schema}/docid/?cluster=#{content_cluster_name}&selection=true"

    {:ok, {{http_method, status_code, msg}, headers, response}} =
      :httpc.request(
        :delete,
        {endpoint, []},
        [],
        [{:ssl, [{:certfile, vespa_sync.cert}]}]
      )

    if status_code == 200 do
      {:ok,
       %VespaResponse{
         json: Jason.encode!(response),
         status_code: status_code,
         url: endpoint,
         operation_type: "delete"
       }}
    else
      {:error, response}
    end
  end

  def get_data(%VespaSync{} = vespa_sync, schema, data_id, namespace \\ nil) do
    base_url = "#{vespa_sync.app.end_point}/document/v1"

    cur_namespace =
      if namespace == nil do
        schema
      else
        namespace
      end

    endpoint = "#{base_url}/#{cur_namespace}/#{schema}/docid/#{data_id}"

    {:ok, {{http_method, status_code, msg}, headers, response}} =
      :httpc.request(
        :get,
        {endpoint, []},
        [],
        [{:ssl, [{:certfile, vespa_sync.cert}]}]
      )

    if status_code == 200 do
      {:ok,
       %VespaResponse{
         json: Jason.encode!(response),
         status_code: status_code,
         url: endpoint,
         operation_type: "get"
       }}
    else
      {:error, response}
    end
  end

  def update_data(%VespaSync{} = vespa_sync, schema, data_id, fields, namespace \\ nil) do
    base_url = "#{vespa_sync.app.end_point}/document/v1"

    cur_namespace =
      if namespace == nil do
        schema
      else
        namespace
      end

    endpoint = "#{base_url}/#{cur_namespace}/#{schema}/docid/#{data_id}"

    req_headers = [{"Content-Type", "application/json"}]
    vespa_format = %{fields: Enum.map(fields, fn {k, v} -> {k, %{assign: v}} end)}

    {:ok, {{http_method, status_code, msg}, headers, response}} =
      :httpc.request(
        :put,
        {endpoint, req_headers},
        [],
        [{:ssl, [{:certfile, vespa_sync.cert}]}],
        Jason.encode!(vespa_format)
      )

    if status_code == 200 do
      {:ok,
       %VespaResponse{
         json: Jason.encode!(response),
         status_code: status_code,
         url: endpoint,
         operation_type: "update"
       }}
    else
      {:error, response}
    end
  end
end
