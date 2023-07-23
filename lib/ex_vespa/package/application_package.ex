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
    :models,
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
          models: map() | {},
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
        models: %{},
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
      models: Keyword.get(opts, :models, %{}),
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

  @doc """
  Get schema by name in app package

  ## Examples

    iex> alias ExVespa.Package.{ApplicationPackage, Schema, Document}
    iex> app_package = ApplicationPackage.new("my_app")
    iex> ApplicationPackage.get_schema(app_package, "my_app")
    %Schema{name: "my_app", document: %Document{_fields: %{}, inherits: [], _structs: %{}}, fieldsets: %{}, rank_profiles: %{}, models: [], global_document: false, imported_fields: %{}, document_summaries: []}
  """
  def get_schema(app_package, name \\ nil)

  def get_schema(%ApplicationPackage{schema: schema}, _) when length(schema) == 0 do
    raise ArgumentError, "No schemas defined in application package"
  end

  def get_schema(%ApplicationPackage{schema: schema}, name) when is_nil(name) do
    Map.values(schema) |> List.first()
  end

  def get_schema(%ApplicationPackage{schema: schema}, name) do
    Map.get(schema, name)
  end

  def add_schema(%ApplicationPackage{schema: schema} = application_package, schema_to_add) do
    new_schema = Map.put(schema, schema_to_add.name, schema_to_add)

    %{application_package | schema: new_schema}
  end

  def get_model(%ApplicationPackage{models: _models}, name) when is_nil(name) do
    raise ArgumentError, "Model name cannot be nil"
  end

  def get_model(%ApplicationPackage{models: models}, name) do
    Map.fetch(models, name)
  end

  @doc ~S"""
  Get query profile template as text

  ## Examples

      iex> alias ExVespa.Package.{ApplicationPackage}
      iex> app_package = ApplicationPackage.new("my_app")
      iex> ApplicationPackage.query_profile_to_text(app_package)
      ~s(<query-profile id=\"default\" type=\"root\">\n</query-profile>)

      iex> # Test with fields in the query_profile
      iex> alias ExVespa.Package.{ApplicationPackage, QueryProfile, QueryField}
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

    iex> alias ExVespa.Package.{ApplicationPackage}
    iex> app_package = ApplicationPackage.new("my_app")
    iex> ApplicationPackage.query_profile_type_to_text(app_package)
    ~s(<query-profile-type id=\"root\">\n</query-profile-type>)

    iex> # Test with fields in the query_profile_type
    iex> alias ExVespa.Package.{ApplicationPackage, QueryProfileType, QueryField}
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
    ~s(<?xml version=\"1.0\" encoding=\"UTF-8\"?>\n<services version=\"1.0\">\n\n    <container id=\"my_app_container\" version=\"1.0\">\n        <search></search>\n        <document-api></document-api>\n    </container>\n    <content id=\"my_app_content\" version=\"1.0\">\n        <redundancy reply-after=\"1\">1</redundancy>\n        <documents>\n            <document type=\"my_app\" mode=\"index\"></document>\n        </documents>\n        <nodes>\n            <node hostalias=\"node1\" distribution-key=\"0\"/>\n        </nodes>\n    </content>\n</services>\n)
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

  defp setup_dirs(%ApplicationPackage{} = app_package) do
    dir = Path.join(System.tmp_dir!(), "vespa_package_#{app_package.name}")

    if File.exists?(dir) do
      File.rm_rf!(dir)
    end

    File.mkdir!(dir)
    dir |> Path.join("schemas") |> File.mkdir!()
    dir |> Path.join("files") |> File.mkdir!()
    qp_path = dir |> Path.join("search/query-profiles/")
    File.mkdir_p!(qp_path)
    types_path = Path.join(qp_path, "types")
    File.mkdir_p!(types_path)
    {dir, qp_path}
  end

  def to_files(%ApplicationPackage{} = app_package) do
    {dir, qp_path} = setup_dirs(app_package)
    # Write services file
    dir
    |> Path.join("services.xml")
    |> File.write!(ApplicationPackage.services_to_text(app_package))

    # Write validation overrides file
    dir
    |> Path.join("validation-overrides.xml")
    |> File.write!(ApplicationPackage.validations_to_text(app_package))

    # Iterate over schemas and write them to disk
    Enum.each(ApplicationPackage.schemas(app_package), fn schema ->
      dir
      |> Path.join("schemas")
      |> Path.join("#{schema.name}.sd")
      |> File.write!(Schema.schema_to_text(schema))
    end)

    # TODO: Add support to write onnx files to disk

    if app_package.query_profile do
      qp_path
      |> Path.join("default.xml")
      |> File.write!(ApplicationPackage.query_profile_to_text(app_package))

      File.write(
        qp_path |> Path.join("types/root.xml"),
        ApplicationPackage.query_profile_type_to_text(app_package)
      )
    end

    IO.puts("Files available at: #{dir}")
    dir
  end

  def to_zip(%ApplicationPackage{} = app_package, zip_name \\ "vespa.zip") do
    dir = to_files(app_package)
    files = File.ls!(dir) |> Enum.map(&String.to_charlist/1)
    {:ok, {_zip_name, data}} = :zip.create("#{zip_name}", files, [:memory, cwd: dir])
    {:ok, data}
  end

  def to_zipfile(%ApplicationPackage{} = app_package, zip_name \\ "vespa.zip") do
    {:ok, data} = to_zip(app_package, zip_name)
    File.write!(zip_name, data)
    {:ok, zip_name}
  end
end
