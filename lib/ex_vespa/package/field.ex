defmodule ExVespa.Package.Field do
  alias ExVespa.Package.{HNSW, Summary, Struct}

  alias __MODULE__

  @keys [
    :name,
    :type,
    :indexing,
    :attribute,
    :index,
    :ann,
    :match,
    :weight,
    :bolding,
    :summary,
    :stemming,
    :rank,
    :query_command,
    :struct_fields
  ]

  defstruct @keys

  @type t :: %{
          name: String.t(),
          type: String.t(),
          indexing: list(String.t()),
          attribute: list(String.t()),
          index: String.t(),
          ann: HNSW.t(),
          match: list(String.t()) | list({String.t(), String.t()}),
          weight: Integer.t(),
          bolding: boolean,
          summary: Summary.t(),
          stemming: String.t(),
          rank: String.t(),
          query_command: list(String.t()),
          struct_fields: list(Struct.t())
        }

  def validate(%__MODULE__{name: name}) when is_nil(name) do
    raise ArgumentError, "Name should not be nil"
  end

  def validate(%__MODULE__{name: name}) when not is_binary(name) and not is_nil(name) do
    raise ArgumentError, "Name should be a string"
  end

  def validate(%__MODULE__{type: type}) when is_nil(type) do
    raise ArgumentError, "Type should not be nil"
  end

  def validate(%__MODULE__{type: type}) when not is_binary(type) and not is_nil(type) do
    raise ArgumentError, "Type should be a string"
  end

  def validate(input), do: input

  @doc """
  Creates a new field object

  ## Examples

    iex> alias ExVespa.Package.Field
    iex> Field.new("my_field", "string")
    %Field{
      name: "my_field",
      type: "string"
    }

    iex> alias ExVespa.Package.Field
    iex> Field.new(nil, "string")
    ** (ArgumentError) Name should not be nil

    iex> alias ExVespa.Package.Field
    iex> Field.new("my_field", nil)
    ** (ArgumentError) Type should not be nil

    iex> alias ExVespa.Package.Field
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"]})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"]
    }

    iex> alias ExVespa.Package.Field
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"]})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"]
    }

    iex> alias ExVespa.Package.Field
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25"})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"],
      index: "enable-bm25"
    }

    iex> alias ExVespa.Package.Field
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25", ann: %{hnsw: %{max_links_per_node: 16, neighbors_to_explore_at_insert: 500}}})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"],
      index: "enable-bm25",
      ann: %{
        hnsw: %{
          max_links_per_node: 16,
          neighbors_to_explore_at_insert: 500
        }
      }
    }

    iex> alias ExVespa.Package.Field
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25", ann: %{hnsw: %{max_links_per_node: 16, neighbors_to_explore_at_insert: 500}}, match: ["exact", "substring"]})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"],
      index: "enable-bm25",
      ann: %{
        hnsw: %{
          max_links_per_node: 16,
          neighbors_to_explore_at_insert: 500
        }
      },
      match: ["exact", "substring"]
    }

    iex> alias ExVespa.Package.Field
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25", ann: %{hnsw: %{max_links_per_node: 16, neighbors_to_explore_at_insert: 500}}, match: ["exact", "substring"], weight: 10})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"],
      index: "enable-bm25",
      ann: %{
        hnsw: %{
          max_links_per_node: 16,
          neighbors_to_explore_at_insert: 500
        }
      },
      match: ["exact", "substring"],
      weight: 10
    }

    iex> alias ExVespa.Package.Field
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25", ann: %{hnsw: %{max_links_per_node: 16, neighbors_to_explore_at_insert: 500}}, match: ["exact", "substring"], weight: 10, bolding: true})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"],
      index: "enable-bm25",
      ann: %{
        hnsw: %{
          max_links_per_node: 16,
          neighbors_to_explore_at_insert: 500
        }
      },
      match: ["exact", "substring"],
      weight: 10,
      bolding: true
    }

    iex> alias ExVespa.Package.{Field, Summary}
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25", ann: %{hnsw: %{max_links_per_node: 16, neighbors_to_explore_at_insert: 500}}, match: ["exact", "substring"], weight: 10, bolding: true, summary: Summary.new("summary", "string")})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"],
      index: "enable-bm25",
      ann: %{
        hnsw: %{
          max_links_per_node: 16,
          neighbors_to_explore_at_insert: 500
        }
      },
      match: ["exact", "substring"],
      weight: 10,
      bolding: true,
      summary: Summary.new("summary", "string")
    }

    iex> alias ExVespa.Package.{Field, Summary}
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25", ann: %{hnsw: %{max_links_per_node: 16, neighbors_to_explore_at_insert: 500}}, match: ["exact", "substring"], weight: 10, bolding: true, summary: Summary.new("summary", "string"), stemming: "true"})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"],
      index: "enable-bm25",
      ann: %{
        hnsw: %{
          max_links_per_node: 16,
          neighbors_to_explore_at_insert: 500
        }
      },
      match: ["exact", "substring"],
      weight: 10,
      bolding: true,
      summary: Summary.new("summary", "string"),
      stemming: "true"
    }

    iex> alias ExVespa.Package.{Field, Summary}
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25", ann: %{hnsw: %{max_links_per_node: 16, neighbors_to_explore_at_insert: 500}}, match: ["exact", "substring"], weight: 10, bolding: true, summary: Summary.new("summary", "string"), stemming: "true", rank: "bm25"})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"],
      index: "enable-bm25",
      ann: %{
        hnsw: %{
          max_links_per_node: 16,
          neighbors_to_explore_at_insert: 500
        }
      },
      match: ["exact", "substring"],
      weight: 10,
      bolding: true,
      summary: Summary.new("summary", "string"),
      stemming: "true",
      rank: "bm25"
    }

    iex> alias ExVespa.Package.{Field, Summary}
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25", ann: %{hnsw: %{max_links_per_node: 16, neighbors_to_explore_at_insert: 500}}, match: ["exact", "substring"], weight: 10, bolding: true, summary: Summary.new("summary", "string"), stemming: "true", rank: "bm25", query_command: "my_query_command"})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"],
      index: "enable-bm25",
      ann: %{
        hnsw: %{
          max_links_per_node: 16,
          neighbors_to_explore_at_insert: 500
        }
      },
      match: ["exact", "substring"],
      weight: 10,
      bolding: true,
      summary: Summary.new("summary", "string"),
      stemming: "true",
      rank: "bm25",
      query_command: "my_query_command"
    }

    iex> alias ExVespa.Package.{Field, Summary, StructField}
    iex> Field.new("my_field", "string", %{indexing: ["attribute", "summary"], attribute: ["fast-search"], index: "enable-bm25", ann: %{hnsw: %{max_links_per_node: 16, neighbors_to_explore_at_insert: 500}}, match: ["exact", "substring"], weight: 10, bolding: true, summary: Summary.new("summary", "string"), stemming: "true", rank: "bm25", query_command: "my_query_command", struct_fields: [StructField.new("structfield")]})
    %Field{
      name: "my_field",
      type: "string",
      indexing: ["attribute", "summary"],
      attribute: ["fast-search"],
      index: "enable-bm25",
      ann: %{
        hnsw: %{
          max_links_per_node: 16,
          neighbors_to_explore_at_insert: 500
        }
      },
      match: ["exact", "substring"],
      weight: 10,
      bolding: true,
      summary: Summary.new("summary", "string"),
      stemming: "true",
      rank: "bm25",
      query_command: "my_query_command",
      struct_fields: [StructField.new("structfield")]
    }

  """
  def new(
        name,
        type,
        opts \\ %{}
      ) do
    %Field{
      name: name,
      type: type,
      indexing: Map.get(opts, :indexing, nil),
      attribute: Map.get(opts, :attribute, nil),
      index: Map.get(opts, :index, nil),
      ann: Map.get(opts, :ann, nil),
      match: Map.get(opts, :match, nil),
      weight: Map.get(opts, :weight, nil),
      bolding: Map.get(opts, :bolding, nil),
      summary: Map.get(opts, :summary, nil),
      stemming: Map.get(opts, :stemming, nil),
      rank: Map.get(opts, :rank, nil),
      query_command: Map.get(opts, :query_command, nil),
      struct_fields: Map.get(opts, :struct_fields, nil)
    }
    |> validate()
  end

  def %Field{
        name: lname,
        type: ltype,
        indexing: lindexing,
        attribute: lattribute,
        index: lindex,
        ann: lann,
        match: lmatch,
        weight: lweight,
        bolding: lbolding,
        summary: lsummary,
        stemming: lstemming,
        rank: lrank,
        query_command: lquery_command,
        struct_fields: lstruct_fields
      } = %Field{
        name: rname,
        type: rtype,
        indexing: rindexing,
        attribute: rattribute,
        index: rindex,
        ann: rann,
        match: rmatch,
        weight: rweight,
        bolding: rbolding,
        summary: rsummary,
        stemming: rstemming,
        rank: rrank,
        query_command: rquery_command,
        struct_fields: rstruct_fields
      } do
    lname == rname and ltype == rtype and lindexing == rindexing and
      lattribute == rattribute and lindex == rindex and lann == rann and lmatch == rmatch and
      lweight == rweight and lbolding == rbolding and lsummary == rsummary and
      lstemming == rstemming and lrank == rrank and lquery_command == rquery_command and
      lstruct_fields == rstruct_fields
  end

  def inspect(%Field{
        name: name,
        type: type,
        indexing: indexing,
        attribute: attribute,
        index: index,
        ann: ann,
        match: match,
        weight: weight,
        bolding: bolding,
        summary: summary,
        stemming: stemming,
        rank: rank,
        query_command: query_command,
        struct_fields: struct_fields
      }) do
    "Field(#{name}, #{type}, #{indexing}, #{attribute}, #{index}, #{ann}, #{match}, #{weight}, #{bolding}, #{summary}, #{stemming}, #{rank}, #{query_command}, #{struct_fields})"
  end
end
