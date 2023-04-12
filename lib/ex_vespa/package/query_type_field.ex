defmodule ExVespa.Package.QueryTypeField do
  @moduledoc """
  Create a field to be included in a QueryProfileType
  """

  alias __MODULE__

  @keys [
    :name,
    :type
  ]

  defstruct @keys
  

  @type t :: %QueryTypeField{
          name: String.t(),
          type: String.t()
        }

  @spec validate(t()) :: t()
  def validate(%QueryTypeField{name: name}) when is_nil(name) do
    raise ArgumentError, "name is required"
  end

  def validate(%QueryTypeField{type: type}) when is_nil(type) do
    raise ArgumentError, "type is required"
  end

  def validate(%QueryTypeField{name: name}) when not is_binary(name) do
    raise ArgumentError, "name must be a string"
  end

  def validate(%QueryTypeField{type: type}) when not is_binary(type) do
    raise ArgumentError, "type must be a string"
  end

  def validate(%QueryTypeField{} = query_type_field) do
    query_type_field
  end

  @doc """

  Create a new query type field

  ## Examples 
  
    iex> ExVespa.Package.QueryTypeField.new("ranking.features.query(title_bert)", "tensor<float>(x[768])")
    %ExVespa.Package.QueryTypeField{
      name: "ranking.features.query(title_bert)",
      type: "tensor<float>(x[768])"
    }

    iex> alias ExVespa.Package.QueryTypeField
    iex> %QueryTypeField{name: nil}
    ** (ArgumentError) name is required

    iex> %QueryTypeField{type: nil}
    ** (ArgumentError) type is required
    
    iex> %QueryTypeField{name: 1}
    ** (ArgumentError) name must be a string

    iex> %QueryTypeField{type: 1}
    ** (ArgumentError) type must be a string

  """
  @spec new(String.t(), String.t()) :: t()
  def new(name, type) do
    %QueryTypeField{
      name: name,
      type: type
    } |> validate()
  end

  def %QueryTypeField{name: lname, type: ltype} = %QueryTypeField{name: rname, type: rtype} do
    lname == rname and ltype == rtype
  end

  def inspect(%QueryTypeField{name: name, type: type}, _opts) do
    "ExVespa.Package.QueryTypeField(#{name}, #{type})"
  end

end
