defmodule ExVespa.Package.Schema do
  @moduledoc """
  A Vespa schema.
  Check the `Vespa documentation <https://docs.vespa.ai/en/schemas.html>`__
  for more detailed information about schemas.
  """

  alias ExVespa.Package.{
    Document,
    Field,
    FieldSet,
    RankProfile,
    OnnxModel,
    ImportedField,
    DocumentSummary
  }

  alias ExVespa.Templates.Schema, as: SchemaTemplate
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
  defp convert_list_to_map(input_list) when is_map(input_list) do
    input_list
  end

  defp convert_list_to_map(input_list) when is_list(input_list) do
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
        fieldsets: %{},
        global_document: false,
        imported_fields: %{},
        models: [],
        name: "my_schema",
        rank_profiles: %{},
        document_summaries: []
      }
  """
  def new(name, document, opts \\ []) do
    fieldsets = Keyword.get(opts, :fieldsets, %{})
    rank_profiles = Keyword.get(opts, :rank_profiles, %{})
    models = Keyword.get(opts, :models, [])
    global_document = Keyword.get(opts, :global_document, false)
    imported_fields = Keyword.get(opts, :imported_fields, %{})
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

  @doc """
  Adds a field to a document

  ## Examples

      iex> alias ExVespa.Package.{Schema, Document, Field}
      iex> schema = Schema.new("my_schema", Document.new())
      iex> schema = Schema.add_fields(schema, Field.new("my_field", "string", %{indexing: ["attribute", "summary"]}))
      iex> schema.document._fields
      %{"my_field" => %ExVespa.Package.Field{
          indexing: ["attribute", "summary"],
          name: "my_field",
          type: "string"
        }
      }
  """

  def add_fields(%Schema{document: document} = schema, %Field{} = fields) do
    %Schema{schema | document: Document.add_fields(document, [fields])}
  end

  @doc """
  Adds a fieldset to a document

  ## Examples

      iex> alias ExVespa.Package.{Schema, Document, Field, FieldSet}
      iex> schema = Schema.new("my_schema", Document.new())
      iex> schema = Schema.add_field_set(schema, FieldSet.new("my_fieldset", ["title", "body"]))
      iex> schema.fieldsets
      %{"my_fieldset" => %ExVespa.Package.FieldSet{
          fields: ["title", "body"],
          name: "my_fieldset"
        }
      }
  """
  def add_field_set(%Schema{fieldsets: fieldsets} = schema, %FieldSet{} = fieldset) do
    %Schema{schema | fieldsets: Map.put(fieldsets, fieldset.name, fieldset)}
  end

  @doc """
  Adds a rank profile to a document

  ## Examples

      iex> alias ExVespa.Package.{Schema, Document, RankProfile}
      iex> schema = Schema.new("my_schema", Document.new())
      iex> rank_profile = RankProfile.new("default", "1.25 * bm25(title) + 3.75 * bm25(body)")
      iex> schema = Schema.add_rank_profile(schema, rank_profile)
      iex> schema.rank_profiles
      %{"default" => %ExVespa.Package.RankProfile{
          name: "default",
          first_phase: "1.25 * bm25(title) + 3.75 * bm25(body)"
        }
      }
  """

  def add_rank_profile(
        %Schema{rank_profiles: rank_profiles} = schema,
        %RankProfile{} = rank_profile
      ) do
    %Schema{schema | rank_profiles: Map.put(rank_profiles, rank_profile.name, rank_profile)}
  end

  @doc """
  Adds a model to a document

  ## Examples

      iex> alias ExVespa.Package.{Schema, Document, OnnxModel}
      iex> schema = Schema.new("my_schema", Document.new())
      iex> model = OnnxModel.new(
      ...>   "my_model",
      ...>   "model.onnx",
      ...>   %{
      ...>     input_ids: "input_ids",
      ...>     token_type_ids: "token_type_ids",
      ...>     attention_mask: "attention_mask",
      ...>   },
      ...>   %{
      ...>     logits: "logits"
      ...>   }
      ...> )
      iex> schema = Schema.add_model(schema, model)
      iex> schema.models
      [%ExVespa.Package.OnnxModel{
        model_name: "my_model",
        model_file_path: "model.onnx",
        inputs: %{
                    input_ids: "input_ids",
                    token_type_ids: "token_type_ids",
                    attention_mask: "attention_mask",
                  },
        outputs: %{
                    logits: "logits"
                  },
        model_file_name: "my_model.onnx",
        file_path: "files/my_model.onnx"
      }]
  """
  def add_model(%Schema{models: models} = schema, %OnnxModel{} = model) do
    %Schema{schema | models: [model | models]}
  end

  @doc """
  Adds a document summary to a document

  ## Examples

      iex> alias ExVespa.Package.{Schema, Document, DocumentSummary, Summary}
      iex> schema = Schema.new("my_schema", Document.new())
      iex> document_summary = DocumentSummary.new("my_summary", ["my_inherited_summary"], [Summary.new("my_field", "string")])
      iex> schema = Schema.add_document_summary(schema, document_summary)
      iex> schema.document_summaries
      [%DocumentSummary{
        name: "my_summary",
        inherits: ["my_inherited_summary"],
        summary_fields: [Summary.new("my_field", "string")],
        from_disk: false,
        omit_summary_fields: false
      }]
  """

  def add_document_summary(
        %Schema{document_summaries: document_summaries} = schema,
        %DocumentSummary{} = document_summary
      ) do
    %Schema{schema | document_summaries: [document_summary | document_summaries]}
  end

  @doc """
  Adds a imported field to a document

  ## Examples

      iex> alias ExVespa.Package.{Schema, Document, ImportedField}
      iex> schema = Schema.new("my_schema", Document.new())
      iex> imported_field = ImportedField.new("my_field", "my_reference_field", "my_field_to_import")
      iex> schema = Schema.add_imported_field(schema, imported_field)
      iex> schema.imported_fields
      %{"my_field" => %ImportedField{
          name: "my_field",
          reference_field: "my_reference_field",
          field_to_import: "my_field_to_import"
        }
      }
  """

  def add_imported_field(
        %Schema{imported_fields: imported_fields} = schema,
        %ImportedField{} = imported_field
      ) do
    %Schema{
      schema
      | imported_fields: Map.put(imported_fields, imported_field.name, imported_field)
    }
  end

  @doc """
  Check if two Schema module objects are equal

  ## Examples

    iex> alias ExVespa.Package.{Schema, Document, FieldSet, RankProfile, OnnxModel, DocumentSummary, Summary, ImportedField}
    iex> schema1 = Schema.new("my_schema", Document.new())
    iex> schema2 = Schema.new("my_schema", Document.new())
    iex> schema1 == schema2
    true

    iex> alias ExVespa.Package.{Schema, Document, FieldSet, RankProfile, OnnxModel, DocumentSummary, Summary, ImportedField}
    iex> schema1 = Schema.new("my_schema", Document.new())
    iex> schema2 = Schema.new("my_schema", Document.new())
    iex> schema1 = Schema.add_field_set(schema1, FieldSet.new("my_fieldset", ["my_field"]))
    iex> schema1 == schema2
    false
  """
  def %Schema{
        name: lname,
        document: ldocument,
        fieldsets: lfieldsets,
        rank_profiles: lrank_profiles,
        models: lmodels,
        document_summaries: ldocument_summaries,
        imported_fields: limported_fields
      } = %Schema{
        name: rname,
        document: rdocument,
        fieldsets: rfieldsets,
        rank_profiles: rrank_profiles,
        models: rmodels,
        document_summaries: rdocument_summaries,
        imported_fields: rimported_fields
      } do
    lname == rname and
      ldocument == rdocument and
      lfieldsets == rfieldsets and
      lrank_profiles == rrank_profiles and
      lmodels == rmodels and
      ldocument_summaries == rdocument_summaries and
      limported_fields == rimported_fields
  end

  @doc ~S"""
  Returns a string representation of the schema.

  ## Examples

    iex> alias ExVespa.Package.{Schema, Struct, Document, Field, FieldSet, StructField, RankProfile, OnnxModel, DocumentSummary, Summary, ImportedField, Function, SecondPhaseRanking}
    iex> sf = StructField.new("title", ["index1", "index2"], ["attribute"], ["match"], ["query_command"], %ExVespa.Package.Summary{name: "summary", type: "summary", fields: ["dynamic"]})
    iex> cur_field = Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25", ann: %{hnsw: %{distance_metric: "euclidean", max_links_per_node: 16, neighbors_to_explore_at_insert: 500}}, match: ["exact", "substring"], weight: 10, bolding: true, summary: Summary.new("summary", "string"), stemming: "true", rank: "bm25", query_command: ["my_query_command"], struct_fields: [sf]})
    iex> schema = Schema.new("my_schema", Document.new([cur_field], ["my_inherited_document"], [Struct.new("my_struct", [Field.new("struct_field", "string")])]))
    iex> rank_profile = RankProfile.new("default", "1.25 * bm25(title) + 3.75 * bm25(body)", "default", %{c1: 1.0}, [Function.new("f1", "x + 1")], ["summary_feature"], SecondPhaseRanking.new("expression"))
    iex> schema = Schema.add_field_set(schema, FieldSet.new("my_fieldset", ["my_field"]))
    iex> schema = Schema.add_rank_profile(schema, rank_profile)
    iex> alias ExVespa.Package.OnnxModel
    iex> onnx_model = OnnxModel.new(
    ...>   "my_model",
    ...>   "model.onnx",
    ...>   %{
    ...>     input_ids: "input_ids",
    ...>     token_type_ids: "token_type_ids",
    ...>     attention_mask: "attention_mask",
    ...>   },
    ...>   %{
    ...>     logits: "logits"
    ...>   }
    ...> )
    iex> schema = Schema.add_model(schema, onnx_model)
    iex> doc_summary = DocumentSummary.new("my_summary", ["my_inherited_summary"], [Summary.new("my_field", "string")])
    iex> schema = Schema.add_document_summary(schema, doc_summary)
    iex> imported_field = ImportedField.new("my_field", "my_reference_field", "my_field_to_import")
    iex> schema = Schema.add_imported_field(schema, imported_field)
    iex> Schema.schema_to_text(schema)
    ~s(schema my_schema {\n    document my_schema {\n        field my_field type string {\n            indexing: attribute | summary\n            index: enable-bm25\n            \n            attribute {\n                fast-search\n\n            }\n            index {\n                hnsw {\n                  max-links-per-node: 16\n                  neighbors-to-explore-at-insert: 500\n                }\n            }\n            match {exact\nsubstring\n}\n            }\n            weight: 10\n            bolding: on\n            \nsummary summary type string {}\n            stemming: true\n            rank: bm25\n            query-command: my_query_command\n            \n            struct-field {\n              indexing: index1 | index2\n              \n              attribute {\n                \nattribute\n              }\n              \n              \n              match {match\n}\n              }\n              query-command: query_command\n              \n              summary {\n                summarytype: summary\n              }\n              \n\n              struct my_struct {\n                \n                  field struct_field type string {\n                    \n                    \n                    \n                    \n                    \n                  }\n                  \n                  \n                  \n                  \n                  \n                  \n                \n              }\n              \n            }\n        \n        }\n    }\n\n  import field my_reference_field.my_field_to_import as my_field {}\n\n\n  fieldset my_fieldset {\n    my_field\n  }\n\n\n  \n  onnx-model my_model {\n    file: files/my_model.onnx\n    \n      input attention_mask: attention_mask\n    \n      input input_ids: input_ids\n    \n      input token_type_ids: token_type_ids\n    \n    \n      output logits: logits\n    \n  }\n  \n\n}\n)
  """
  def schema_to_text(%Schema{} = schema) do
    SchemaTemplate.render(schema)
  end

  def inspect(
        %Schema{
          name: name,
          document: document,
          fieldsets: fieldsets,
          rank_profiles: rank_profiles,
          models: models,
          document_summaries: document_summaries,
          imported_fields: imported_fields
        },
        _opts
      ) do
    """
    Schema{
      name: #{inspect(name)},
      document: #{inspect(document)},
      fieldsets: #{inspect(fieldsets)},
      rank_profiles: #{inspect(rank_profiles)},
      models: #{inspect(models)},
      document_summaries: #{inspect(document_summaries)},
      imported_fields: #{inspect(imported_fields)}
    }
    """
  end
end
