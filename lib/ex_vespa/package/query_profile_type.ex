defmodule ExVespa.Package.QueryProfileType do
  @moduledoc """
  Create a Vespa Query Profile Type

  Check the `Vespa documentation <https://docs.vespa.ai/en/query-profiles.html#query-profile-types>`__ for more detailed information about query profile types.

  An :class:`ApplicationPackage` instance comes with a default :class:`QueryProfile` named `default` that is associated with a :class:`QueryProfileType` named `root`, meaning that you usually do not need to create those yourself, only add fields to them when required.
  """

  alias ExVespa.Package.QueryTypeField
  alias __MODULE__

  @keys [
    :name,
    :fields
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          name: String.t(),
          fields: list(QueryTypeField.t())
        }

  @spec validate(t()) :: t()
  defp validate(%QueryProfileType{name: name}) when is_nil(name) do
    raise ArgumentError, "name is required"
  end

  defp validate(%QueryProfileType{name: name}) when not is_binary(name) do
    raise ArgumentError, "name must be a string"
  end

  defp validate(%QueryProfileType{fields: fields}) when is_nil(fields) do
    raise ArgumentError, "fields is required"
  end

  defp validate(%QueryProfileType{fields: fields}) when not is_list(fields) do
    raise ArgumentError, "fields must be a list"
  end

  defp validate(%QueryProfileType{fields: fields} = query_profile_type)
       when length(fields) == 0 do
    query_profile_type
  end

  defp validate(%QueryProfileType{fields: fields} = query_profile_type) do
    if fields |> Enum.all?(&QueryTypeField.validate/1) do
      query_profile_type
    else
      raise ArgumentError, "Invalid field"
    end
  end

  @doc """
  Create a new query profile type

  ## Examples

    iex> alias ExVespa.Package.QueryProfileType
    iex> QueryProfileType.new("root", [])
    %QueryProfileType{
      fields: [],
      name: "root"
    }

    iex> alias ExVespa.Package.QueryProfileType
    iex> QueryProfileType.new(nil)
    ** (ArgumentError) name is required

    iex> alias ExVespa.Package.QueryProfileType
    iex> QueryProfileType.new(123)
    ** (ArgumentError) name must be a string

    iex> alias ExVespa.Package.QueryProfileType
    iex> QueryProfileType.new("root", nil)
    ** (ArgumentError) fields is required

    iex> alias ExVespa.Package.QueryProfileType
    iex> QueryProfileType.new("root", "fields")
    ** (ArgumentError) fields must be a list

    iex> alias ExVespa.Package.{QueryProfileType, QueryTypeField}
    iex> query_profile_type = QueryProfileType.new("root", [QueryTypeField.new("ranking.features.query(title_bert)", "tensor<float>(x[768])")])
    iex> query_profile_type.fields
    [%ExVespa.Package.QueryTypeField{
      name: "ranking.features.query(title_bert)",
      type: "tensor<float>(x[768])"
    }]

  """
  def new(name \\ "root", fields \\ []) do
    %QueryProfileType{
      name: name,
      fields: fields
    }
    |> validate()
  end

  def %QueryProfileType{name: lname, fields: lfields} =
        lquery_profile_type =
        %QueryProfileType{name: rname, fields: rfields} = rquery_profile_type do
    lname == rname and lfields == rfields and lquery_profile_type == rquery_profile_type
  end

  @doc """
  Add fields to a query profile type

  ## Examples

    iex> alias ExVespa.Package.{QueryProfileType, QueryTypeField}
    iex> query_profile_type = QueryProfileType.new("root", [QueryTypeField.new("ranking.features.query(title_bert)", "tensor<float>(x[768])")])
    iex> query_profile_type.fields
    [%ExVespa.Package.QueryTypeField{
      name: "ranking.features.query(title_bert)",
      type: "tensor<float>(x[768])"
    }]
    iex> query_profile_type = QueryProfileType.add_fields(query_profile_type, [QueryTypeField.new("ranking.features.query(passage_bert)", "tensor<float>(x[768])")])
    iex> query_profile_type.fields
    [%ExVespa.Package.QueryTypeField{
      name: "ranking.features.query(title_bert)",
      type: "tensor<float>(x[768])"
    }, %ExVespa.Package.QueryTypeField{
      name: "ranking.features.query(passage_bert)",
      type: "tensor<float>(x[768])"
    }]
  """
  def add_fields(%QueryProfileType{fields: fields} = query_profile_type, new_fields) do
    %QueryProfileType{
      query_profile_type
      | fields: fields ++ new_fields
    }
  end

  def inspect(%QueryProfileType{name: name, fields: fields}, _opts) do
    "#<ExVespa.Package.QueryProfileType(#{name}, #{inspect(fields)})"
  end
end
