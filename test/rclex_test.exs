defmodule RclexTest do
  use ExUnit.Case

  # -----------------------node_nif.c--------------------------
  test "rcl_node_get_name" do
    context = Rclex.rclexinit()

    node_name = 'test_node'
    node_list = Rclex.create_nodes(context, node_name, 2)
    [node_1, node_2] = node_list

    assert Rclex.rcl_node_get_name(node_1) == 'test_node1', 'first node name is test_node1'
    assert Rclex.rcl_node_get_name(node_2) == 'test_node2', 'second node name is test_node2'

    Rclex.node_finish(node_list)
  end

  # -----------------------graph_nif.c--------------------------
  test "rcl_get_topic_names_and_types" do
    context = Rclex.rclexinit()
    node_list = Rclex.create_nodes(context, 'test_pub_node', 1)

    publisher_list = Rclex.create_publishers(node_list, 'testtopic', :single)
    node_list_2 = Rclex.create_nodes(context, 'test_sub_node', 1)
    subscriber_list = Rclex.create_subscribers(node_list_2, 'testtopic', :single)
    node = hd(node_list)

    names_and_types_tuple_list =
      Rclex.rcl_get_topic_names_and_types(node, Rclex.rcl_get_default_allocator(), false)

    [name_and_types_tuple_1 | [name_and_types_tuple_2]] = names_and_types_tuple_list

    name_1 = elem(name_and_types_tuple_1, 0)
    types_list_1 = elem(name_and_types_tuple_1, 1)

    assert name_1 == '/rosout', 'first topic name is rosout'
    type_1 = hd(types_list_1)
    assert type_1 == 'rcl_interfaces/msg/Log', 'first topic type is rcl_interfaces/msg/Log'

    name_2 = elem(name_and_types_tuple_2, 0)
    types_list_2 = elem(name_and_types_tuple_2, 1)

    assert name_2 == '/testtopic', 'second topic name is testtopic'
    type_2 = hd(types_list_2)
    assert type_2 == 'std_msgs/msg/String', 'second topic type is std_msgs/msg/String'

    Rclex.publisher_finish(publisher_list, node_list)
    Rclex.subscriber_finish(subscriber_list, node_list_2)
    Rclex.node_finish(node_list)
    Rclex.node_finish(node_list_2)
  end
end
