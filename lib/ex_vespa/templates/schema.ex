defmodule ExVespa.Templates.Schema do
  require EEx

  EEx.function_from_file(
    :def,
    :render,
    "#{File.cwd!()}/lib/ex_vespa/templates/schema.eex",
    [:schema]
  )

  def construct_struct_field(sf) do
    out = """
    struct-field #{sf.name} {
    }
    """

    EEx.eval_string(out, list: [sf])
  end
end
