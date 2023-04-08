defmodule ExVespa.Package.Document do
  @moduledoc """
  Create a Vespa Document.

  Check the `Vespa documentation <https://docs.vespa.ai/en/documents.html>`__
  for more detailed information about documents.
  """
  alias ExVespa.Package.{Field, Struct}
  alias __MODULE__

  @keys [
    :_fields,
    :inherits,
    :_structs
  ]

  defstruct @keys

  @type t :: %Document{
          _fields: list(Field.t()),
          inherits: list(String.t()),
          _structs: list(Struct.t())
        }

  defp convert_list_to_map(input_list) do
    input_list
    |> Enum.map(fn x -> %{x.name => x} end)
    |> Enum.reduce(%{}, fn x, acc -> Map.merge(x, acc) end)
  end

  defp validate(input), do: input

  @doc """
  Creates a new document object

  ## Examples

    iex> alias ExVespa.Package.{Field, Struct, Document}
    iex> Document.new([Field.new("my_field", "string")], ["my_inherited_document"], [Struct.new("my_struct")])
    %ExVespa.Package.Document{
      _fields: %{"my_field" => Field.new("my_field", "string")},
      inherits: ["my_inherited_document"],
      _structs: %{
        "my_struct" => ExVespa.Package.Struct.new("my_struct")
      }
    }
  """
  def new(fields \\ [], inherits \\ [], structs \\ []) do
    %Document{
      _fields: fields |> convert_list_to_map(),
      inherits: inherits,
      _structs: structs |> convert_list_to_map()
    }
    |> validate()
  end
end
