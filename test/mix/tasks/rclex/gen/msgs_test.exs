defmodule Mix.Tasks.Rclex.Gen.MsgsTest do
  use ExUnit.Case

  doctest Mix.Tasks.Rclex.Gen.Msgs

  alias Mix.Tasks.Rclex.Gen.Msgs, as: GenMsgs

  @msg_mod File.read!("test/expected_files/std_msgs/string.ex")
  @msg_nif_h File.read!("test/expected_files/std_msgs/string_nif.h")

  test "generate_msg_mod/0" do
    assert @msg_mod = GenMsgs.generate_msg_mod()
  end

  test "generate_msg_nif_h/0" do
    assert @msg_nif_h = GenMsgs.generate_msg_nif_h()
  end

  test "get_type_variable_tuples/2" do
    assert [{"string", "data"}] ==
             GenMsgs.get_type_variable_tuples("std_msgs/String", "/opt/ros/foxy/share")

    assert [{"geometry_msgs/Vector3", "linear"}, {"geometry_msgs/Vector3", "angular"}] ==
             GenMsgs.get_type_variable_tuples("geometry_msgs/Twist", "/opt/ros/foxy/share")

    assert [{"float64", "x"}, {"float64", "y"}, {"float64", "z"}] ==
             GenMsgs.get_type_variable_tuples("geometry_msgs/Vector3", "/opt/ros/foxy/share")
  end

  test "create_fields/2" do
    from = "/opt/ros/foxy/share"

    assert "data: nil" == GenMsgs.create_fields("std_msgs/String", from)

    assert "x: nil, y: nil, z: nil" == GenMsgs.create_fields("geometry_msgs/Vector3", from)

    assert "x: nil, y: nil, z: nil, w: nil" ==
             GenMsgs.create_fields("geometry_msgs/Quaternion", from)

    assert "linear: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}, " <>
             "angular: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}" ==
             GenMsgs.create_fields("geometry_msgs/Twist", from)
  end

  test "create_struct_type/2" do
    from = "/opt/ros/foxy/share"

    assert "%Rclex.StdMsgs.Msg.String{data: [integer]}" =
             GenMsgs.create_struct_type("std_msgs/String", from)

    assert "%Rclex.GeometryMsgs.Msg.Twist{" <>
             "linear: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}, " <>
             "angular: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}}" ==
             GenMsgs.create_struct_type("geometry_msgs/Twist", from)
  end
end
