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
             %{{:msg_type, "std_msgs/msg/String"} => [[{:builtin_type, "string"}, "data"]]}},
            {"geometry_msgs/msg/Vector3",
             %{
               {:msg_type, "geometry_msgs/msg/Vector3"} => [
                 [{:builtin_type, "float64"}, "x"],
                 [{:builtin_type, "float64"}, "y"],
                 [{:builtin_type, "float64"}, "z"]
               ]
             }},
            {"geometry_msgs/msg/Twist",
             %{
               {:msg_type, "geometry_msgs/msg/Twist"} => [
                 [{:msg_type, "geometry_msgs/msg/Vector3"}, "linear"],
                 [{:msg_type, "geometry_msgs/msg/Vector3"}, "angular"]
               ],
               {:msg_type, "geometry_msgs/msg/Vector3"} => [
                 [{:builtin_type, "float64"}, "x"],
                 [{:builtin_type, "float64"}, "y"],
                 [{:builtin_type, "float64"}, "z"]
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
end
