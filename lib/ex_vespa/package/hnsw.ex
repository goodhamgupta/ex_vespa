defmodule ExVespa.Package.HNSW do
  @keys [
    :distance_metric,
    :max_links_per_node,
    :neighbors_to_explore_at_insert
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          distance_metric: String.t(),
          max_links_per_node: integer(),
          neighbors_to_explore_at_insert: integer()
        }

  def validate(%__MODULE__{distance_metric: distance_metric})
      when not is_binary(distance_metric) do
    raise ArgumentError, "Distance metric should be a string"
  end

  def validate(input), do: input

  @doc """
  Creates a new HNSW struct.

  ## Examples

        iex> alias ExVespa.Package.HNSW
        iex> HNSW.new("euclidean", 16, 200)
        %HNSW{
          distance_metric: "euclidean",
          max_links_per_node: 16,
          neighbors_to_explore_at_insert: 200
        }

        iex> alias ExVespa.Package.HNSW
        iex> HNSW.new(nil, 16, 200)
        ** (ArgumentError) Distance metric should be a string
  """
  @spec new(String.t(), integer(), integer()) :: t() | no_return()
  def new(
        distance_metric \\ "euclidean",
        max_links_per_node \\ 16,
        neighbors_to_explore_at_insert \\ 200
      ) do
    %__MODULE__{
      distance_metric: distance_metric,
      max_links_per_node: max_links_per_node,
      neighbors_to_explore_at_insert: neighbors_to_explore_at_insert
    }
    |> validate()
  end

  @doc """
  Checks if two instances of the HNSW struct are equal.

  ## Examples

      iex> ExVespa.Package.HNSW.new("euclidean", 16, 200) == ExVespa.Package.HNSW.new("euclidean", 16, 200)
      true

      iex> ExVespa.Package.HNSW.new("euclidean", 16, 200) == ExVespa.Package.HNSW.new("euclidean", 16, 100)
      false
  """
  def %__MODULE__{
        distance_metric: ldistance_metric,
        max_links_per_node: lmax_links_per_node,
        neighbors_to_explore_at_insert: lneighbors_to_explore_at_insert
      } = %__MODULE__{
        distance_metric: rdistance_metric,
        max_links_per_node: rmax_links_per_node,
        neighbors_to_explore_at_insert: rneighbors_to_explore_at_insert
      } do
    ldistance_metric == rdistance_metric and
      lmax_links_per_node == rmax_links_per_node and
      lneighbors_to_explore_at_insert == rneighbors_to_explore_at_insert
  end

  def inspect(
        %__MODULE__{
          distance_metric: distance_metric,
          max_links_per_node: max_links_per_node,
          neighbors_to_explore_at_insert: neighbors_to_explore_at_insert
        },
        _opts
      ) do
    "HNSW(#{distance_metric}, #{max_links_per_node}, #{neighbors_to_explore_at_insert})"
  end
end
