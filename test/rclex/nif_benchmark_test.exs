defmodule Rclex.NifBenchmarkTest do
  use ExUnit.Case

  require Logger

  import ExUnit.CaptureLog

  alias Rclex.Nif

  @moduletag :skip
  @nif_limit_time_us 1000

  setup_all do
    capture_log(fn -> Application.stop(:rclex) end)
    :ok
  end

  describe "context" do
    test "rcl_init!/0" do
      {time_us, context} = :timer.tc(&Nif.rcl_init!/0, [])
      :ok = Nif.rcl_fini!(context)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_fini!/1" do
      context = Nif.rcl_init!()
      {time_us, :ok} = :timer.tc(&Nif.rcl_fini!/1, [context])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "node" do
    setup do
      context = Nif.rcl_init!()
      on_exit(fn -> :ok = Nif.rcl_fini!(context) end)
      %{context: context}
    end

    test "rcl_node_init!/3", %{context: context} do
      {time_us, node} = :timer.tc(&Nif.rcl_node_init!/3, [context, ~c"name", ~c"/namespace"])
      :ok = Nif.rcl_node_fini!(node)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_node_fini!/1", %{context: context} do
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      {time_us, :ok} = :timer.tc(&Nif.rcl_node_fini!/1, [node])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "publisher" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.rosidl_get_std_msgs_msg_string_type_support!()

      on_exit(fn ->
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{node: node, type_support: type_support}
    end

    test "rcl_publisher_init!/3", %{node: node, type_support: type_support} do
      {time_us, publisher} =
        :timer.tc(&Nif.rcl_publisher_init!/3, [node, type_support, ~c"/topic"])

      :ok = Nif.rcl_publisher_fini!(publisher, node)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_publisher_fini!/2", %{node: node, type_support: type_support} do
      publisher = Nif.rcl_publisher_init!(node, type_support, ~c"/topic")
      {time_us, :ok} = :timer.tc(&Nif.rcl_publisher_fini!/2, [publisher, node])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "subscription" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.rosidl_get_std_msgs_msg_string_type_support!()

      on_exit(fn ->
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{node: node, type_support: type_support}
    end

    test "rcl_subscription_init!/3", %{node: node, type_support: type_support} do
      {time_us, subscription} =
        :timer.tc(&Nif.rcl_subscription_init!/3, [node, type_support, ~c"/topic"])

      :ok = Nif.rcl_subscription_fini!(subscription, node)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_subscription_fini!/2", %{node: node, type_support: type_support} do
      subscription = Nif.rcl_subscription_init!(node, type_support, ~c"/topic")
      {time_us, :ok} = :timer.tc(&Nif.rcl_subscription_fini!/2, [subscription, node])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "wait_set" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.rosidl_get_std_msgs_msg_string_type_support!()
      subscription = Nif.rcl_subscription_init!(node, type_support, ~c"/topic")

      on_exit(fn ->
        :ok = Nif.rcl_subscription_fini!(subscription, node)
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{context: context, subscription: subscription}
    end

    test "rcl_wait_set_init_subscription!/1", %{context: context} do
      {time_us, wait_set} = :timer.tc(&Nif.rcl_wait_set_init_subscription!/1, [context])
      :ok = Nif.rcl_wait_set_fini!(wait_set)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_wait_set_fini!/1", %{context: context} do
      wait_set = Nif.rcl_wait_set_init_subscription!(context)
      {time_us, :ok} = :timer.tc(&Nif.rcl_wait_set_fini!/1, [wait_set])
      assert time_us <= @nif_limit_time_us
    end
  end
end
