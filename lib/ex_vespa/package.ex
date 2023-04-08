defmodule ExVespa.Package do
  @moduledoc """
  Documentation for `ExVespa.Package`.

  """

  alias __MODULE__

  @keys [
    :name,
    :schema,
    :query_profile,
    :query_profile_type,
    :stateless_model_evaluation,
    :create_schema_by_default,
    :create_query_profile_by_default,
    :configurations,
    :validations
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          name: String.t(),
          schema: String.t(),
          query_profile: String.t(),
          query_profile_type: String.t(),
          stateless_model_evaluation: String.t(),
          create_schema_by_default: boolean(),
          create_query_profile_by_default: boolean(),
          configurations: list(),
          validations: list()
        }

  @spec validate(__MODULE__.t()) :: {:ok, __MODULE__.t()} | no_return()
  defp validate(%__MODULE__{name: name}) do
    if Regex.match?(~r/^[a-zA-Z0-9_]+$/, name) do
      {:ok, %__MODULE__{name: name}}
    else
      raise ArgumentError, "Application package name can only contain [a-zA-Z0-9]"
    end
  end

  @spec new(String.t()) :: {:ok, __MODULE__} | no_return()
  def new(app_name) do
    %__MODULE__{name: app_name} |> validate()
  end
end
