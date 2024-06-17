defmodule Rclex.Generators.SrvH do
  @moduledoc false

  alias Rclex.Generators.Util

  def generate(type) do
    EEx.eval_file(Path.join(Util.templates_dir_path(:srv), "srv_h.eex"),
      function_prefix: "nif_" <> Util.type_down_snake(type)
    )
  end
end
