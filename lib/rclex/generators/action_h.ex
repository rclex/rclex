defmodule Rclex.Generators.ActionH do
  @moduledoc false

  alias Rclex.Generators.Util

  def generate(type) do
    EEx.eval_file(Path.join(Util.templates_dir_path(:action), "action_h.eex"),
      function_prefix: "nif_" <> Util.type_down_snake(type)
    )
  end
end
