defmodule Mix.Tasks.Rclex.Gen.MsgsTest do
  use ExUnit.Case

  doctest Mix.Tasks.Rclex.Gen.Msgs

  alias Mix.Tasks.Rclex.Gen.Msgs, as: GenMsgs

  @ros2_message_type_map %{
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

  for type <- ["std_msgs/msg/String", "geometry_msgs/msg/Twist"] do
    @tag :skip
    test "generate_msg_prot/2, type:#{type}" do
      type = unquote(type)
      binary = File.read!("test/expected_files/#{String.downcase(type)}_impl.ex")
      assert binary == GenMsgs.generate_msg_prot(type, @ros2_message_type_map)
    end
  end

  for type <- ["std_msgs/msg/String", "geometry_msgs/msg/Vector3", "geometry_msgs/msg/Twist"] do
    @tag :skip
    test "generate_msg_mod/2, type:#{type}" do
      type = unquote(type)
      binary = File.read!("test/expected_files/#{String.downcase(type)}.ex")
      assert binary == GenMsgs.generate_msg_mod(type, @ros2_message_type_map)
    end
  end

  for type <- ["std_msgs/msg/String", "geometry_msgs/msg/Vector3", "geometry_msgs/msg/Twist"] do
    @tag :skip
    test "generate_msg_nif_c/2, type:#{type}" do
      type = unquote(type)
      binary = File.read!("test/expected_files/#{String.downcase(type)}_nif.c")
      assert binary == GenMsgs.generate_msg_nif_c(type, @ros2_message_type_map)
    end
  end

  for type <- ["std_msgs/msg/String", "geometry_msgs/msg/Vector3", "geometry_msgs/msg/Twist"] do
    @tag :skip
    test "generate_msg_nif_h/2, type:#{type}" do
      type = unquote(type)
      binary = File.read!("test/expected_files/#{String.downcase(type)}_nif.h")
      assert binary == GenMsgs.generate_msg_nif_h(type, @ros2_message_type_map)
    end
  end

  @tag :skip
  test "get_ros2_message_type_map/3" do
    assert Map.equal?(
             %{"std_msgs/msg/String" => [{"string", "data"}]},
             GenMsgs.get_ros2_message_type_map("std_msgs/msg/String", "/opt/ros/foxy/share")
           )

    assert Map.equal?(
             %{
               "geometry_msgs/msg/Vector3" => [
                 {"float64", "x"},
                 {"float64", "y"},
                 {"float64", "z"}
               ]
             },
             GenMsgs.get_ros2_message_type_map("geometry_msgs/msg/Vector3", "/opt/ros/foxy/share")
           )

    assert Map.equal?(
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
             },
             GenMsgs.get_ros2_message_type_map("geometry_msgs/msg/Twist", "/opt/ros/foxy/share")
           )
  end

  test "create_fields_for_set/2" do
    [
      {"std_msgs/msg/String", "data.data"},
      {"geometry_msgs/msg/Twist",
       "{data.linear.x, data.linear.y, data.linear.z}, " <>
         "{data.angular.x, data.angular.y, data.angular.z}"}
    ]
    |> Enum.map(fn {type, expected_fields} ->
      ros2_message_type_map = @ros2_message_type_map

      assert expected_fields ==
               GenMsgs.create_fields_for_nifs_setdata_arg(type, ros2_message_type_map)
    end)
  end

  test "create_fields_for_nifs_readdata_return/2" do
    [
      {"std_msgs/msg/String", "data_0"},
      {"geometry_msgs/msg/Twist",
       "{data_0_0, data_0_1, data_0_2}, {data_1_0, data_1_1, data_1_2}"}
    ]
    |> Enum.map(fn {type, expected_fields} ->
      ros2_message_type_map = @ros2_message_type_map

      assert expected_fields ==
               GenMsgs.create_fields_for_nifs_readdata_return(type, ros2_message_type_map)
    end)
  end

  test "create_fields_for_read/2" do
    [
      {"std_msgs/msg/String", "data: data_0"},
      {"geometry_msgs/msg/Twist",
       "linear: %Rclex.GeometryMsgs.Msg.Vector3{x: data_0_0, y: data_0_1, z: data_0_2}, " <>
         "angular: %Rclex.GeometryMsgs.Msg.Vector3{x: data_1_0, y: data_1_1, z: data_1_2}"}
    ]
    |> Enum.map(fn {type, expected_fields} ->
      ros2_message_type_map = @ros2_message_type_map
      assert expected_fields == GenMsgs.create_fields_for_read(type, ros2_message_type_map)
    end)
  end

  test "create_fields_for_defstruct/2" do
    [
      {"std_msgs/msg/String", "data: nil"},
      {"geometry_msgs/msg/Vector3", "x: nil, y: nil, z: nil"},
      {"geometry_msgs/msg/Twist",
       "linear: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}, " <>
         "angular: %Rclex.GeometryMsgs.Msg.Vector3{x: nil, y: nil, z: nil}"}
    ]
    |> Enum.map(fn {type, expected_fields} ->
      ros2_message_type_map = @ros2_message_type_map
      assert expected_fields == GenMsgs.create_fields_for_defstruct(type, ros2_message_type_map)
    end)
  end

  test "create_readdata_statements/1" do
    ["std_msgs/msg/String", "geometry_msgs/msg/Vector3", "geometry_msgs/msg/Twist"]
    |> Enum.map(fn type ->
      expected = File.read!("test/expected_files/#{String.downcase(type)}_readdata_function.txt")
      ros2_message_type_map = @ros2_message_type_map

      assert expected == GenMsgs.create_readdata_statements(type, ros2_message_type_map)
    end)
  end

  test "create_setdata_statements/1" do
    ["std_msgs/msg/String", "geometry_msgs/msg/Vector3", "geometry_msgs/msg/Twist"]
    |> Enum.map(fn type ->
      expected = File.read!("test/expected_files/#{String.downcase(type)}_setdata_function.txt")
      ros2_message_type_map = @ros2_message_type_map

      assert expected == GenMsgs.create_setdata_statements(type, ros2_message_type_map)
    end)
  end
end
