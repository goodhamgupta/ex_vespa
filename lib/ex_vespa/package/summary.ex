defmodule ExVespa.Package.Summary do
  @moduledoc """
  Configures a summary Field for a Vespa application package.
  """

  @keys [
    :name,
    :type,
    :fields
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          name: String.t(),
          type: String.t(),
          fields: list()
        }

  @spec validate(t()) :: t() | no_return()
  defp validate(%__MODULE__{name: name}) when not is_binary(name) and not is_nil(name) do
    raise ArgumentError, "Name should be a string"
  end

  defp validate(%__MODULE__{type: type}) when not is_binary(type) and not is_nil(type) do
    raise ArgumentError, "Type should be a string"
  end

  defp validate(input), do: input

  @spec new(any, any, any) :: t() | no_return()
  def new(name, type, fields \\ []) do
    %__MODULE__{
      name: name,
      type: type,
      fields: fields
    }
    |> validate()
  end

  @spec inspect(ExVespa.Package.Summary.t(), any) :: String.t()
  def inspect(%__MODULE__{name: name, type: type, fields: fields}, _opts) do
    "summary #{name} { type: #{type}, fields: #{Enum.join(fields, ", ")} }"
  end

  def %__MODULE__{name: lname, type: ltype, fields: lfields} = %__MODULE__{
        name: rname,
        type: rtype,
        fields: rfields
      } do
    lname == rname and ltype == rtype and lfields == rfields
  end

  @doc """
  Returns the object as a list of string, with each string representing a line
  of configuration that can be used during schema generation as such:

  ## Examples

    iex> ExVespa.Package.Summary.new(nil, nil, ["dynamic"])
    ...> |> ExVespa.Package.Summary.as_lines()
    {:ok, ["summary: dynamic"]}

    iex> ExVespa.Package.Summary.new("artist", "string", [{"bolding", "on"}, {"sources", "artist"}])
    ...> |> ExVespa.Package.Summary.as_lines()
    {:ok, ["summary artist type string {", ["    bolding: on"], ["    sources: artist"], "}"]}

  """
  @spec as_lines(t()) :: {:ok, [...]}
  def as_lines(%__MODULE__{name: name, type: type, fields: fields})
      when fields == ["dynamic"] and is_nil(name) and is_nil(type) do
    # Special case of `summary: dynamic` and others.
    {:ok, ["summary: dynamic"]}
  end

  def as_lines(%__MODULE__{name: name, type: type, fields: fields}) do
    starting_string = "summary"

    starting_string =
      if not is_nil(name) do
        "#{starting_string} #{name}"
      end

    starting_string =
      if not is_nil(type) do
        "#{starting_string} type #{type}"
      end

    # Add newline as each field resides in a separate line
    result =
      if is_nil(fields) or length(fields) == 0 do
        ["#{starting_string} {}"]
      else
        field_list = do_map_fields(fields)
        ["#{starting_string} {"] ++ field_list ++ ["}"]
      end

    {:ok, result}
  end

  defp do_map_fields(fields) do
    Enum.map(fields, fn field ->
      if is_binary(field) do
        ["    #{field}"]
      else
        tmp_string = "    #{elem(field, 0)}: "

        tmp_string =
          if is_binary(elem(field, 1)) do
            "#{tmp_string}#{elem(field, 1)}"
          else
            "#{tmp_string}#{Enum.join(elem(field, 1), ", ")}"
          end

        [tmp_string]
      end
    end)
  end
end
