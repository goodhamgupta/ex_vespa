defmodule ExVespa.Package.StructField do
  alias ExVespa.Package.Summary

  @keys [
    :name,
    :indexing,
    :attribute,
    :match,
    :query_command,
    :summary
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          name: String.t(),
          indexing: list(String.t()),
          attribute: list(String.t()),
          match: list(String.t()),
          query_command: list(String.t()),
          summary: Summary.t()
        }

  def validate(%__MODULE__{name: name}) when is_nil(name) do
    raise ArgumentError, "Name should not be nil"
  end

  def validate(%__MODULE__{name: name}) when not is_binary(name) and not is_nil(name) do
    raise ArgumentError, "Name should be a string"
  end

  def validate(input), do: input

  @doc """
  Create a new struct field object

  ## Examples

    iex> ExVespa.Package.StructField.new("title", ["index"], ["attribute"], ["match"], ["query_command"], %ExVespa.Package.Summary{name: "summary", type: "summary", fields: ["dynamic"]})
    %ExVespa.Package.StructField{attribute: ["attribute"], indexing: ["index"], match: ["match"], name: "title", query_command: ["query_command"], summary: %ExVespa.Package.Summary{fields: ["dynamic"], name: "summary", type: "summary"}}
  """
  def new(name, indexing \\ [], attribute \\ [], match \\ [], query_command \\ [], summary \\ nil) do
    %__MODULE__{
      name: name,
      indexing: indexing,
      attribute: attribute,
      match: match,
      query_command: query_command,
      summary: summary
    }
    |> validate()
  end

  def inspect(
        %__MODULE__{
          name: name,
          indexing: indexing,
          attribute: attribute,
          match: match,
          query_command: query_command,
          summary: summary
        },
        _opts
      ) do
    "#{__MODULE__}(#{name} [#{Enum.join(indexing, ", ")}] [#{Enum.join(attribute, ", ")}] [#{Enum.join(match, ", ")}], [#{Enum.join(query_command, ", ")}], [#{inspect(summary)}])"
  end

  def %__MODULE__{
        name: lname,
        indexing: lindexing,
        attribute: lattribute,
        match: lmatch,
        query_command: lquery_command,
        summary: lsummary
      } = %__MODULE__{
        name: rname,
        indexing: rindexing,
        attribute: rattribute,
        match: rmatch,
        query_command: rquery_command,
        summary: rsummary
      } do
    lname == rname and lindexing == rindexing and lattribute == rattribute and lmatch == rmatch and
      lquery_command == rquery_command and lsummary == rsummary
  end
end
