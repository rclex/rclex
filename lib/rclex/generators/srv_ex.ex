defmodule Rclex.Generators.SrvEx do
  @moduledoc false

  alias Rclex.Generators.Util

  def generate(type) do
    EEx.eval_file(Path.join(Util.templates_dir_path(:srv), "srv_ex.eex"),
      module_name: Util.module_name(type),
      function_prefix: Util.type_down_snake(type)
    )
  end
end
