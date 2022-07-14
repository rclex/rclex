defmodule Rclex.PublisherTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Rclex.Publisher
  alias Rclex.Nifs

  setup do
    msg_type = 'StdMsgs.Msg.String'
    node_id = 'node'
    topic = 'topic'

    context = get_initialized_context()
    node = get_initialized_no_namespace_node(context, node_id)

    publisher = get_initialized_publisher(node, topic, msg_type)

    publisher_id = "#{node_id}/#{topic}/pub"

    pid = start_supervised!({Rclex.Publisher, {publisher, publisher_id}})

    %{publisher: publisher, id_tuple: {node_id, topic, :pub}, pid: pid, node: node}
  end

  describe "publish_once/3" do
    test "capture_log", %{publisher: publisher} do
      publisher_allocation = Nifs.create_pub_alloc()

      message = Rclex.Msg.initialize('StdMsgs.Msg.String')

      :ok =
        Rclex.Msg.set(
          message,
          %Rclex.StdMsgs.Msg.String{data: 'data'},
          'StdMsgs.Msg.String'
        )

      assert capture_log(fn ->
               Publisher.publish_once(publisher, message, publisher_allocation)
             end) =~ "publish ok"
    end
  end

  describe "publish/2" do
    @tag capture_log: true
    test "return :ok", %{id_tuple: id_tuple} do
      message = Rclex.Msg.initialize('StdMsgs.Msg.String')

      :ok =
        Rclex.Msg.set(
          message,
          %Rclex.StdMsgs.Msg.String{data: 'data'},
          'StdMsgs.Msg.String'
        )

      assert :ok = Publisher.publish([id_tuple], [message])
    end
  end

  describe "handle_cast({:publish, msg}, pub)" do
    test "capture_log", %{pid: pid} do
      message = Rclex.Msg.initialize('StdMsgs.Msg.String')

      :ok =
        Rclex.Msg.set(
          message,
          %Rclex.StdMsgs.Msg.String{data: 'data'},
          'StdMsgs.Msg.String'
        )

      assert capture_log(fn ->
               GenServer.cast(pid, {:publish, message})
               Process.sleep(10)
             end) =~ "publish ok"
    end
  end

  describe "handle_call({:finish, node}, ...)" do
    test "return", %{pid: pid, node: node} do
      assert {:ok, 'publisher finished: '} = GenServer.call(pid, {:finish, node})
    end
  end

  defp get_initialized_context() do
    options = Nifs.rcl_get_zero_initialized_init_options()
    :ok = Nifs.rcl_init_options_init(options)
    context = Nifs.rcl_get_zero_initialized_context()
    Nifs.rcl_init_with_null(options, context)
    Nifs.rcl_init_options_fini(options)

    context
  end

  defp get_initialized_no_namespace_node(context, node_name \\ 'node') do
    node = Nifs.rcl_get_zero_initialized_node()
    options = Nifs.rcl_node_get_default_options()

    Nifs.rcl_node_init_without_namespace(node, node_name, context, options)
  end

  defp get_initialized_publisher(
         node,
         topic \\ 'topic',
         message_type \\ 'StdMsgs.Msg.String',
         publisher_options \\ Nifs.rcl_publisher_get_default_options()
       ) do
    publisher = Nifs.rcl_get_zero_initialized_publisher()
    typesupport = Rclex.Msg.typesupport(message_type)

    Nifs.rcl_publisher_init(publisher, node, topic, typesupport, publisher_options)
  end
end
