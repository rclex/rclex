defmodule Rclex.Generators.MsgExTest do
  use ExUnit.Case
  doctest Rclex.Generators.MsgEx

  with ros_distro <- System.get_env("ROS_DISTRO"),
       true <- File.exists?("/opt/ros/#{ros_distro}") do
    @ros_share_path "/opt/ros/#{ros_distro}/share"
  else
    _ ->
      @moduletag :skip
  end

  alias Mix.Tasks.Rclex.Gen.Msgs
  alias Rclex.Generators.MsgEx
  alias Rclex.Generators.Util

  for ros2_message_type <- [
        "sensor_msgs/msg/PointCloud",
        "std_msgs/msg/Empty",
        "std_msgs/msg/String",
        "std_msgs/msg/MultiArrayLayout",
        "std_msgs/msg/UInt32MultiArray",
        "geometry_msgs/msg/Vector3",
        "geometry_msgs/msg/Twist"
      ] do
    test "generate/2 #{ros2_message_type}" do
      ros2_message_type = unquote(ros2_message_type)
      ros2_message_type_map = Msgs.get_ros2_message_type_map(ros2_message_type, @ros_share_path)

      [interfaces, msg, type] = String.split(ros2_message_type, "/")
      type_path = Enum.join([interfaces, msg, Util.to_down_snake(type)], "/")

      binary = MsgEx.generate(ros2_message_type, ros2_message_type_map)

      assert "#{binary}" ==
               File.read!(Path.join(File.cwd!(), "test/expected_files/#{type_path}.ex"))
    end
  end

  describe "fields functions," do
    setup do
      %{
        ros2_message_type_map:
          Enum.reduce(
            [
              "std_msgs/msg/Empty",
              "std_msgs/msg/String",
              "std_msgs/msg/MultiArrayLayout",
              "std_msgs/msg/UInt32MultiArray",
              "geometry_msgs/msg/Vector3",
              "geometry_msgs/msg/Twist"
            ],
            %{},
            fn type, acc ->
              Msgs.get_ros2_message_type_map(type, @ros_share_path, acc)
            end
          )
      }
    end

    for {ros2_message_type, expected} <- [
          {"std_msgs/msg/Empty", "[]"},
          {"std_msgs/msg/String", "data: nil"},
          {"std_msgs/msg/MultiArrayDimension", "label: nil,\nsize: nil,\nstride: nil"},
          {"std_msgs/msg/MultiArrayLayout", "dim: [],\ndata_offset: nil"},
          {"std_msgs/msg/UInt32MultiArray",
           "layout: %Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout{},\ndata: []"},
          {"geometry_msgs/msg/Vector3", "x: nil,\ny: nil,\nz: nil"},
          {"geometry_msgs/msg/Twist",
           "linear: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{},\nangular: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{}"}
        ] do
      test "defstruct_fields/2, #{ros2_message_type}", %{
        ros2_message_type_map: ros2_message_type_map
      } do
        fields = MsgEx.defstruct_fields(unquote(ros2_message_type), ros2_message_type_map)

        assert fields == "defstruct #{unquote(expected)}"
      end
    end

    for {ros2_message_type, expected} <- [
          {"std_msgs/msg/Empty", ""},
          {"std_msgs/msg/String", "data: String.t()"},
          {"std_msgs/msg/MultiArrayDimension",
           "label: String.t(),\nsize: non_neg_integer(),\nstride: non_neg_integer()"},
          {"std_msgs/msg/MultiArrayLayout",
           "dim: list(%Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension{}),\ndata_offset: non_neg_integer()"},
          {"std_msgs/msg/UInt32MultiArray",
           "layout: %Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout{},\ndata: list(non_neg_integer())"},
          {"geometry_msgs/msg/Vector3", "x: float(),\ny: float(),\nz: float()"},
          {"geometry_msgs/msg/Twist",
           "linear: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{},\nangular: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{}"}
        ] do
      test "type_fields/2, #{ros2_message_type}", %{ros2_message_type_map: ros2_message_type_map} do
        fields = MsgEx.type_fields(unquote(ros2_message_type), ros2_message_type_map)

        assert fields == "@type t :: %__MODULE__{#{unquote(expected)}}"
      end
    end

    for {ros2_message_type, expected} <- [
          {"std_msgs/msg/Empty", ""},
          {"std_msgs/msg/String", "data: data"},
          {"std_msgs/msg/MultiArrayDimension", "label: label, size: size, stride: stride"},
          {"std_msgs/msg/MultiArrayLayout", "dim: dim, data_offset: data_offset"},
          {"std_msgs/msg/UInt32MultiArray", "layout: layout, data: data"},
          {"geometry_msgs/msg/Vector3", "x: x, y: y, z: z"},
          {"geometry_msgs/msg/Twist", "linear: linear, angular: angular"}
        ] do
      test "to_tuple_args_fields/2, #{ros2_message_type}", %{
        ros2_message_type_map: ros2_message_type_map
      } do
        assert MsgEx.to_tuple_args_fields(unquote(ros2_message_type), ros2_message_type_map) ==
                 unquote(expected)
      end
    end

    for {ros2_message_type, expected} <- [
          {"std_msgs/msg/Empty", ""},
          {"std_msgs/msg/String", "data"},
          {"std_msgs/msg/MultiArrayDimension", "label, size, stride"},
          {"std_msgs/msg/MultiArrayLayout", "dim, data_offset"},
          {"std_msgs/msg/UInt32MultiArray", "layout, data"},
          {"geometry_msgs/msg/Vector3", "x, y, z"},
          {"geometry_msgs/msg/Twist", "linear, angular"}
        ] do
      test "to_struct_args_fields/2, #{ros2_message_type}", %{
        ros2_message_type_map: ros2_message_type_map
      } do
        assert MsgEx.to_struct_args_fields(unquote(ros2_message_type), ros2_message_type_map) ==
                 unquote(expected)
      end
    end

    for {ros2_message_type, expected} <- [
          {"std_msgs/msg/Empty", ""},
          {"std_msgs/msg/String", "~c\"\#{data}\""},
          {"std_msgs/msg/MultiArrayDimension", "~c\"\#{label}\",\nsize,\nstride"},
          {"std_msgs/msg/MultiArrayLayout",
           "for struct <- dim do\n  Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension.to_tuple(struct)\nend,\ndata_offset"},
          {"std_msgs/msg/UInt32MultiArray",
           "Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout.to_tuple(layout),\ndata"},
          {"geometry_msgs/msg/Vector3", "x,\ny,\nz"},
          {"geometry_msgs/msg/Twist",
           "Rclex.Pkgs.GeometryMsgs.Msg.Vector3.to_tuple(linear),\nRclex.Pkgs.GeometryMsgs.Msg.Vector3.to_tuple(angular)"}
        ] do
      test "to_tuple_return_fields/2, #{ros2_message_type}", %{
        ros2_message_type_map: ros2_message_type_map
      } do
        fields = MsgEx.to_tuple_return_fields(unquote(ros2_message_type), ros2_message_type_map)

        assert fields == "{#{unquote(expected)}}"
      end
    end

    for {ros2_message_type, expected} <- [
          {"std_msgs/msg/Empty", ""},
          {"std_msgs/msg/String", "data: \"\#{data}\""},
          {"std_msgs/msg/MultiArrayDimension",
           "label: \"\#{label}\",\nsize: size,\nstride: stride"},
          {"std_msgs/msg/MultiArrayLayout",
           "dim:\n  for tuple <- dim do\n    Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension.to_struct(tuple)\n  end,\ndata_offset: data_offset"},
          {"std_msgs/msg/UInt32MultiArray",
           "layout: Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout.to_struct(layout),\ndata: data"},
          {"geometry_msgs/msg/Vector3", "x: x,\ny: y,\nz: z"},
          {"geometry_msgs/msg/Twist",
           "linear: Rclex.Pkgs.GeometryMsgs.Msg.Vector3.to_struct(linear),\nangular: Rclex.Pkgs.GeometryMsgs.Msg.Vector3.to_struct(angular)"}
        ] do
      test "to_struct_return_fields/2, #{ros2_message_type}", %{
        ros2_message_type_map: ros2_message_type_map
      } do
        fields = MsgEx.to_struct_return_fields(unquote(ros2_message_type), ros2_message_type_map)

        assert fields == "%__MODULE__{#{unquote(expected)}}"
      end
    end
  end
end
