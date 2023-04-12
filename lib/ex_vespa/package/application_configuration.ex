defmodule ExVespa.Package.ApplicationConfiguration do
  @moduledoc """
  Create a Vespa Schema.

  Check the `Config documentation <https://docs.vespa.ai/en/reference/services.html#generic-config>`__
  for more detailed information about generic configuration.
  """

  @keys [
    :name,
    :value
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          name: String.t(),
          value:
            String.t()
            | map(String.t(), String.t())
            | map(String.t(), map(String.t(), String.t()))
        }

  def validate(%ApplicationConfiguration{name: name}) when is_nil(name) do
    raise ArgumentError, "name is required"
  end

  def validate(%ApplicationConfiguration{value: value}) when is_nil(value) do
    raise ArgumentError, "value is required"
  end

  def validate(application_configuration), do: application_configuration

  @doc """
  Create a ApplicationConfiguration

  ## Examples

      iex> alias ExVespa.Package.ApplicationConfiguration
      iex> ApplicationConfiguration.new("my_config", "my_value")
      %ApplicationConfiguration{
          name: "my_config",
          value: "my_value"
      }
  """
  @spec new(
          String.t(),
          String.t() | map(String.t(), String.t()) | map(String.t(), map(String.t(), String.t()))
        ) :: %ApplicationConfiguration{}
  def new(name, value) do
    %ApplicationConfiguration{
      name: name,
      value: value
    }
    |> validate()
  end

  @doc """
  Create a ApplicationConfiguration from a map

  ## Examples

      iex> alias ExVespa.Package.ApplicationConfiguration
      iex> ApplicationConfiguration.from_map(%{name: "my_config", value: "my_value"})
      %ApplicationConfiguration{
          name: "my_config",
          value: "my_value"
      }
  """
  @spec from_map(
          map(
            String.t(),
            String.t()
            | map(String.t(), String.t())
            | map(String.t(), map(String.t(), String.t()))
          )
        ) :: %ApplicationConfiguration{}
  def from_map(%{name: name, value: value}) do
    new(name, value)
  end

  def inspect(%ApplicationConfiguration{name: name, value: value}, _opts) do
    "#<ApplicationConfiguration name: \"#{name}\", value: \"#{value}\">"
  end

  def %ApplicationConfiguration{name: lname, value: lvalue} = %ApplicationConfiguration{
        name: rname,
        value: rvalue
      } do
    lname == rname and lvalue == rvalue
  end

  def to_text(%ApplicationConfiguration{name: name, value: value}) when is_binary(value) do
    "    #{value}"
  end

  @doc """
  Convert a ApplicationConfiguration to a text

  ## Examples

      iex> alias ExVespa.Package.ApplicationConfiguration
      iex> ApplicationConfiguration.to_text(%ApplicationConfiguration{name: "my_config", value: "my_value"})
      "    my_value"
  """
  def to_text(%ApplicationConfiguration{name: name, value: value}) when is_binary(value) do
    acc = "\n"
    result = ApplicationConfiguration.convert_to_xml(value, 1, acc)
    "    #{result}"
  end

  defp convert_to_xml(value, level \\ 1, acc) when is_map(value_map) do
    Enum.flat_map(value_map, fn {key, value} ->
      acc <> String.duplicate(" ", level * 4) <> "<#{key}>#{value}</#{key}>"
    end)
    |> Enum.join("\n")
  end

  defp convert_to_xml(value, level \\ 1, acc) do
    acc <> String.duplicate(" ", level * 4) <> "<#{key}>#{value}</#{key}>"
  end
end
