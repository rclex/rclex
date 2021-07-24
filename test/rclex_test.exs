defmodule RclexTest do
  use ExUnit.Case
  doctest Rclex

  # -----------------------node_nif.c--------------------------
  test "rcl_node_get_name" do
    context = Rclex.rclexinit()

    node_name = 'test_node'
    node_list = Rclex.create_nodes(context, node_name, 2)
    [node_1, node_2] = node_list

    assert Rclex.node_get_name(node_1) == 'test_node1', 'first node name is test_node1'
    assert Rclex.node_get_name(node_2) == 'test_node2', 'second node name is test_node2'

    Rclex.node_finish(node_list)
    Rclex.shutdown(context)
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
      Rclex.get_topic_names_and_types(
        node,
        Rclex.get_default_allocator(),
        false
      )

    name_and_types_tuple = List.last(names_and_types_tuple_list)

    name = elem(name_and_types_tuple, 0)
    types_list = elem(name_and_types_tuple, 1)

    assert name == '/testtopic', 'topic name is testtopic'
    type = hd(types_list)
    assert type == 'std_msgs/msg/String', 'topic type is std_msgs/msg/String'

    Rclex.publisher_finish(publisher_list, node_list)
    Rclex.subscriber_finish(subscriber_list, node_list_2)
    Rclex.node_finish(node_list)
    Rclex.node_finish(node_list_2)
    Rclex.shutdown(context)
  end
end
