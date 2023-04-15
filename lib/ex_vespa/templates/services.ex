defmodule ExVespa.Templates.Services do
  require EEx

  EEx.function_from_file(:def, :render, "#{File.cwd!()}/lib/ex_vespa/templates/services.eex", [
    :application_name,
    :schemas,
    :configurations,
    :stateless_model_evaluation
  ])
end
