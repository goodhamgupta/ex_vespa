defmodule ExVespa.Package.ImportField do
  @moduledoc """
  Imported field from a reference document

  Useful to implement `parent/child relationships <https://docs.vespa.ai/en/parent-child.html>`.

  """

  @keys [
    :name,
    :reference_field,
    :field_to_import
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          name: String.t(),
          reference_field: String.t(),
          field_to_import: String.t()
        }

  def validate(%__MODULE__{name: name}) when is_nil(name) do
    raise ArgumentError, "Name should not be nil"
  end

  def validate(%__MODULE__{name: name}) when not is_binary(name) and not is_nil(name) do
    raise ArgumentError, "Name should be a string"
  end

  def validate(%__MODULE__{reference_field: reference_field}) when is_nil(reference_field) do
    raise ArgumentError, "Reference field should not be nil"
  end

  def validate(%__MODULE__{reference_field: reference_field})
      when not is_binary(reference_field) and not is_nil(reference_field) do
    raise ArgumentError, "Reference field should be a string"
  end

  def validate(%__MODULE__{field_to_import: field_to_import}) when is_nil(field_to_import) do
    raise ArgumentError, "Field to import should not be nil"
  end

  def validate(%__MODULE__{field_to_import: field_to_import})
      when not is_binary(field_to_import) and not is_nil(field_to_import) do
    raise ArgumentError, "Field to import should be a string"
  end

  def validate(input), do: input

  @doc """
  Creates a new import field object

  ## Examples

      iex> ExVespa.Package.ImportField.new("my_field", "my_reference_field", "my_field_to_import")
      %ExVespa.Package.ImportField{
        name: "my_field",
        reference_field: "my_reference_field",
        field_to_import: "my_field_to_import"
      }

      iex> ExVespa.Package.ImportField.new(nil, "my_reference_field", "my_field_to_import")
      ** (ArgumentError) Name should not be nil

      iex> ExVespa.Package.ImportField.new("my_field", nil, "my_field_to_import")
      ** (ArgumentError) Reference field should not be nil

      iex> ExVespa.Package.ImportField.new("my_field", "my_reference_field", nil)
      ** (ArgumentError) Field to import should not be nil

      iex> ExVespa.Package.ImportField.new(123, "my_reference_field", 123)
      ** (ArgumentError) Name should be a string

      iex> ExVespa.Package.ImportField.new("my_field", 123, "my_field_to_import")
      ** (ArgumentError) Reference field should be a string

      iex> ExVespa.Package.ImportField.new("my_field", "my_reference_field", 123)
      ** (ArgumentError) Field to import should be a string

  """
  def new(name, reference_field, field_to_import) do
    %__MODULE__{
      name: name,
      reference_field: reference_field,
      field_to_import: field_to_import
    }
    |> validate()
  end

  def inspect(
        %__MODULE__{
          name: name,
          reference_field: reference_field,
          field_to_import: field_to_import
        },
        _opts
      ) do
    "#{__MODULE__}(#{name}, #{reference_field}, #{field_to_import})"
  end

  def %__MODULE__{
        name: lname,
        reference_field: lreference_field,
        field_to_import: lfield_to_import
      } = %__MODULE__{
        name: rname,
        reference_field: rreference_field,
        field_to_import: rfield_to_import
      } do
    lname == rname and lreference_field == rreference_field and
      lfield_to_import == rfield_to_import
  end
end
