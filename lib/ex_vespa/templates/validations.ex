defmodule ExVespa.Templates.Validations do
  require EEx

  EEx.function_from_file(
    :def,
    :render,
    "#{File.cwd!()}/lib/ex_vespa/templates/validation_overrides.eex",
    [:validations]
  )
end
