defmodule ExVespa.Package.Schema do
  @moduledoc """
  A Vespa schema.
  Check the `Vespa documentation <https://docs.vespa.ai/en/schemas.html>`__
  for more detailed information about schemas.
  """

  alias ExVespa.Package.{
    Document,
    FieldSet,
    RankProfile,
    OnnxModel,
    ImportedField,
    DocumentSummary
  }

  alias __MODULE__

  @keys [
    :name,
    :document,
    :fieldsets,
    :rank_profiles,
    :models,
    :global_document,
    :imported_fields,
    :document_summaries
  ]

  defstruct @keys

  @type t :: %Schema{
          name: String.t(),
          document: Document.t(),
          fieldsets: [FieldSet.t()] | nil,
          rank_profiles: [RankProfile.t()] | nil,
          models: [OnnxModel.t()] | nil,
          global_document: boolean() | false,
          imported_fields: [ImportedField.t()] | nil,
          document_summaries: [DocumentSummary.t()] | nil
        }
  defp convert_list_to_map(input_list) when is_nil(input_list) do
    []
  end

  defp convert_list_to_map(input_list) do
    input_list
    |> Enum.map(fn x -> %{x.name => x} end)
    |> Enum.reduce(%{}, fn x, acc -> Map.merge(x, acc) end)
  end

  defp validate(%Schema{name: name}) when is_nil(name) do
    raise ArgumentError, "name is required"
  end

  defp validate(%Schema{document: document}) when is_nil(document) do
    raise ArgumentError, "document is required"
  end

  defp validate(input), do: input

  @doc """
  Creates a new schema.

  ## Examples

      iex> alias ExVespa.Package.{Schema, Document}
      iex> Schema.new("my_schema", Document.new())
      %ExVespa.Package.Schema{
        document: Document.new(),
        fieldsets: [],
        global_document: false,
        imported_fields: [],
        models: [],
        name: "my_schema",
        rank_profiles: [],
        document_summaries: []
      }
  """
  def new(name, document, opts \\ []) do
    fieldsets = Keyword.get(opts, :fieldsets, nil)
    rank_profiles = Keyword.get(opts, :rank_profiles, nil)
    models = Keyword.get(opts, :models, [])
    global_document = Keyword.get(opts, :global_document, false)
    imported_fields = Keyword.get(opts, :imported_fields, nil)
    document_summaries = Keyword.get(opts, :document_summaries, [])

    %__MODULE__{
      name: name,
      document: document,
      fieldsets: fieldsets |> convert_list_to_map(),
      rank_profiles: rank_profiles |> convert_list_to_map(),
      models: models,
      global_document: global_document,
      imported_fields: imported_fields |> convert_list_to_map(),
      document_summaries: document_summaries
    }
    |> validate()
  end

  def add_fields(%Schema{document: document} = schema, fields) do
    %Schema{schema | document: document.fields ++ fields}
  end
end
