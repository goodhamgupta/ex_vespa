defmodule ExVespa.Templates.QueryProfileType do
  require EEx

  EEx.function_from_file(
    :def,
    :render,
    "#{File.cwd!()}/lib/ex_vespa/templates/query_profile_type.eex",
    [:fields]
  )
end
