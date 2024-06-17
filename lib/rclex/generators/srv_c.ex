defmodule Rclex.Generators.SrvC do
  @moduledoc false

  alias Rclex.Generators.Util

  def generate(type) do
    EEx.eval_file(Path.join(Util.templates_dir_path(:srv), "srv_c.eex"),
      header_name: to_header_name(type),
      header_prefix: to_header_prefix(type),
      function_prefix: "nif_" <> Util.type_down_snake(type),
      rosidl_get_srv_type_support: rosidl_get_srv_type_support(type)
    )
  end

  def to_header_name(ros2_service_type) do
    [_interfaces, "srv", type] = ros2_service_type |> String.split("/")
    Util.to_down_snake(type)
  end

  def to_header_prefix(ros2_service_type) do
    [interfaces, "srv", type] = ros2_service_type |> String.split("/")
    [interfaces, "srv", Util.to_down_snake(type)] |> Path.join()
  end

  def rosidl_get_srv_type_support(ros2_service_type) do
    [interfaces, "srv", type] = ros2_service_type |> String.split("/")
    "ROSIDL_GET_SRV_TYPE_SUPPORT(#{interfaces}, srv, #{type})"
  end
end
