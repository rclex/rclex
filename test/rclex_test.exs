defmodule RclexTest do
  use ExUnit.Case
  @moduletag capture_log: true

  doctest Rclex

  describe "rclexinit/0" do
    test "return reference" do
      assert is_reference(Rclex.rclexinit())
    end

    test "start_link Rclex.ResourceServer" do
      Rclex.rclexinit()
      assert is_pid(GenServer.whereis(:resource_server))
    end
  end

  # -----------------------node_nif.c--------------------------
  test "rcl_node_get_name" do
    context = Rclex.rclexinit()

    node_name = ~c"test_node"
    {:ok, node_list} = Rclex.ResourceServer.create_nodes(context, node_name, 2)
    [node_0, node_1] = node_list

    assert Rclex.Node.node_get_name(node_0) == ~c"test_node0"
    assert Rclex.Node.node_get_name(node_1) == ~c"test_node1"

    Rclex.ResourceServer.finish_nodes(node_list)
    Rclex.shutdown(context)
  end

  test "single_pub_sub" do
    context = Rclex.rclexinit()
    str_data = "data"
    pid = self()

    {:ok, sub_node} = Rclex.ResourceServer.create_node(context, ~c"listener")

    {:ok, subscriber} =
      Rclex.Node.create_subscriber(sub_node, ~c"StdMsgs.Msg.String", ~c"chatter")

    Rclex.Subscriber.start_subscribing([subscriber], context, fn msg ->
      recv_msg = Rclex.Msg.read(msg, ~c"StdMsgs.Msg.String")
      assert List.to_string(recv_msg.data) == str_data, "received data is correct."
      _msg_data = List.to_string(recv_msg.data)
      send(pid, :message_received)
    end)

    {:ok, pub_node} = Rclex.ResourceServer.create_node(context, ~c"talker")

    {:ok, publisher} = Rclex.Node.create_publisher(pub_node, ~c"StdMsgs.Msg.String", ~c"chatter")

    {:ok, timer} =
      Rclex.ResourceServer.create_timer_with_limit(
        fn publisher ->
          msg = Rclex.Msg.initialize(~c"StdMsgs.Msg.String")

          Rclex.Msg.set(
            msg,
            %Rclex.StdMsgs.Msg.String{data: String.to_charlist(str_data)},
            ~c"StdMsgs.Msg.String"
          )

          Rclex.Publisher.publish([publisher], [msg])
        end,
        publisher,
        100,
        ~c"continuous_timer",
        1
      )

    assert_receive :message_received, 500

    Rclex.ResourceServer.stop_timer(timer)
    Rclex.Subscriber.stop_subscribing([subscriber])
    Rclex.Node.finish_jobs([publisher, subscriber])
    Rclex.ResourceServer.finish_nodes([pub_node, sub_node])
    Rclex.shutdown(context)
  end

  # -----------------------graph_nif.c--------------------------
  test "rcl_get_topic_names_and_types" do
    context = Rclex.rclexinit()

    {:ok, node_list} = Rclex.ResourceServer.create_nodes(context, ~c"test_pub_node", 1)

    {:ok, publisher_list} =
      Rclex.Node.create_publishers(node_list, ~c"StdMsgs.Msg.String", ~c"testtopic", :single)

    {:ok, node_list_2} = Rclex.ResourceServer.create_nodes(context, ~c"test_sub_node", 1)

    {:ok, subscriber_list} =
      Rclex.Node.create_subscribers(node_list_2, ~c"StdMsgs.Msg.String", ~c"testtopic", :single)

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

    assert name == ~c"/testtopic"
    type = hd(types_list)
    assert type == ~c"std_msgs/msg/String"

    Rclex.Node.finish_jobs(publisher_list)
    Rclex.Node.finish_jobs(subscriber_list)
    Rclex.ResourceServer.finish_nodes(node_list)
    Rclex.ResourceServer.finish_nodes(node_list_2)
    Rclex.shutdown(context)
  end
end
