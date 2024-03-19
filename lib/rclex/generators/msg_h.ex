defmodule Rclex.Generators.MsgH do
  @moduledoc false

  alias Rclex.Generators.Util

  def generate(type, _ros2_message_type_map) do
    EEx.eval_file(Path.join(Util.templates_dir_path(), "msg_h.eex"),
      function_prefix: "nif_" <> Util.type_down_snake(type)
    )
  end
end
