defmodule Mix.Tasks.Rclex.Gen.MsgsTest do
  use ExUnit.Case

  doctest Mix.Tasks.Rclex.Gen.Msgs

  alias Mix.Tasks.Rclex.Gen.Msgs, as: GenMsgs

  @ros2_message_type_map %{
    "geometry_msgs/msg/TwistWithCovariance" => [
      {"geometry_msgs/msg/Twist", "twist"},
      {"float64[36]", "covariance"}
    ],
    "geometry_msgs/msg/Twist" => [
      {"geometry_msgs/msg/Vector3", "linear"},
      {"geometry_msgs/msg/Vector3", "angular"}
    ],
    "geometry_msgs/msg/Vector3" => [
      {"float64", "x"},
      {"float64", "y"},
      {"float64", "z"}
    ],
    "std_msgs/msg/String" => [{"string", "data"}]
  }

  for type <- [
        "std_msgs/msg/String",
        "geometry_msgs/msg/Twist",
        "geometry_msgs/msg/TwistWithCovariance"
      ] do
    @tag :skip
    test "generate_msg_prot/2, type: #{type}" do
      type = unquote(type)
      binary = File.read!("test/expected_files/#{GenMsgs.get_file_name_from_type(type)}_impl.ex")
      assert binary == GenMsgs.generate_msg_prot(type, @ros2_message_type_map)
    end
  end

  for type <- [
        "std_msgs/msg/String",
        "geometry_msgs/msg/Vector3",
        "geometry_msgs/msg/Twist",
        "geometry_msgs/msg/TwistWithCovariance"
      ] do
    @tag :skip
    test "generate_msg_mod/2, type: #{type}" do
      type = unquote(type)
      binary = File.read!("test/expected_files/#{GenMsgs.get_file_name_from_type(type)}.ex")
      assert binary == GenMsgs.generate_msg_mod(type, @ros2_message_type_map)
    end
  end

  for type <- [
        "std_msgs/msg/String",
        "geometry_msgs/msg/Vector3",
        "geometry_msgs/msg/Twist",
        "geometry_msgs/msg/TwistWithCovariance"
      ] do
    @tag :skip
    test "generate_msg_nif_c/2, type: #{type}" do
      type = unquote(type)
      binary = File.read!("test/expected_files/#{GenMsgs.get_file_name_from_type(type)}_nif.c")
      assert binary == GenMsgs.generate_msg_nif_c(type, @ros2_message_type_map)
    end
  end

  for type <- [
        "std_msgs/msg/String",
        "geometry_msgs/msg/Vector3",
        "geometry_msgs/msg/Twist",
        "geometry_msgs/msg/TwistWithCovariance"
      ] do
    @tag :skip
    test "generate_msg_nif_h/2, type: #{type}" do
      type = unquote(type)
      binary = File.read!("test/expected_files/#{GenMsgs.get_file_name_from_type(type)}_nif.h")
      assert binary == GenMsgs.generate_msg_nif_h(type, @ros2_message_type_map)
    end
  end

  for {type, expected_map} <- [
        {"std_msgs/msg/String", %{"std_msgs/msg/String" => [{"string", "data"}]}},
        {"geometry_msgs/msg/Vector3",
         %{
           "geometry_msgs/msg/Vector3" => [
             {"float64", "x"},
             {"float64", "y"},
             {"float64", "z"}
           ]
         }},
        {"geometry_msgs/msg/Twist",
         %{
           "geometry_msgs/msg/Twist" => [
             {"geometry_msgs/msg/Vector3", "linear"},
             {"geometry_msgs/msg/Vector3", "angular"}
           ],
           "geometry_msgs/msg/Vector3" => [
             {"float64", "x"},
             {"float64", "y"},
             {"float64", "z"}
           ]
         }},
        {"geometry_msgs/msg/TwistWithCovariance",
         %{
           "geometry_msgs/msg/TwistWithCovariance" => [
             {"geometry_msgs/msg/Twist", "twist"},
             {"float64[36]", "covariance"}
           ],
           "geometry_msgs/msg/Twist" => [
             {"geometry_msgs/msg/Vector3", "linear"},
             {"geometry_msgs/msg/Vector3", "angular"}
           ],
           "geometry_msgs/msg/Vector3" => [
             {"float64", "x"},
             {"float64", "y"},
             {"float64", "z"}
           ]
         }}
      ] do
    test "get_ros2_message_type_map/3, type: #{type}" do
      type = unquote(type)
      expected_map = unquote(Macro.escape(expected_map))

      ros_distro = System.get_env("ROS_DISTRO")

      if not is_nil(ros_distro) do
        assert Map.equal?(
                 expected_map,
                 GenMsgs.get_ros2_message_type_map(type, "/opt/ros/#{ros_distro}/share")
               )
      end
    end
  end

  for {type, expected_fields} <- [
        {"std_msgs/msg/String", "data.data"},
        {"geometry_msgs/msg/Twist",
         "{data.linear.x, data.linear.y, data.linear.z}, " <>
           "{data.angular.x, data.angular.y, data.angular.z}"},
        {"geometry_msgs/msg/TwistWithCovariance",
         "{{data.twist.linear.x, data.twist.linear.y, data.twist.linear.z}, " <>
           "{data.twist.angular.x, data.twist.angular.y, data.twist.angular.z}}, data.covariance"}
      ] do
    test "create_fields_for_set/2, type: #{type}" do
      type = unquote(type)
      expected_fields = unquote(expected_fields)

      assert expected_fields ==
               GenMsgs.create_fields_for_nifs_setdata_arg(type, @ros2_message_type_map)
    end
  end

  for {type, expected_fields} <- [
        {"std_msgs/msg/String", "data_0"},
        {"geometry_msgs/msg/Twist",
         "{data_0_0, data_0_1, data_0_2}, {data_1_0, data_1_1, data_1_2}"},
        {"geometry_msgs/msg/TwistWithCovariance",
         "{{data_0_0_0, data_0_0_1, data_0_0_2}, {data_0_1_0, data_0_1_1, data_0_1_2}}, data_1"}
      ] do
    test "create_fields_for_nifs_readdata_return/2, type: #{type}" do
      type = unquote(type)
      expected_fields = unquote(expected_fields)

      assert expected_fields ==
               GenMsgs.create_fields_for_nifs_readdata_return(type, @ros2_message_type_map)
    end
  end

  for {type, expected_fields} <- [
        {"std_msgs/msg/String", "data: data_0"},
        {"geometry_msgs/msg/Twist",
         "linear: %Rclex.GeometryMsgs.Msg.Vector3{x: data_0_0, y: data_0_1, z: data_0_2}, " <>
           "angular: %Rclex.GeometryMsgs.Msg.Vector3{x: data_1_0, y: data_1_1, z: data_1_2}"},
        {"geometry_msgs/msg/TwistWithCovariance",
         "twist: %Rclex.GeometryMsgs.Msg.Twist{" <>
           "linear: %Rclex.GeometryMsgs.Msg.Vector3{x: data_0_0_0, y: data_0_0_1, z: data_0_0_2}, " <>
           "angular: %Rclex.GeometryMsgs.Msg.Vector3{x: data_0_1_0, y: data_0_1_1, z: data_0_1_2}}, " <>
           "covariance: data_1"}
      ] do
    test "create_fields_for_read/2, type: #{type}" do
      type = unquote(type)
      expected_fields = unquote(expected_fields)

      assert expected_fields == GenMsgs.create_fields_for_read(type, @ros2_message_type_map)
    end
  end

  for {type, expected_fields} <- [
        {"std_msgs/msg/String", "data: nil"},
        {"geometry_msgs/msg/Vector3", "x: nil, y: nil, z: nil"},
        {"geometry_msgs/msg/Twist",
         "linear: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}, " <>
           "angular: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}"},
        {"geometry_msgs/msg/TwistWithCovariance",
         "twist: %Rclex.GeometryMsgs.Msg.Twist{" <>
           "linear: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}, " <>
           "angular: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}}, " <>
           "covariance: nil"}
      ] do
    test "create_fields_for_defstruct/2, type: #{type}" do
      type = unquote(type)
      expected_fields = unquote(expected_fields)

      assert expected_fields == GenMsgs.create_fields_for_defstruct(type, @ros2_message_type_map)
    end
  end

  for {type, expected_fields} <- [
        {"std_msgs/msg/String", "data: [integer]"},
        {"geometry_msgs/msg/Vector3", "x: float, y: float, z: float"},
        {"geometry_msgs/msg/Twist",
         "linear: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}, " <>
           "angular: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}"},
        {"geometry_msgs/msg/TwistWithCovariance",
         "twist: %Rclex.GeometryMsgs.Msg.Twist{" <>
           "linear: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}, " <>
           "angular: %Rclex.GeometryMsgs.Msg.Vector3{x: float, y: float, z: float}}, " <>
           "covariance: [float]"}
      ] do
    test "create_fields_for_type/2, type: #{type}" do
      type = unquote(type)
      expected_fields = unquote(expected_fields)

      assert expected_fields == GenMsgs.create_fields_for_type(type, @ros2_message_type_map)
    end
  end

  for type <- [
        "std_msgs/msg/String",
        "geometry_msgs/msg/Vector3",
        "geometry_msgs/msg/Twist",
        "geometry_msgs/msg/TwistWithCovariance"
      ] do
    test "create_readdata_statements/1, type: #{type}" do
      type = unquote(type)

      expected =
        File.read!(
          "test/expected_files/#{GenMsgs.get_file_name_from_type(type)}_readdata_function.txt"
        )

      assert expected == GenMsgs.create_readdata_statements(type, @ros2_message_type_map)
    end
  end

  for type <- [
        "std_msgs/msg/String",
        "geometry_msgs/msg/Vector3",
        "geometry_msgs/msg/Twist",
        "geometry_msgs/msg/TwistWithCovariance"
      ] do
    test "create_setdata_statements/1, type: #{type}" do
      type = unquote(type)

      expected =
        File.read!(
          "test/expected_files/#{GenMsgs.get_file_name_from_type(type)}_setdata_function.txt"
        )

      assert expected == GenMsgs.create_setdata_statements(type, @ros2_message_type_map)
    end
  end
end
