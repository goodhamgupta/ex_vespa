defmodule ExVespa.Package.Struct do
  @moduledoc """
  Create a vespa struct.

  A struct defines a composite type. Check the `Vespa documentation
  <https://docs.vespa.ai/en/reference/schema-reference.html#struct>`__
  for more detailed information about structs.
  """

  @keys [
    :name,
    :fields
  ]

  defstruct @keys
end
