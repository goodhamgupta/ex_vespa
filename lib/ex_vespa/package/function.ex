defmodule ExVespa.Package.Function do
  @moduledoc """
  Create a Vespa rank function.

  Define a named function that can be referenced as a part of the ranking expression, or (if having no arguments)
  as a feature. Check the
  `Vespa documentation <https://docs.vespa.ai/en/reference/schema-reference.html#function-rank>`__`
  for more detailed information about rank functions.
  """
  alias __MODULE__

  @keys [
    :name,
    :expression,
    :arguments
  ]

  defstruct @keys

  @type t() :: %Function{
          name: String.t(),
          expression: String.t(),
          arguments: list(String.t())
        }

  defp validate(%Function{name: name}) when is_nil(name) do
    raise ArgumentError, "Name should not be nil"
  end

  defp validate(%Function{name: name}) when not is_binary(name) and not is_nil(name) do
    raise ArgumentError, "Name should be a string"
  end

  defp validate(%Function{expression: expression}) when is_nil(expression) do
    raise ArgumentError, "Expression should not be nil"
  end

  defp validate(%Function{expression: expression})
       when not is_binary(expression) and not is_nil(expression) do
    raise ArgumentError, "Expression should be a string"
  end

  defp validate(input), do: input

  @spec new(String.t(), String.t(), list(String.t())) :: Function.t() | no_return()
  @doc """
  Creates a new function object

  ## Examples

    iex> ExVespa.Package.Function.new("my_function", "expression", ["arg1", "arg2"])
    %ExVespa.Package.Function{
      name: "my_function",
      expression: "expression",
      arguments: ["arg1", "arg2"]
    }

    iex> ExVespa.Package.Function.new(nil, "expression")
    ** (ArgumentError) Name should not be nil

    iex> ExVespa.Package.Function.new(1, "expression")
    ** (ArgumentError) Name should be a string

    iex> ExVespa.Package.Function.new("my_function", nil)
    ** (ArgumentError) Expression should not be nil

    iex> ExVespa.Package.Function.new("my_function", 1)
    ** (ArgumentError) Expression should be a string
  """
  def new(name, expression, arguments \\ []) do
    %Function{
      name: name,
      expression: expression,
      arguments: arguments
    }
    |> validate()
  end

  @doc """
  Return arguments as a string

  ## Examples

    iex> ExVespa.Package.Function.args_to_text(%ExVespa.Package.Function{arguments: []})
    ""

    iex> ExVespa.Package.Function.args_to_text(%ExVespa.Package.Function{arguments: ["arg1", "arg2"]})
    "(arg1, arg2)"
  """
  @spec args_to_text(ExVespa.Package.Function.t()) :: String.t()
  def args_to_text(%Function{arguments: []}), do: ""
  def args_to_text(%Function{arguments: args}), do: "(#{Enum.join(args, ", ")})"

  @doc """
  Check if two instances of the Function module are equal

  ## Examples

    iex> ExVespa.Package.Function.new("my_function", "expression", ["arg1", "arg2"]) == ExVespa.Package.Function.new("my_function", "expression", ["arg1", "arg2"])
    true

    iex> ExVespa.Package.Function.new("my_function", "expression", ["arg1", "arg2"]) == ExVespa.Package.Function.new("my_function", "expression", ["arg1"])
    false
  """
  def %Function{name: lname, expression: lexpression, arguments: larguments} = %Function{
        name: rname,
        expression: rexpression,
        arguments: rarguments
      } do
    lname == rname and lexpression == rexpression and larguments == rarguments
  end

  def inspect(%Function{name: name, expression: expression, arguments: arguments}, _opts) do
    "#{__MODULE__}(#{name}, #{expression}, #{arguments})"
  end
end
