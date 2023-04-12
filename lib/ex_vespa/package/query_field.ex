defmodule ExVespa.Package.QueryField do
  @moduledoc """
  Create a field to be included in a :class:`QueryProfile`.
  """

  alias __MODULE__

  @keys [
    :name,
    :value
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          name: String.t(),
          value: String.t() | integer() | float()
        }

  def validate(%QueryField{name: name}) when is_nil(name) do
    raise ArgumentError, "name is required"
  end

  def validate(%QueryField{value: value}) when is_nil(value) do
    raise ArgumentError, "value is required"
  end

  def validate(query_field), do: query_field

  @doc """
  Create a field to be included in a QueryProfile

  ## Examples

    iex> ExVespa.Package.QueryField.new("maxHits", 100)
    %ExVespa.Package.QueryField{
      name: "maxHits",
      value: 100
    }
  """
  def new(name, value) do
    %QueryField{
      name: name,
      value: value
    }
    |> validate()
  end

  def %QueryField{name: lname, value: lvalue} = %QueryField{name: rname, value: rvalue} do
    lname == rname and lvalue == rvalue
  end

  def inspect(%QueryField{name: name, value: value}, _opts) do
    "#<ExVespa.Package.QueryField name: \"#{name}\", value: \"#{value}\">"
  end
end
