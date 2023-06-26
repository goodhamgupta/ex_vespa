defmodule ExVespa.Package.RankProfile do
  @moduledoc """
  Create a Vespa rank profile configuration.
  Rank profiles are used to specify an alternative ranking of the same data for different purposes, and to
  experiment with new rank settings. Check the
  `Vespa documentation <https://docs.vespa.ai/en/reference/schema-reference.html#rank-profile>`__
  for more detailed information about rank profiles.
  """

  alias ExVespa.Package.{Function, SecondPhaseRanking}
  alias __MODULE__

  @keys [
    :name,
    :first_phase,
    :inherits,
    :constants,
    :functions,
    :summary_features,
    :second_phase,
    :weight,
    :rank_type,
    :rank_properties,
    :inputs
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          name: String.t(),
          first_phase: String.t(),
          inherits: String.t() | nil,
          constants: Map.t() | nil,
          functions: list(Function.t()) | nil,
          summary_features: list(String.t()) | nil,
          second_phase: SecondPhaseRanking.t() | nil,
          weight: list(Tuple.t()) | nil,
          rank_type: list(Tuple.t()) | nil,
          rank_properties: list(Tuple.t()) | nil,
          inputs: list(Tuple.t()) | nil
        }

  defp validate(%RankProfile{name: name}) when is_nil(name) do
    raise ArgumentError, "Rank profile name cannot be nil"
  end

  defp validate(%RankProfile{name: name}) when not is_binary(name) do
    raise ArgumentError, "Rank profile name must be a string"
  end

  defp validate(%RankProfile{first_phase: first_phase}) when is_nil(first_phase) do
    raise ArgumentError, "First phase ranking expression cannot be nil"
  end

  defp validate(%RankProfile{first_phase: first_phase}) when not is_binary(first_phase) do
    raise ArgumentError, "First phase ranking expression must be a string"
  end

  defp validate(input), do: input

  @doc """
  Create a rank profile configuration.

  ## Examples

    iex> ExVespa.Package.RankProfile.new(nil, nil)
    ** (ArgumentError) Rank profile name cannot be nil

    iex> ExVespa.Package.RankProfile.new(1, 1)
    ** (ArgumentError) Rank profile name must be a string

    iex> ExVespa.Package.RankProfile.new("default", nil)
    ** (ArgumentError) First phase ranking expression cannot be nil

    iex> ExVespa.Package.RankProfile.new("default", 1)
    ** (ArgumentError) First phase ranking expression must be a string

    iex> alias ExVespa.Package.RankProfile
    iex> RankProfile.new("default", "1.25 * bm25(title) + 3.75 * bm25(body)")
    %ExVespa.Package.RankProfile{
      constants: nil,
      first_phase: "1.25 * bm25(title) + 3.75 * bm25(body)",
      functions: nil,
      inherits: nil,
      name: "default",
      second_phase: nil,
      summary_features: nil
    }

    iex> alias ExVespa.Package.RankProfile
    iex> RankProfile.new("default", "1.25 * bm25(title) + 3.75 * bm25(body)", "default", %{c1: 1.0}, [ExVespa.Package.Function.new("f1", "x + 1")], ["summary_feature"], ExVespa.Package.SecondPhaseRanking.new("expression"))
    %ExVespa.Package.RankProfile{
      constants: %{c1: 1.0},
      first_phase: "1.25 * bm25(title) + 3.75 * bm25(body)",
      functions: [ExVespa.Package.Function.new("f1", "x + 1")],
      inherits: "default",
      name: "default",
      second_phase: %ExVespa.Package.SecondPhaseRanking{
        expression: "expression",
        rerank_count: 100
      },
      summary_features: ["summary_feature"]
    }
  """
  def new(
        name,
        first_phase,
        inherits \\ nil,
        constants \\ nil,
        functions \\ nil,
        summary_features \\ nil,
        second_phase \\ nil,
        weight \\ nil,
        rank_type \\ nil,
        rank_properties \\ nil,
        inputs \\ nil
      ) do
    %RankProfile{
      name: name,
      first_phase: first_phase,
      inherits: inherits,
      constants: constants,
      functions: functions,
      summary_features: summary_features,
      second_phase: second_phase,
      weight: weight,
      rank_type: rank_type,
      rank_properties: rank_properties,
      inputs: inputs
    }
    |> validate()
  end

  def %RankProfile{
        name: lname,
        first_phase: lfirst_phase,
        inherits: linherits,
        constants: lconstants,
        functions: lfunctions,
        summary_features: lsummary_features,
        second_phase: lsecond_phase,
        weight: lweight,
        rank_type: lrank_type,
        rank_properties: lrank_properties,
        inputs: linputs
      } = %RankProfile{
        name: rname,
        first_phase: rfirst_phase,
        inherits: rinherits,
        constants: rconstants,
        functions: rfunctions,
        summary_features: rsummary_features,
        second_phase: rsecond_phase,
        weight: rweight,
        rank_type: rrank_type,
        rank_properties: rrank_properties,
        inputs: rinputs
      } do
    lname == rname and
      lfirst_phase == rfirst_phase and
      linherits == rinherits and
      lconstants == rconstants and
      lfunctions == rfunctions and
      lsummary_features == rsummary_features and
      lsecond_phase == rsecond_phase and
      lweight == rweight and
      lrank_type == rrank_type and
      lrank_properties == rrank_properties and
      linputs == rinputs
  end

  def inspect(
        %RankProfile{
          name: name,
          first_phase: first_phase,
          inherits: inherits,
          constants: constants,
          functions: functions,
          summary_features: summary_features,
          second_phase: second_phase,
          weight: weight,
          rank_type: rank_type,
          rank_properties: rank_properties,
          inputs: inputs
        },
        _opts
      ) do
    "RankProfile.new(\"#{name}\", \"#{first_phase}\", #{inspect(inherits)}, #{inspect(constants)}, #{inspect(functions)}, #{inspect(summary_features)}, #{inspect(second_phase)}, #{inspect(weight)}, #{inspect(rank_type)}, #{inspect(rank_properties)}, #{inspect(inputs)})"
  end
end
