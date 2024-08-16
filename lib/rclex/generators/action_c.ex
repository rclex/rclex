defmodule Rclex.Generators.ActionC do
  @moduledoc false

  alias Rclex.Generators.Util

  def generate(type) do
    EEx.eval_file(Path.join(Util.templates_dir_path(:action), "action_c.eex"),
      header_name: to_header_name(type),
      header_prefix: to_header_prefix(type),
      function_prefix: "nif_" <> Util.type_down_snake(type),
      rosidl_get_action_type_support: rosidl_get_action_type_support(type)
    )
  end

  def to_header_name(ros2_action_type) do
    [_interfaces, _interface_type, type] = ros2_action_type |> String.split("/")
    Util.to_down_snake(type)
  end

  def to_header_prefix(ros2_action_type) do
    [interfaces, interface_type, type] = ros2_action_type |> String.split("/")
    [interfaces, interface_type, Util.to_down_snake(type)] |> Path.join()
  end

  def rosidl_get_action_type_support(ros2_action_type) do
    [interfaces, "action", type] = ros2_action_type |> String.split("/")
    "ROSIDL_GET_ACTION_TYPE_SUPPORT(#{interfaces}, #{type})"
  end
end
