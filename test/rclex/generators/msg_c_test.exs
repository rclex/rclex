defmodule Rclex.Generators.MsgCTest do
  use ExUnit.Case
  doctest Rclex.Generators.MsgC

  with ros_distro <- System.get_env("ROS_DISTRO"),
       true <- File.exists?("/opt/ros/#{ros_distro}") do
    @ros_share_path "/opt/ros/#{ros_distro}/share"
  else
    _ ->
      @moduletag :skip
  end

  alias Mix.Tasks.Rclex.Gen.Msgs
  alias Rclex.Generators.MsgC
  alias Rclex.Generators.Util

  for ros2_message_type <- [
        "sensor_msgs/msg/PointCloud",
        "std_msgs/msg/String",
        "std_msgs/msg/MultiArrayDimension",
        "std_msgs/msg/MultiArrayLayout",
        "std_msgs/msg/UInt32MultiArray",
        "geometry_msgs/msg/Vector3",
        "geometry_msgs/msg/Twist"
      ] do
    test "get_fun_fragments/2 #{ros2_message_type}" do
      ros2_message_type = unquote(ros2_message_type)
      ros2_message_type_map = Msgs.get_ros2_message_type_map(ros2_message_type, @ros_share_path)

      [interfaces, msg, type] = String.split(ros2_message_type, "/")
      type_path = Enum.join([interfaces, msg, Util.to_down_snake(type)], "/")

      assert MsgC.get_fun_fragments(ros2_message_type, ros2_message_type_map) ==
               File.read!(Path.join(File.cwd!(), "test/expected_files/#{type_path}_get_fun.txt"))
    end
  end

  for ros2_message_type <- [
        "sensor_msgs/msg/PointCloud",
        "std_msgs/msg/String",
        "std_msgs/msg/MultiArrayDimension",
        "std_msgs/msg/MultiArrayLayout",
        "std_msgs/msg/UInt32MultiArray",
        "geometry_msgs/msg/Vector3",
        "geometry_msgs/msg/Twist"
      ] do
    test "set_fun_fragments/2 #{ros2_message_type}" do
      ros2_message_type = unquote(ros2_message_type)
      ros2_message_type_map = Msgs.get_ros2_message_type_map(ros2_message_type, @ros_share_path)

      [interfaces, msg, type] = String.split(ros2_message_type, "/")
      type_path = Enum.join([interfaces, msg, Util.to_down_snake(type)], "/")

      assert MsgC.set_fun_fragments(ros2_message_type, ros2_message_type_map) ==
               File.read!(Path.join(File.cwd!(), "test/expected_files/#{type_path}_set_fun.txt"))
    end
  end
end
