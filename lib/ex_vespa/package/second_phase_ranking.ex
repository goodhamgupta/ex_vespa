defmodule ExVespa.Package.SecondPhaseRanking do
  @moduledoc """

  Create a Vespa second phase ranking configuration.

  This is the optional reranking performed on the best hits from the first phase. Check the
  `Vespa documentation <https://docs.vespa.ai/en/reference/schema-reference.html#secondphase-rank>`__`
  for more detailed information about second phase ranking configuration.

  """
  alias __MODULE__

  @keys [
    :expression,
    :rerank_count
  ]

  defstruct @keys

  defp validate(%SecondPhaseRanking{expression: expression}) when is_nil(expression) do
    raise ArgumentError, "Second phase ranking expression cannot be nil"
  end

  defp validate(%SecondPhaseRanking{expression: expression}) when not is_binary(expression) do
    raise ArgumentError, "Second phase ranking expression must be a string"
  end

  defp validate(input) do
    input
  end

  @doc """
  Create a second phase ranking configuration.

  ## Examples

    iex> ExVespa.Package.SecondPhaseRanking.new(nil)
    ** (ArgumentError) Second phase ranking expression cannot be nil

    iex> ExVespa.Package.SecondPhaseRanking.new(1)
    ** (ArgumentError) Second phase ranking expression must be a string

    iex> ExVespa.Package.SecondPhaseRanking.new("1.25 * bm25(title) + 3.75 * bm25(body)")
    %ExVespa.Package.SecondPhaseRanking{expression: "1.25 * bm25(title) + 3.75 * bm25(body)", rerank_count: 100}

    iex> ExVespa.Package.SecondPhaseRanking.new("expression", 10)
    %ExVespa.Package.SecondPhaseRanking{expression: "expression", rerank_count: 10}

  """
  @spec new(String.t(), integer()) :: %SecondPhaseRanking{}
  def new(expression, rerank_count \\ 100) do
    %SecondPhaseRanking{
      expression: expression,
      rerank_count: rerank_count
    }
    |> validate()
  end

  @doc """
  Compare two second phase ranking configurations.

  ## Examples

    iex> ExVespa.Package.SecondPhaseRanking.new("expression") == ExVespa.Package.SecondPhaseRanking.new("expression")
    true

    iex> ExVespa.Package.SecondPhaseRanking.new("expression") == ExVespa.Package.SecondPhaseRanking.new("expression", 10)
    false
  """
  def %SecondPhaseRanking{expression: lexpression, rerank_count: lrerank_count} =
        %SecondPhaseRanking{expression: rexpression, rerank_count: rrerank_count} do
    lexpression == rexpression and lrerank_count == rrerank_count
  end

  def inspect(%SecondPhaseRanking{expression: expression, rerank_count: rerank_count}) do
    "SecondPhaseRanking(#{expression}, #{rerank_count})"
  end
end
