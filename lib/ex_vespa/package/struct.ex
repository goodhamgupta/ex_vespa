defmodule ExVespa.Package.Struct do
  @moduledoc """
  Create a vespa struct.

  A struct defines a composite type. Check the `Vespa documentation
  <https://docs.vespa.ai/en/reference/schema-reference.html#struct>`__
  for more detailed information about structs.
  """
  alias ExVespa.Package.Summary
  alias __MODULE__

  @keys [
    :name,
    :indexing,
    :attribute,
    :match,
    :query_command,
    :summary
  ]

  defstruct @keys

  @type t() :: %Struct{
          name: String.t(),
          indexing: list(String.t()),
          attribute: list(String.t()),
          match: list(String.t()) | list({String.t(), String.t()}),
          query_command: list(String.t()),
          summary: Summary.t()
        }

  def validate(%Struct{name: name}) when is_nil(name) do
    raise ArgumentError, "Name should not be nil"
  end

  def validate(%Struct{name: name}) when not is_binary(name) and not is_nil(name) do
    raise ArgumentError, "Name should be a string"
  end

  def validate(input), do: input

  @doc """
  Creates a new struct object

  ## Examples

    iex> ExVespa.Package.Struct.new("my_struct", ["indexing"], ["attribute"], ["match"], ["query_command"], ExVespa.Package.Summary.new("my_field", "string"))
    %ExVespa.Package.Struct{
      name: "my_struct",
      indexing: ["indexing"],
      attribute: ["attribute"],
      match: ["match"],
      query_command: ["query_command"],
      summary: ExVespa.Package.Summary.new("my_field", "string")
    }

    iex> ExVespa.Package.Struct.new(nil)
    ** (ArgumentError) Name should not be nil

    iex> ExVespa.Package.Struct.new(1)
    ** (ArgumentError) Name should be a string
  """
  def new(
        name,
        indexing \\ [],
        attribute \\ [],
        match \\ [],
        query_command \\ [],
        summary \\ nil
      ) do
    %Struct{
      name: name,
      indexing: indexing,
      attribute: attribute,
      match: match,
      query_command: query_command,
      summary: summary
    }
    |> validate()
  end
end
