defmodule ExVespa.Package.QueryProfile do
  @moduledoc """
  Create a Vespa Query Profile

  Check the `Vespa documentation <https://docs.vespa.ai/en/query-profiles.html>`__
  for more detailed information about query profiles.

  A `QueryProfile` is a named collection of query request parameters given in the configuration.
  The query request can specify a query profile whose parameters will be used as parameters of that request.
  """

  alias ExVespa.Package.{QueryField}
  alias __MODULE__

  @keys [
    :name,
    :type,
    :fields
  ]

  defstruct @keys

  @type t :: %__MODULE__{
          name: String.t(),
          type: String.t(),
          fields: [QueryField.t()]
        }

  def validate(%QueryProfile{name: name}) when is_nil(name) do
    raise ArgumentError, "name is required"
  end

  def validate(%QueryProfile{type: type}) when is_nil(type) do
    raise ArgumentError, "type is required"
  end

  def validate(%QueryProfile{fields: fields}) when is_nil(fields) do
    raise ArgumentError, "fields is required"
  end

  def validate(query_profile), do: query_profile

  @doc """
  Create a QueryProfile

  ## Examples

    iex> alias ExVespa.Package.{QueryProfile, QueryField}
    iex> QueryProfile.new("default", "root", [QueryField.new("maxHits", 100)])
    %QueryProfile{
      fields: [
        %QueryField{
          name: "maxHits",
          value: 100
        }
      ],
      name: "default",
      type: "root"
    }
  """

  @spec new(String.t(), String.t(), [QueryField.t()]) :: t()
  def new(name \\ "default", type \\ "root", fields \\ []) do
    %QueryProfile{
      name: name,
      type: type,
      fields: fields
    }
    |> validate()
  end

  @doc """
  Add a field to a QueryProfile

  ## Examples
    iex> alias ExVespa.Package.{QueryProfile, QueryField}
    iex> QueryProfile.new("default", "root", [QueryField.new("maxHits", 100)])
    %QueryProfile{
      fields: [
        %QueryField{
          name: "maxHits",
          value: 100
        }
      ],
      name: "default",
      type: "root"
    }
    iex> QueryProfile.add_fields(%QueryProfile{
    ...>   fields: [
    ...>     %QueryField{
    ...>       name: "maxHits",
    ...>       value: 100
    ...>     }
    ...>   ],
    ...>   name: "default",
    ...>   type: "root"
    ...> }, [QueryField.new("timeout", 10000)])
    %QueryProfile{
      fields: [
        %QueryField{
          name: "maxHits",
          value: 100
        },
        %QueryField{
          name: "timeout",
          value: 10000
        }
      ],
      name: "default",
      type: "root"
    }
  """
  def add_fields(query_profile, fields) do
    %QueryProfile{
      query_profile
      | fields: query_profile.fields ++ fields
    }
  end

  @doc """
  Check if two QueryProfiles are equal

  ## Examples 
    iex> alias ExVespa.Package.{QueryProfile, QueryField}
    iex> %QueryProfile{
    ...>   fields: [
    ...>     %QueryField{
    ...>       name: "maxHits",
    ...>       value: 100
    ...>     }
    ...>   ],
    ...>   name: "default",
    ...>   type: "root"
    ...> } == %QueryProfile{
    ...>   fields: [
    ...>     %QueryField{
    ...>       name: "maxHits",
    ...>       value: 100
    ...>     }
    ...>   ],
    ...>   name: "default",
    ...>   type: "root"
    ...> }
    true
  """
  def %QueryProfile{name: lname, type: ltype, fields: lfields} = %QueryProfile{
        name: rname,
        type: rtype,
        fields: rfields
      } do
    lname == rname and ltype == rtype and lfields == rfields
  end

  def inspect(%QueryProfile{name: name, type: type, fields: fields}, _opts) do
    "#<ExVespa.Package.QueryProfile name: \"#{name}\", type: \"#{type}\", fields: #{inspect(fields)}>"
  end
end
