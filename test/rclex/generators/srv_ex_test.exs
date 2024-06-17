defmodule Rclex.Generators.SrvExTest do
  use ExUnit.Case
  doctest Rclex.Generators.SrvEx

  alias Rclex.Generators.SrvEx
  alias Rclex.Generators.Util

  for ros2_service_type <- [
        "std_srvs/srv/SetBool"
      ] do
    test "generate/2 #{ros2_service_type}" do
      ros2_service_type = unquote(ros2_service_type)

      [interfaces, msg, type] = String.split(ros2_service_type, "/")
      type_path = Enum.join([interfaces, msg, Util.to_down_snake(type)], "/")

      assert SrvEx.generate(ros2_service_type) ==
               File.read!(Path.join(File.cwd!(), "test/expected_files/#{type_path}.ex"))
    end
  end
end
