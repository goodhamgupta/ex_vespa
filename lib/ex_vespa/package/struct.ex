defmodule ExVespa.Package.Struct do
  @moduledoc """
  Create a vespa struct.

  A struct defines a composite type. Check the `Vespa documentation
  <https://docs.vespa.ai/en/reference/schema-reference.html#struct>`__
  for more detailed information about structs.
  """
  alias ExVespa.Package.Summary
  alias ExVespa.Package.Field
  alias __MODULE__

  @keys [
    :name,
    :fields
  ]

  defstruct @keys

  @type t() :: %Struct{
          name: String.t(),
          fields: list(Field.t())
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

    iex> alias ExVespa.Package.Struct
    iex> struct = Struct.new("my_struct")
    %ExVespa.Package.Struct{
      fields: [],
      name: "my_struct"
    }

    # Add fields to struct
    iex> alias ExVespa.Package.{Struct, Field}
    iex> struct = Struct.new("my_struct", [Field.new("my_field", "string")])
    %ExVespa.Package.Struct{
      fields: [
        %ExVespa.Package.Field{
          ann: nil,
          attribute: nil,
          bolding: nil,
          index: nil,
          indexing: nil,
          match: nil,
          name: "my_field",
          query_command: nil,
          rank: nil,
          stemming: nil,
          struct_fields: nil,
          summary: nil,
          type: "string",
          weight: nil
        }
      ],
      name: "my_struct"
    }

  """
  def new(
        name,
        fields \\ []
      ) do
    %Struct{
      name: name,
      fields: fields
    }
    |> validate()
  end
end
