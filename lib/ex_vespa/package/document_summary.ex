defmodule ExVespa.Package.DocumentSummary do
  @moduledoc """
  Create a Document Summary.
  Check the `Vespa documentation <https://docs.vespa.ai/en/reference/schema-reference.html#document-summary>`__
  for more detailed information about documment-summary.
  """
  alias ExVespa.Package.Summary
  alias __MODULE__

  @keys [
    :name,
    :inherits,
    :summary_fields,
    :from_disk,
    :omit_summary_fields
  ]

  defstruct @keys

  @type t() :: %DocumentSummary{
          name: String.t(),
          inherits: String.t(),
          summary_fields: list(Summary.t()),
          from_disk: boolean(),
          omit_summary_fields: boolean()
        }
  defp validate(%DocumentSummary{name: name}) when is_nil(name) do
    raise ArgumentError, "Name should not be nil"
  end

  defp validate(%DocumentSummary{name: name}) when not is_binary(name) and not is_nil(name) do
    raise ArgumentError, "Name should be a string"
  end

  defp validate(input), do: input

  @doc """
  Creates a new document summary object

  ## Examples

    iex> alias ExVespa.Package.Summary
    iex> ExVespa.Package.DocumentSummary.new("my_summary", ["my_inherited_summary"], [Summary.new("my_field", "string")])
    %ExVespa.Package.DocumentSummary{
      name: "my_summary",
      inherits: ["my_inherited_summary"],
      summary_fields: [ExVespa.Package.Summary.new("my_field", "string")],
      from_disk: false,
      omit_summary_fields: false
    }

    iex> ExVespa.Package.DocumentSummary.new(nil)
    ** (ArgumentError) Name should not be nil

    iex> ExVespa.Package.DocumentSummary.new(1)
    ** (ArgumentError) Name should be a string

  """
  def new(
        name,
        inherits \\ nil,
        summary_fields \\ [],
        from_disk \\ false,
        omit_summary_fields \\ false
      ) do
    %DocumentSummary{
      name: name,
      inherits: inherits,
      summary_fields: summary_fields,
      from_disk: from_disk,
      omit_summary_fields: omit_summary_fields
    }
    |> validate()
  end

  def %DocumentSummary{
        name: lname,
        inherits: linherits,
        summary_fields: lsummary_fields,
        from_disk: lfrom_disk,
        omit_summary_fields: lomit_summary_fields
      } = %DocumentSummary{
        name: rname,
        inherits: rinherits,
        summary_fields: rsummary_fields,
        from_disk: rfrom_disk,
        omit_summary_fields: romit_summary_fields
      } do
    lname == rname and linherits == rinherits and lsummary_fields == rsummary_fields and
      lfrom_disk == rfrom_disk and lomit_summary_fields == romit_summary_fields
  end

  def inspect(
        %DocumentSummary{
          name: name,
          inherits: inherits,
          summary_fields: summary_fields,
          from_disk: from_disk,
          omit_summary_fields: omit_summary_fields
        },
        _opts
      ) do
    "#{__MODULE__}(#{name}, [#{Enum.join(inherits, ", ")}], [#{Enum.join(summary_fields, ", ")}], #{from_disk}, #{omit_summary_fields}])"
  end
end
