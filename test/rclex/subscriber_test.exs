defmodule Rclex.SubscriberTest do
  use ExUnit.Case

  alias Rclex.Subscriber

  describe "start_subscribing/3" do
    setup do
      msg_type = 'StdMsgs.Msg.String'
      node_id = 'node'
      topic = 'topic'

      dummy_subscriber_reference = make_ref()
      subscriber_id = "#{node_id}/#{topic}/sub"

      start_supervised!({Rclex.Subscriber, {dummy_subscriber_reference, msg_type, subscriber_id}})

      %{
        subscriber: {node_id, topic, :sub},
        context: Rclex.get_initialized_context(),
        callback: fn _ -> nil end
      }
    end

    @tag capture_log: true
    test "for Subscriber.t(), return :ok", %{
      subscriber: subscriber,
      context: context,
      callback: callback
    } do
      assert :ok = Subscriber.start_subscribing(subscriber, context, callback)
      assert :ok = Subscriber.stop_subscribing(subscriber)
    end

    @tag capture_log: true
    test "for [Subscriber.t()], return :ok", %{
      subscriber: subscriber,
      context: context,
      callback: callback
    } do
      assert [:ok] = Subscriber.start_subscribing([subscriber], context, callback)
      assert :ok = Subscriber.stop_subscribing(subscriber)
    end
  end
end
