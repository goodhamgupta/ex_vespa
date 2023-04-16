defmodule ExVespa.Templates.Schema do
  require EEx

  EEx.function_from_file(
    :def,
    :render,
    "#{File.cwd!()}/lib/ex_vespa/templates/schema.eex",
    [:schema]
  )
end
