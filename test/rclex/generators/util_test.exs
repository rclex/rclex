defmodule Rclex.Generators.UtilTest do
  use ExUnit.Case
  doctest Rclex.Generators.Util

  alias Rclex.Generators.Util

  test "templates_dir_path/1" do
    assert Util.templates_dir_path() =~ "priv/templates/rclex.gen.msgs"
    assert Util.templates_dir_path(:msg) =~ "priv/templates/rclex.gen.msgs"
    assert Util.templates_dir_path(:srv) =~ "priv/templates/rclex.gen.srvs"

    assert_raise RuntimeError, "ros2 interface type not supported", fn ->
      Util.templates_dir_path(:unknown)
    end
  end

  test "type_down_snake/1" do
    assert "Ab_Cd_ef" = Util.type_down_snake("Ab/Cd/Ef")

    assert_raise MatchError, fn ->
      Util.type_down_snake("Ab/Cd/Ef/gH")
    end
  end

  test "to_down_snake/1" do
    assert "ab_cd_ef" = Util.to_down_snake("AbCdEf")
  end
end
