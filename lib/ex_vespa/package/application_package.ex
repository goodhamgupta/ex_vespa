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

  alias ExVespa.Templates.QueryProfile, as: QueryProfileTemplate
  alias ExVespa.Templates.QueryProfileType, as: QueryProfileTypeTemplate
  alias ExVespa.Templates.Services, as: ServicesTemplate
  alias ExVespa.Templates.Validations, as: ValidationsTemplate

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
  def new(name, opts \\ []) do
    schema =
      if Keyword.get(opts, :schema) == nil do
        interim =
          if Keyword.get(opts, :create_schema_by_default, true) do
            [Schema.new(name, Document.new())]
          else
            []
          end

        interim
      else
        opts[:schema]
      end

    query_profile =
      if Keyword.get(opts, :query_profile) == nil do
        if Keyword.get(opts, :create_query_profile_by_default, true) do
          QueryProfile.new()
        else
          nil
        end
      else
        opts[:query_profile]
      end

    query_profile_type =
      if Keyword.get(opts, :query_profile_type) == nil do
        if Keyword.get(opts, :create_query_profile_by_default, true) do
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
      model_ids: Keyword.get(opts, :model_ids, []),
      model_configs: Keyword.get(opts, :model_configs, %{}),
      stateless_model_evaluation: Keyword.get(opts, :stateless_model_evaluation, false),
      create_schema_by_default: Keyword.get(opts, :create_schema_by_default, false),
      create_query_profile_by_default: Keyword.get(opts, :create_query_profile_by_default, false),
      configurations: Keyword.get(opts, :configurations, []),
      validations: Keyword.get(opts, :validations, [])
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

  @doc ~S"""
  Get query profile template as text

  ## Examples

      iex> alias ExVespa.Package.{ApplicationPackage, Schema, Document}
      iex> app_package = ApplicationPackage.new("my_app")
      iex> ApplicationPackage.query_profile_to_text(app_package)
      ~s(<query-profile id=\"default\" type=\"root\">\n</query-profile>)

      iex> # Test with fields in the query_profile
      iex> alias ExVespa.Package.{ApplicationPackage, Schema, Document, QueryProfile, QueryField}
      iex> app_package = ApplicationPackage.new("my_app", query_profile: QueryProfile.new() |> QueryProfile.add_fields(
      ...> [QueryField.new("field1", "string"), QueryField.new("field2", "string")]
      ...> ))
      iex> ApplicationPackage.query_profile_to_text(app_package)
      ~s(<query-profile id=\"default\" type=\"root\">\n<field name=\"field1\">string</field>\n<field name=\"field2\">string</field>\n</query-profile>)
  """
  def query_profile_to_text(%ApplicationPackage{query_profile: query_profile}) do
    QueryProfileTemplate.render(query_profile.fields)
  end

  @doc ~S"""
  Get query profile type template as text

  ## Examples

    iex> alias ExVespa.Package.{ApplicationPackage, Schema, Document}
    iex> app_package = ApplicationPackage.new("my_app")
    iex> ApplicationPackage.query_profile_type_to_text(app_package)
    ~s(<query-profile-type id=\"root\">\n</query-profile-type>)

    iex> # Test with fields in the query_profile_type
    iex> alias ExVespa.Package.{ApplicationPackage, Schema, Document, QueryProfileType, QueryField}
    iex> app_package = ApplicationPackage.new("my_app", query_profile_type: QueryProfileType.new() |> QueryProfileType.add_fields(
    ...> [QueryField.new("field1", "string"), QueryField.new("field2", "string")]
    ...> ))
    iex> ApplicationPackage.query_profile_type_to_text(app_package)
    ~s(<query-profile-type id=\"root\">\n<field name=\"field1\">string</field>\n<field name=\"field2\">string</field>\n</query-profile-type>)
  """
  def query_profile_type_to_text(%ApplicationPackage{query_profile_type: query_profile_type}) do
    QueryProfileTypeTemplate.render(query_profile_type.fields)
  end

  @doc ~S"""
  Get services as template text

  ## Examples

    iex> alias ExVespa.Package.ApplicationPackage
    iex> app_package = ApplicationPackage.new("my_app")
    iex> ApplicationPackage.services_to_text(app_package)
    ~s(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<services version=\"1.0\">\n\n\n    <container id=my_app_container version=\"1.0\">\n        <search></search>\n        <document-api></document-api>\n    </container>\n    <content id=my_app_content version=\"1.0\">\n        <redundancy reply-after=\"1\">1</redundancy>\n        <documents>\n        \n            <document type=\"my_app\" mode=\"index\"></document>\n        \n        </documents>\n        <nodes>\n            <node hostalias=\"node1\" distribution-key=\"0\"/>\n        </nodes>\n    </content>\n</services>\n)
  """
  def services_to_text(
        %ApplicationPackage{
          name: name,
          configurations: configurations,
          stateless_model_evaluation: stateless_model_evaluation
        } = app_package
      ) do
    ServicesTemplate.render(
      name,
      ApplicationPackage.schemas(app_package),
      configurations,
      stateless_model_evaluation
    )
  end

  @doc ~S"""
  Get validations as template text

  ## Examples

    iex> alias ExVespa.Package.ApplicationPackage
    iex> app_package = ApplicationPackage.new("my_app")
    iex> ApplicationPackage.validations_to_text(app_package)
    ~s(<validation-overrides>\n    \n</validation-overrides>)

    iex> # Test with validations
    iex> alias ExVespa.Package.{ApplicationPackage, Validation}
    iex> app_package = ApplicationPackage.new("my_app", validations: [Validation.new(10, "2022-03-01", "test comment")])
    iex> ApplicationPackage.validations_to_text(app_package)
    ~s(<validation-overrides>\n    <allow until=\"2022-03-01\" comment=\"test comment\">10</allow>\n</validation-overrides>)
  """
  def validations_to_text(%ApplicationPackage{validations: validations}) do
    ValidationsTemplate.render(validations)
  end

  def %ApplicationPackage{name: lname, schema: lschema} = %ApplicationPackage{
        name: rname,
        schema: rschema
      } do
    lname == rname and lschema == rschema
  end

  def inspect(
        %ApplicationPackage{
          name: name,
          query_profile: query_profile,
          query_profile_type: query_profile_type
        } = app_package,
        _opts
      ) do
    schemas = ApplicationPackage.schemas(app_package)

    "#ExVespa.Package.ApplicationPackage<name: #{name}, schemas: #{inspect(schemas)} query_profile: #{inspect(query_profile)} query_profile_type: #{inspect(query_profile_type)}>"
  end
end
