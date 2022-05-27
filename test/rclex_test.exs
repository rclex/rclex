defmodule RclexTest do
  use ExUnit.Case
  doctest Rclex

  # -----------------------node_nif.c--------------------------
  test "rcl_node_get_name" do
    context = Rclex.rclexinit()

    node_name = 'test_node'
    {:ok, node_list} = Rclex.ResourceServer.create_nodes(context, node_name, 2)
    [node_0, node_1] = node_list

    assert Rclex.Node.node_get_name(node_0) == 'test_node0', 'first node name is test_node0'
    assert Rclex.Node.node_get_name(node_1) == 'test_node1', 'second node name is test_node1'

    Rclex.ResourceServer.finish_nodes(node_list)
    Rclex.shutdown(context)
  end

  test "single_pub_sub" do
    context = Rclex.rclexinit()
    str_data = "data"

    {:ok, sub_node} = Rclex.ResourceServer.create_node(context, 'listener')

    {:ok, subscriber} = Rclex.Node.create_subscriber(sub_node, 'StdMsgs.Msg.String', 'chatter')

    Rclex.Subscriber.start_subscribing([subscriber], context, fn msg ->
      recv_msg = Rclex.Msg.read(msg, 'StdMsgs.Msg.String')
      assert List.to_string(recv_msg.data) == str_data, "received data is correct."
      msg_data = List.to_string(recv_msg.data)
      IO.puts("Rclex: received msg: #{msg_data}")
    end)

    {:ok, pub_node} = Rclex.ResourceServer.create_node(context, 'talker')

    {:ok, publisher} = Rclex.Node.create_publisher(pub_node, 'StdMsgs.Msg.String', 'chatter')

    {:ok, timer} =
      Rclex.ResourceServer.create_timer_with_limit(
        fn publisher ->
          msg = Rclex.Msg.initialize('StdMsgs.Msg.String')

          Rclex.Msg.set(
            msg,
            %Rclex.StdMsgs.Msg.String{data: String.to_charlist(str_data)},
            'StdMsgs.Msg.String'
          )

          Rclex.Publisher.publish([publisher], [msg])
        end,
        publisher,
        100,
        'continus_timer',
        1
      )

    Process.sleep(500)

    Rclex.ResourceServer.stop_timer(timer)
    Rclex.Subscriber.stop_subscribing([subscriber])
    Rclex.Node.finish_jobs([publisher, subscriber])
    Rclex.ResourceServer.finish_nodes([pub_node, sub_node])
    Rclex.shutdown(context)
  end

  # -----------------------graph_nif.c--------------------------
  test "rcl_get_topic_names_and_types" do
    context = Rclex.rclexinit()

    {:ok, node_list} = Rclex.ResourceServer.create_nodes(context, 'test_pub_node', 1)

    {:ok, publisher_list} =
      Rclex.Node.create_publishers(node_list, 'StdMsgs.Msg.String', 'testtopic', :single)

    {:ok, node_list_2} = Rclex.ResourceServer.create_nodes(context, 'test_sub_node', 1)

    {:ok, subscriber_list} =
      Rclex.Node.create_subscribers(node_list_2, 'StdMsgs.Msg.String', 'testtopic', :single)

    node = hd(node_list)

    names_and_types_tuple_list =
      Rclex.Node.get_topic_names_and_types(
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

    Rclex.Node.finish_jobs(publisher_list)
    Rclex.Node.finish_jobs(subscriber_list)
    Rclex.ResourceServer.finish_nodes(node_list)
    Rclex.ResourceServer.finish_nodes(node_list_2)
    Rclex.shutdown(context)
  end
end
