defmodule ExVespa.Package.ApplicationPackage do
  @moduledoc """
   Create an `Application Package <https://docs.vespa.ai/en/application-packages.html>`__.
   An :class:`ApplicationPackage` instance comes with a default :class:`Schema`
   that contains a default :class:`Document`
  """

  alias ExVespa.Package.{
    Document,
    Schema,
    QueryProfile,
    QueryProfileType,
    Configuration,
    Validation
  }

  alias __MODULE__

  @keys [
    :name,
    :schema,
    :query_profile,
    :query_profile_type,
    :model_ids,
    :model_configs,
    :stateless_model_evaluation,
    :create_schema_by_default,
    :create_query_profile_by_default,
    :configurations,
    :validations
  ]

  defstruct @keys

  @type t :: %ApplicationPackage{
          name: String.t(),
          schema: list(Schema.t()) | nil,
          query_profile: QueryProfile.t() | nil,
          query_profile_type: QueryProfileType.t() | nil,
          model_ids: list(String.t()) | [],
          model_configs: map(),
          stateless_model_evaluation: boolean(),
          create_schema_by_default: boolean(),
          create_query_profile_by_default: boolean(),
          configurations: list(Configuration.t()) | nil,
          validations: list(Validation.t()) | nil
        }

  defp convert_list_to_map(input_list) when is_map(input_list) do
    input_list
  end

  defp convert_list_to_map(input_list) when is_list(input_list) do
    input_list
    |> Enum.map(fn x -> %{x.name => x} end)
    |> Enum.reduce(%{}, fn x, acc -> Map.merge(x, acc) end)
  end

  def validate(%ApplicationPackage{name: name}) when is_nil(name) do
    raise ArgumentError, "name is required"
  end

  def validate(application_package), do: application_package

  @doc """
  Create an ApplicationPackage instance

  ## Examples

    iex> alias ExVespa.Package.{ApplicationPackage, Schema, Document}
    iex> ApplicationPackage.new("my_app")
    %ApplicationPackage{                                                                                                                                                         
        configurations: [],                                                                                                                                                                        
        create_query_profile_by_default: false,                                                                                                                                                    
        create_schema_by_default: false,                                                                                                                                                           
        model_configs: %{},                                                                                                                                                                        
        model_ids: [],                                                                                                                                                                             
        name: "my_app",                                                                                                                                                                            
        query_profile: %ExVespa.Package.QueryProfile{name: "default", type: "root", fields: []},                                                                                                   
        query_profile_type: %ExVespa.Package.QueryProfileType{name: "root", fields: []},                                                                                                           
        schema: %{                                                                                                                                                                                 
        "my_app" => %ExVespa.Package.Schema{name: "my_app", document: %ExVespa.Package.Document{_fields: %{}, inherits: [], _structs: %{}}, fieldsets: %{}, rank_profiles: %{}, models: [], global_document: false, imported_fields: %{}, document_summaries: []}                                                                                                                                         
        },                                                                                                                                                                                         
        stateless_model_evaluation: false,                                                                                                                                                         
        validations: []                                                                                                                                                                            
    }
  """
  def new(name, opts \\ %{}) do
    schema =
      if Map.get(opts, :schema) == nil do
        interim =
          if Map.get(opts, :create_schema_by_default, true) do
            [Schema.new(name, Document.new())]
          else
            []
          end

        interim
      else
        opts[:schema]
      end

    query_profile =
      if Map.get(opts, :query_profile) == nil do
        if Map.get(opts, :create_query_profile_by_default, true) do
          QueryProfile.new()
        else
          nil
        end
      else
        opts[:query_profile]
      end

    query_profile_type =
      if Map.get(opts, :query_profile_type) == nil do
        if Map.get(opts, :create_query_profile_by_default, true) do
          QueryProfileType.new()
        else
          nil
        end
      else
        opts[:query_profile_type]
      end

    %ApplicationPackage{
      name: name,
      schema: convert_list_to_map(schema),
      query_profile: query_profile,
      query_profile_type: query_profile_type,
      model_ids: Map.get(opts, :model_ids, []),
      model_configs: Map.get(opts, :model_configs, %{}),
      stateless_model_evaluation: Map.get(opts, :stateless_model_evaluation, false),
      create_schema_by_default: Map.get(opts, :create_schema_by_default, false),
      create_query_profile_by_default: Map.get(opts, :create_query_profile_by_default, false),
      configurations: Map.get(opts, :configurations, []),
      validations: Map.get(opts, :validations, [])
    }
    |> validate()
  end

  @doc """
  List all schemas in the application package

  ## Examples 

    iex> alias ExVespa.Package.{ApplicationPackage, Schema, Document}
    iex> app_package = ApplicationPackage.new("my_app")
    iex> ApplicationPackage.schemas(app_package)
    [%Schema{name: "my_app", document: %Document{_fields: %{}, inherits: [], _structs: %{}}, fieldsets: %{}, rank_profiles: %{}, models: [], global_document: false, imported_fields: %{}, document_summaries: []}]
  """
  def schemas(%ApplicationPackage{schema: schema}), do: Map.values(schema)

  def add_schema(%ApplicationPackage{schema: schema} = application_package, schema_to_add) do
    new_schema = Map.put(schema, schema_to_add.name, schema_to_add)

    %{application_package | schema: new_schema}
  end

  def query_profile_to_text(%ApplicationPackage{query_profile: query_profile}) do
    QueryProfile.to_text(query_profile)
  end

end
