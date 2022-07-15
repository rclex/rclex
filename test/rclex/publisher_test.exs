defmodule Rclex.PublisherTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  import Rclex.TestUtils,
    only: [
      get_initialized_context: 0,
      get_initialized_no_namespace_node: 2,
      get_initialized_publisher: 3
    ]

  alias Rclex.Publisher
  alias Rclex.Nifs

  setup do
    msg_type = 'StdMsgs.Msg.String'
    node_id = 'node'
    topic = 'topic'

    context = get_initialized_context()
    node = get_initialized_no_namespace_node(context, node_id)
    publisher = get_initialized_publisher(node, topic, msg_type)

    on_exit(fn ->
      Nifs.rcl_node_fini(node)
      Nifs.rcl_shutdown(context)
    end)

    publisher_id = "#{node_id}/#{topic}/pub"
    pid = start_supervised!({Rclex.Publisher, {publisher, publisher_id}})

    %{publisher: publisher, id_tuple: {node_id, topic, :pub}, pid: pid, node: node}
  end

  describe "publish_once/3" do
    test "capture_log", %{publisher: publisher, node: node} do
      publisher_allocation = Nifs.create_pub_alloc()

      message = Rclex.Msg.initialize('StdMsgs.Msg.String')

      :ok =
        Rclex.Msg.set(
          message,
          %Rclex.StdMsgs.Msg.String{data: 'data'},
          'StdMsgs.Msg.String'
        )

      try do
        assert capture_log(fn ->
                 Publisher.publish_once(publisher, message, publisher_allocation)
               end) =~ "publish ok"
      after
        Nifs.rcl_publisher_fini(publisher, node)
      end
    end
  end

  describe "publish/2" do
    @tag capture_log: true
    test "return :ok", %{id_tuple: id_tuple, publisher: publisher, node: node} do
      message = Rclex.Msg.initialize('StdMsgs.Msg.String')

      :ok =
        Rclex.Msg.set(
          message,
          %Rclex.StdMsgs.Msg.String{data: 'data'},
          'StdMsgs.Msg.String'
        )

      try do
        assert :ok = Publisher.publish([id_tuple], [message])
      after
        Nifs.rcl_publisher_fini(publisher, node)
      end
    end
  end

  describe "handle_cast({:publish, msg}, pub)" do
    test "capture_log", %{pid: pid, publisher: publisher, node: node} do
      message = Rclex.Msg.initialize('StdMsgs.Msg.String')

      :ok =
        Rclex.Msg.set(
          message,
          %Rclex.StdMsgs.Msg.String{data: 'data'},
          'StdMsgs.Msg.String'
        )

      try do
        assert capture_log(fn ->
                 GenServer.cast(pid, {:publish, message})
                 Process.sleep(10)
               end) =~ "publish ok"
      after
        Nifs.rcl_publisher_fini(publisher, node)
      end
    end
  end

  describe "handle_call({:finish, node}, ...)" do
    test "return", %{pid: pid, node: node} do
      assert {:ok, 'publisher finished: '} = GenServer.call(pid, {:finish, node})
    end
  end
end
