defmodule ExVespa.Package.FieldSet do
  @moduledoc """
  Create a Vespa Field Set

  A fieldset groups fields together for searching. Check the
  `Vespa documentation <https://docs.vespa.ai/en/reference/schema-reference.html#fieldset>`__
  for more detailed information about field sets.
  """
  alias __MODULE__

  @keys [
    :name,
    :fields
  ]

  defstruct @keys

  @type t :: %FieldSet{
          name: String.t(),
          fields: list(String.t())
        }

  defp validate(%FieldSet{name: name}) when is_nil(name) do
    raise ArgumentError, "Name should not be nil"
  end

  defp validate(%FieldSet{name: name}) when not is_binary(name) and not is_nil(name) do
    raise ArgumentError, "Name should be a string"
  end

  defp validate(input), do: input

  @doc """
  Creates a new field set object

  ## Examples

    iex> ExVespa.Package.FieldSet.new("my_field_set", ["my_field"])
    %ExVespa.Package.FieldSet{
      name: "my_field_set",
      fields: ["my_field"]
    }

    iex> ExVespa.Package.FieldSet.new(nil)
    ** (ArgumentError) Name should not be nil

    iex> ExVespa.Package.FieldSet.new(1)
    ** (ArgumentError) Name should be a string
  """
  def new(name, fields \\ []) do
    %FieldSet{
      name: name,
      fields: fields
    }
    |> validate()
  end

  def inspect(%FieldSet{name: name, fields: fields}, _opts) do
    "#{__MODULE__}(#{name}, #{inspect(fields)})"
  end

  def %FieldSet{name: lname, fields: lfields} = %FieldSet{name: rname, fields: rfields} do
    lname == rname and lfields == rfields
  end
end
