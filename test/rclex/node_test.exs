defmodule Rclex.NodeTest do
  use ExUnit.Case
  @moduletag capture_log: true
  import Rclex.TestUtils,
    only: [
      get_initialized_context: 0,
      get_initialized_no_namespace_node: 2
    ]

  alias Rclex.Node
  alias Rclex.Nifs

  setup do
    context = get_initialized_context()

    node_a_id = 'node_a0'
    node_a = get_initialized_no_namespace_node(context, node_a_id)
    start_supervised!({Rclex.Node, {node_a, node_a_id, {1, & &1}}})

    node_b_id_list = ['node_b0', 'node_b1']

    node_b_list =
      for node_b_id <- node_b_id_list do
        node_b = get_initialized_no_namespace_node(context, node_b_id)
        start_supervised!({Rclex.Node, {node_b, node_b_id, {1, & &1}}}, id: node_b_id)
        node_b
      end

    on_exit(fn ->
      Nifs.rcl_node_fini(node_a)
      for node_b <- node_b_list, do: Nifs.rcl_node_fini(node_b)
      Nifs.rcl_shutdown(context)
    end)

    %{
      node_id: node_a_id,
      node_id_list: node_b_id_list,
      msg_type: 'StdMsgs.Msg.String',
      topic: 'topic'
    }
  end

  describe "create_publisher/3" do
    test "return {:ok, publisher_id}", %{node_id: node_id, msg_type: msg_type, topic: topic} do
      publisher_id = {node_id, topic, :pub}

      try do
        assert {:ok, ^publisher_id} = Node.create_publisher(node_id, msg_type, topic)
      after
        Node.finish_job(publisher_id)
      end
    end
  end

  describe "create_publishers/4 " do
    test "call with :sigle, return {:ok, publisher_id_list}", %{
      node_id_list: node_id_list,
      msg_type: msg_type,
      topic: topic
    } do
      publisher_id_list = for node_id <- node_id_list, do: {node_id, topic, :pub}

      try do
        assert {:ok, ^publisher_id_list} =
                 Node.create_publishers(node_id_list, msg_type, topic, :single)
      after
        for publisher_id <- publisher_id_list, do: Node.finish_job(publisher_id)
      end
    end

    test "call with :multi, return {:ok, publisher_id_list}", %{
      node_id_list: node_id_list,
      msg_type: msg_type,
      topic: topic
    } do
      publisher_id_list =
        for {node_id, index} <- Enum.with_index(node_id_list) do
          {node_id, "#{topic}#{index}" |> String.to_charlist(), :pub}
        end

      try do
        assert {:ok, ^publisher_id_list} =
                 Node.create_publishers(node_id_list, msg_type, topic, :multi)
      after
        for publisher_id <- publisher_id_list, do: Node.finish_job(publisher_id)
      end
    end
  end

  describe "create_subscriber/3" do
    test "return {:ok, subscriber_id}", %{node_id: node_id, msg_type: msg_type, topic: topic} do
      subscriber_id = {node_id, topic, :sub}

      try do
        assert {:ok, ^subscriber_id} = Node.create_subscriber(node_id, msg_type, topic)
      after
        Node.finish_job(subscriber_id)
      end
    end
  end

  describe "create_subscribers/4 " do
    test "call with :sigle, return {:ok, subscriber_id_list}", %{
      node_id_list: node_id_list,
      msg_type: msg_type,
      topic: topic
    } do
      subscriber_id_list = for node_id <- node_id_list, do: {node_id, topic, :sub}

      try do
        assert {:ok, ^subscriber_id_list} =
                 Node.create_subscribers(node_id_list, msg_type, topic, :single)
      after
        for subscriber_id <- subscriber_id_list, do: Node.finish_job(subscriber_id)
      end
    end

    test "call with :multi, return {:ok, subscriber_id_list}", %{
      node_id_list: node_id_list,
      msg_type: msg_type,
      topic: topic
    } do
      subscriber_id_list =
        for {node_id, index} <- Enum.with_index(node_id_list) do
          {node_id, "#{topic}#{index}" |> String.to_charlist(), :sub}
        end

      try do
        assert {:ok, ^subscriber_id_list} =
                 Node.create_subscribers(node_id_list, msg_type, topic, :multi)
      after
        for subscriber_id <- subscriber_id_list, do: Node.finish_job(subscriber_id)
      end
    end
  end

  describe "finish_job/1" do
    test "call for publisher return :ok", %{node_id: node_id, msg_type: msg_type, topic: topic} do
      {:ok, publisher_id = {^node_id, ^topic, :pub}} =
        Node.create_publisher(node_id, msg_type, topic)

      assert :ok = Node.finish_job(publisher_id)
    end

    test "call for subscriber return :ok", %{node_id: node_id, msg_type: msg_type, topic: topic} do
      {:ok, subscriber_id = {^node_id, ^topic, :sub}} =
        Node.create_subscriber(node_id, msg_type, topic)

      assert :ok = Node.finish_job(subscriber_id)
    end
  end

  describe "finish_jobs/1" do
    test "call for :single publishers return :ok list", %{
      node_id_list: node_id_list,
      msg_type: msg_type,
      topic: topic
    } do
      {:ok, publisher_id_list} = Node.create_publishers(node_id_list, msg_type, topic, :single)

      assert [:ok, :ok] = Node.finish_jobs(publisher_id_list)
    end

    test "call for :multi publishers return :ok list", %{
      node_id_list: node_id_list,
      msg_type: msg_type,
      topic: topic
    } do
      {:ok, publisher_id_list} = Node.create_publishers(node_id_list, msg_type, topic, :multi)

      assert [:ok, :ok] = Node.finish_jobs(publisher_id_list)
    end

    test "call for :single subscribers return :ok list", %{
      node_id_list: node_id_list,
      msg_type: msg_type,
      topic: topic
    } do
      {:ok, subscriber_id_list} = Node.create_subscribers(node_id_list, msg_type, topic, :single)

      assert [:ok, :ok] = Node.finish_jobs(subscriber_id_list)
    end

    test "call for :multi subscribers return :ok list", %{
      node_id_list: node_id_list,
      msg_type: msg_type,
      topic: topic
    } do
      {:ok, subscriber_id_list} = Node.create_subscribers(node_id_list, msg_type, topic, :multi)

      assert [:ok, :ok] = Node.finish_jobs(subscriber_id_list)
    end
  end
end
