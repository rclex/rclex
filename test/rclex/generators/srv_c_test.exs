defmodule Rclex.Generators.SrvCTest do
  use ExUnit.Case
  doctest Rclex.Generators.SrvC

  alias Rclex.Generators.SrvC
  alias Rclex.Generators.Util

  for ros2_service_type <- [
        "std_srvs/srv/SetBool"
      ] do
    test "generate/2 #{ros2_service_type}" do
      ros2_service_type = unquote(ros2_service_type)

      [interfaces, msg, type] = String.split(ros2_service_type, "/")
      type_path = Enum.join([interfaces, msg, Util.to_down_snake(type)], "/")

      assert SrvC.generate(ros2_service_type) ==
               File.read!(Path.join(File.cwd!(), "test/expected_files/#{type_path}.c"))
    end
  end
end
