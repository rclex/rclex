defmodule Mix.Tasks.Rclex.Gen.MsgsTest do
  use ExUnit.Case
  doctest Mix.Tasks.Rclex.Gen.Msgs

  with ros_distro <- System.get_env("ROS_DISTRO"),
       true <- File.exists?("/opt/ros/#{ros_distro}") do
    @ros_share_path "/opt/ros/#{ros_distro}/share"
  else
    _ ->
      @moduletag :skip
  end

  alias Mix.Tasks.Rclex.Gen.Msgs

  describe "get_ros2_message_type_map/2" do
    for {type, expected} <-
          Macro.escape([
            {"std_msgs/msg/String",
             %{"std_msgs/msg/String" => [[{:built_in_type, "string"}, "data"]]}},
            {"geometry_msgs/msg/Vector3",
             %{
               "geometry_msgs/msg/Vector3" => [
                 [{:built_in_type, "float64"}, "x"],
                 [{:built_in_type, "float64"}, "y"],
                 [{:built_in_type, "float64"}, "z"]
               ]
             }},
            {"geometry_msgs/msg/Twist",
             %{
               "geometry_msgs/msg/Twist" => [
                 [{:msg_type, "geometry_msgs/msg/Vector3"}, "linear"],
                 [{:msg_type, "geometry_msgs/msg/Vector3"}, "angular"]
               ],
               "geometry_msgs/msg/Vector3" => [
                 [{:built_in_type, "float64"}, "x"],
                 [{:built_in_type, "float64"}, "y"],
                 [{:built_in_type, "float64"}, "z"]
               ]
             }}
          ]) do
      test "#{type}" do
        type = unquote(type)
        expected = unquote(expected)

        type_map = Msgs.get_ros2_message_type_map(type, @ros_share_path)
        assert type_map == expected
      end
    end
  end

  describe "fields functions," do
    setup do
      %{
        ros2_message_type_map:
          Enum.reduce(
            [
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
          {"std_msgs/msg/String", "data: nil"},
          {"std_msgs/msg/MultiArrayDimension", "label: nil, size: nil, stride: nil"},
          {"std_msgs/msg/MultiArrayLayout", "dim: [], data_offset: nil"},
          {"std_msgs/msg/UInt32MultiArray",
           "layout: %Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout{}, data: []"},
          {"geometry_msgs/msg/Vector3", "x: nil, y: nil, z: nil"},
          {"geometry_msgs/msg/Twist",
           "linear: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{}, angular: %Rclex.Pkgs.GeometryMsgs.Msg.Vector3{}"}
        ] do
      test "defstruct_fields/2, #{ros2_message_type}", %{
        ros2_message_type_map: ros2_message_type_map
      } do
        assert Msgs.defstruct_fields(unquote(ros2_message_type), ros2_message_type_map) ==
                 unquote(expected)
      end
    end

    for {ros2_message_type, expected} <- [
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
        fields =
          Msgs.type_fields(unquote(ros2_message_type), ros2_message_type_map)
          |> remove_indent(10)

        assert fields == unquote(expected)
      end
    end

    for {ros2_message_type, expected} <- [
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
        assert Msgs.to_tuple_args_fields(unquote(ros2_message_type), ros2_message_type_map) ==
                 unquote(expected)
      end
    end

    for {ros2_message_type, expected} <- [
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
        assert Msgs.to_struct_args_fields(unquote(ros2_message_type), ros2_message_type_map) ==
                 unquote(expected)
      end
    end

    for {ros2_message_type, expected} <- [
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
        fields =
          Msgs.to_tuple_return_fields(unquote(ros2_message_type), ros2_message_type_map)
          |> remove_indent(6)

        assert fields == unquote(expected)
      end
    end

    for {ros2_message_type, expected} <- [
          {"std_msgs/msg/String", "data: \"\#{data}\""},
          {"std_msgs/msg/MultiArrayDimension",
           "label: \"\#{label}\",\nsize: size,\nstride: stride"},
          {"std_msgs/msg/MultiArrayLayout",
           "dim:\n  for tuple <- dim do\n    Rclex.Pkgs.StdMsgs.Msg.MultiArrayDimension.to_tuple(tuple)\n  end,\ndata_offset: data_offset"},
          {"std_msgs/msg/UInt32MultiArray",
           "layout: Rclex.Pkgs.StdMsgs.Msg.MultiArrayLayout.to_struct(layout),\ndata: data"},
          {"geometry_msgs/msg/Vector3", "x: x,\ny: y,\nz: z"},
          {"geometry_msgs/msg/Twist",
           "linear: Rclex.Pkgs.GeometryMsgs.Msg.Vector3.to_struct(linear),\nangular: Rclex.Pkgs.GeometryMsgs.Msg.Vector3.to_struct(angular)"}
        ] do
      test "to_struct_return_fields/2, #{ros2_message_type}", %{
        ros2_message_type_map: ros2_message_type_map
      } do
        fields =
          Msgs.to_struct_return_fields(unquote(ros2_message_type), ros2_message_type_map)
          |> remove_indent(6)

        assert fields == unquote(expected)
      end
    end

    defp remove_indent(fields, size) do
      indent = String.duplicate(" ", size)

      fields
      |> String.split("\n")
      |> Enum.map_join("\n", &String.replace_prefix(&1, indent, ""))
    end
  end
end
