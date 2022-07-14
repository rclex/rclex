defmodule Rclex.NodeTest do
  use ExUnit.Case
  @moduletag capture_log: true

  alias Rclex.Node

  setup do
    start_supervised!(Rclex.ResourceServer)
    context = Rclex.get_initialized_context()
    {:ok, node_id} = Rclex.ResourceServer.create_node(context, _node_name = 'singular')

    {:ok, node_id_list} =
      Rclex.ResourceServer.create_nodes(context, _node_name = 'plural', _node_count = 2)

    on_exit(fn -> Rclex.Nifs.rcl_shutdown(context) end)

    %{
      node_id: node_id,
      node_id_list: node_id_list,
      msg_type: 'StdMsgs.Msg.String',
      topic: 'topic'
    }
  end

  describe "create_publisher/3" do
    test "return {:ok, publisher_id}", %{node_id: node_id, msg_type: msg_type, topic: topic} do
      assert {:ok, {^node_id, ^topic, :pub}} = Node.create_publisher(node_id, msg_type, topic)
    end
  end

  describe "create_publishers/4 " do
    test "call with :sigle, return {:ok, publisher_id_list}", %{
      node_id_list: node_id_list,
      msg_type: msg_type,
      topic: topic
    } do
      publisher_id_list = for node_id <- node_id_list, do: {node_id, topic, :pub}

      assert {:ok, ^publisher_id_list} =
               Node.create_publishers(node_id_list, msg_type, topic, :single)
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

      assert {:ok, ^publisher_id_list} =
               Node.create_publishers(node_id_list, msg_type, topic, :multi)
    end
  end

  describe "create_subscriber/3" do
    test "return {:ok, subscriber_id}", %{node_id: node_id, msg_type: msg_type, topic: topic} do
      assert {:ok, {^node_id, ^topic, :sub}} = Node.create_subscriber(node_id, msg_type, topic)
    end
  end

  describe "create_subscribers/4 " do
    test "call with :sigle, return {:ok, subscriber_id_list}", %{
      node_id_list: node_id_list,
      msg_type: msg_type,
      topic: topic
    } do
      subscriber_id_list = for node_id <- node_id_list, do: {node_id, topic, :sub}

      assert {:ok, ^subscriber_id_list} =
               Node.create_subscribers(node_id_list, msg_type, topic, :single)
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

      assert {:ok, ^subscriber_id_list} =
               Node.create_subscribers(node_id_list, msg_type, topic, :multi)
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
