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

  @doc """
  Adds fields to a document object

  ## Examples

    iex> alias ExVespa.Package.{Field, Document}
    iex> Document.new()
    ...> |> Document.add_fields([Field.new("my_field", "string")])
    %ExVespa.Package.Document{
      _fields: %{"my_field" => Field.new("my_field", "string")},
      inherits: [],
      _structs: %{}
    }

    iex> alias ExVespa.Package.{Field, Document}
    iex> Document.new()
    ...> |> Document.add_fields([Field.new("my_field", "string")])
    ...> |> Document.add_fields([Field.new("my_field_again", "string")])
    %ExVespa.Package.Document{
      _fields: %{"my_field" => Field.new("my_field", "string"), "my_field_again" => Field.new("my_field_again", "string")},
      inherits: [],
      _structs: %{}
    }

  """
  def add_fields(document, fields) do
    %Document{
      document
      | _fields: Map.merge(document._fields, fields |> convert_list_to_map())
    }
  end

  @doc """
  Adds structs to a document object

  ## Examples

    iex> alias ExVespa.Package.{Struct, Document}
    iex> Document.new()
    ...> |> Document.add_structs([Struct.new("my_struct")])
    %ExVespa.Package.Document{
      _fields: %{},
      inherits: [],
      _structs: %{
        "my_struct" => ExVespa.Package.Struct.new("my_struct")
      }
    }

    iex> alias ExVespa.Package.{Struct, Document}
    iex> Document.new()
    ...> |> Document.add_structs([Struct.new("my_struct")])
    ...> |> Document.add_structs([Struct.new("my_struct_again")])
    %ExVespa.Package.Document{
      _fields: %{},
      inherits: [],
      _structs: %{
        "my_struct" => ExVespa.Package.Struct.new("my_struct"),
        "my_struct_again" => ExVespa.Package.Struct.new("my_struct_again")
      }
    }
  """
  def add_structs(document, structs) do
    %Document{
      document
      | _structs: Map.merge(document._structs, structs |> convert_list_to_map())
    }
  end

  @doc """
  Get all the stored fields in a document

  ## Examples

    iex> alias ExVespa.Package.{Field, Document}
    iex> Document.new()
    ...> |> Document.add_fields([Field.new("my_field", "string")])
    ...> |> Document.add_fields([Field.new("my_field_again", "string")])
    ...> |> Document.fields()
    [
      Field.new("my_field", "string"),
      Field.new("my_field_again", "string")
    ]
  """
  def fields(document), do: document._fields |> Map.values()

  def structs(document), do: document._structs |> Map.values()
end
