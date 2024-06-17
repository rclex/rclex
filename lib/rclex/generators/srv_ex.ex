defmodule Rclex.Generators.SrvEx do
  @moduledoc false

  alias Rclex.Generators.Util

  def generate(type) do
    EEx.eval_file(Path.join(Util.templates_dir_path(:srv), "srv_ex.eex"),
      module_name: module_name(type),
      function_prefix: Util.type_down_snake(type)
    )
  end

  @doc """
  iex> Rclex.Generators.SrvEx.module_name("std_srvs/srv/SetBool")
  "StdSrvs.Srv.SetBool"
  """
  def module_name(ros2_service_type) do
    [pkg, srv = "srv", type] = String.split(ros2_service_type, "/")

    pkg =
      pkg
      |> String.replace("/", "_")
      |> String.split("_")
      |> Enum.map_join(&String.capitalize(&1))

    Enum.join([pkg, String.capitalize(srv), type], ".")
  end
end
