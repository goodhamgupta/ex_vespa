defmodule ExVespa.IO.VespaResponse do
  alias __MODULE__

  @keys [
    :json,
    :status_code,
    :url,
    :operation_type
  ]

  defstruct @keys

  def new(json, status_code, url, operation_type) do
    %VespaResponse{
      json: json,
      status_code: status_code,
      url: url,
      operation_type: operation_type
    }
  end

  def get_json(%VespaResponse{json: json}) do
    json
  end

  def get_status_code(%VespaResponse{status_code: status_code}) do
    status_code
  end

  def %VespaResponse{
        json: ljson,
        status_code: lstatus_code,
        url: lurl,
        operation_type: loperation_type
      } = %VespaResponse{
        json: rjson,
        status_code: rstatus_code,
        url: rurl,
        operation_type: roperation_type
      } do
    ljson == rjson && lstatus_code == rstatus_code && lurl == rurl &&
      loperation_type == roperation_type
  end
end
