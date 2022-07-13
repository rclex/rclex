defmodule Rclex.SubscriberTest do
  use ExUnit.Case

  alias Rclex.Subscriber
  alias Rclex.Nifs

  setup do
    msg_type = 'StdMsgs.Msg.String'
    node_id = 'node'
    topic = 'topic'

    context = get_initialized_context()

    subscription =
      context
      |> get_initialized_no_namespace_node(node_id)
      |> get_initialized_subscription(topic, msg_type)

    subscriber_id = "#{node_id}/#{topic}/sub"

    start_supervised!({Rclex.Subscriber, {subscription, msg_type, subscriber_id}})

    %{
      id_tuple: {node_id, topic, :sub},
      context: Rclex.get_initialized_context(),
      callback: fn _ -> nil end
    }
  end

  describe "start_subscribing/3" do
    @tag capture_log: true
    test "call to element, return :ok", %{
      id_tuple: id_tuple,
      context: context,
      callback: callback
    } do
      assert :ok = Subscriber.start_subscribing(id_tuple, context, callback)
    end

    @tag capture_log: true
    test "call to list, return :ok", %{id_tuple: id_tuple, context: context, callback: callback} do
      assert [:ok] = Subscriber.start_subscribing([id_tuple], context, callback)
    end
  end

  describe "stop_subscribing/1" do
    test "call to element, return :ok", %{
      id_tuple: id_tuple,
      context: context,
      callback: callback
    } do
      :ok = Subscriber.start_subscribing(id_tuple, context, callback)
      assert :ok = Subscriber.stop_subscribing(id_tuple)
    end

    test "call to list, return :ok", %{
      id_tuple: id_tuple,
      context: context,
      callback: callback
    } do
      id_tuple_list = [id_tuple]
      [:ok] = Subscriber.start_subscribing(id_tuple_list, context, callback)
      assert [:ok] = Subscriber.stop_subscribing(id_tuple_list)
    end
  end

  # TODO: 以下の関数をテストのユーティリティーとしてくくりだす。
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

  defp get_initialized_subscription(
         node,
         topic \\ 'topic',
         message_type \\ 'StdMsgs.Msg.String',
         subscription_options \\ Nifs.rcl_subscription_get_default_options()
       ) do
    subscription = Nifs.rcl_get_zero_initialized_subscription()
    typesupport = Rclex.Msg.typesupport(message_type)

    Nifs.rcl_subscription_init(subscription, node, topic, typesupport, subscription_options)
  end
end
