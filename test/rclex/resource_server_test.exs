defmodule Rclex.ResourceServerTest do
  use ExUnit.Case
  @moduletag capture_log: true

  alias Rclex.ResourceServer

  setup do
    start_supervised!(Rclex.ResourceServer)
    %{context: Rclex.get_initialized_context()}
  end

  describe "create_node/2" do
    test "return {:ok, node_id}", %{context: context} do
      assert {:ok, 'node0'} = ResourceServer.create_node(context, _node_name = 'node')
    end
  end

  describe "create_node_with_namespace/3" do
    test "return {:ok, node_id}", %{context: context} do
      node_name = 'node'
      namespace = 'namespace'

      assert {:ok, 'namespace/node0'} =
               ResourceServer.create_node_with_namespace(
                 context,
                 node_name,
                 namespace
               )
    end
  end

  describe "create_nodes/3" do
    test "return {:ok, [node_id]}", %{context: context} do
      node_name = 'node'
      node_count = 2

      assert {:ok, ['node0', 'node1']} =
               ResourceServer.create_nodes(
                 context,
                 node_name,
                 node_count
               )
    end

    test "return :error, when node already exists", %{context: context} do
      node_name = 'node'
      node_count = 2

      {:ok, 'node0'} = ResourceServer.create_node(context, node_name)

      # try to create 'node0' and 'node1'
      # but 'node0' already exists so cannot create_nodes
      assert :error = ResourceServer.create_nodes(context, node_name, node_count)
    end
  end

  describe "create_nodes_with_namespace/3" do
    test "return {:ok, [node_id]}", %{context: context} do
      node_name = 'node'
      namespace = 'namespace'
      another_namespace = 'namespace2'
      node_count = 2

      assert {:ok, ['namespace/node0', 'namespace/node1']} =
               ResourceServer.create_nodes_with_namespace(
                 context,
                 node_name,
                 namespace,
                 node_count
               )

      assert :error =
               ResourceServer.create_nodes_with_namespace(
                 context,
                 node_name,
                 namespace,
                 node_count
               )

      assert {:ok, ['namespace2/node0', 'namespace2/node1']} =
               ResourceServer.create_nodes_with_namespace(
                 context,
                 node_name,
                 another_namespace,
                 node_count
               )
    end
  end

  describe "craete_timer/4" do
    test "return {:ok, timer_id}" do
      callback = fn _ -> nil end
      args = nil
      time_ms = 1000
      timer_name = 'timer'

      assert {:ok, "timer/Timer"} =
               ResourceServer.create_timer(callback, args, time_ms, timer_name)
    end
  end

  describe "craete_timer_with_limit/5" do
    test "return {:ok, timer_id}" do
      callback = fn _ -> nil end
      args = nil
      time_ms = 1000
      timer_name = 'timer'
      limit = 5

      assert {:ok, "timer/Timer"} =
               ResourceServer.create_timer_with_limit(callback, args, time_ms, timer_name, limit)
    end
  end

  describe "stop_timer/1" do
    setup do
      callback = fn _ -> nil end
      args = nil
      time_ms = 1000
      timer_name = 'timer'

      {:ok, timer_id = "timer/Timer"} =
        ResourceServer.create_timer(callback, args, time_ms, timer_name)

      %{timer_id: timer_id}
    end

    test "return :ok", %{timer_id: timer_id} do
      assert :ok = ResourceServer.stop_timer(timer_id)
    end

    test "return :error when call again for same timer id", %{timer_id: timer_id} do
      assert :ok = ResourceServer.stop_timer(timer_id)
      assert :error = ResourceServer.stop_timer(timer_id)
    end
  end

  describe "finish_node/1" do
    setup do
      context = Rclex.get_initialized_context()
      node_name = 'node'

      {:ok, node_id} =
        ResourceServer.create_node(
          context,
          node_name
        )

      %{node_id: node_id}
    end

    test "return :ok", %{node_id: node_id} do
      assert :ok = ResourceServer.finish_node(node_id)
    end

    test "return :error when call again for same node id", %{node_id: node_id} do
      assert :ok = ResourceServer.finish_node(node_id)
      assert :error = ResourceServer.finish_node(node_id)
    end
  end

  describe "finish_nodes/1" do
    setup do
      context = Rclex.get_initialized_context()
      node_name = 'node'
      node_count = 2

      {:ok, node_list} =
        ResourceServer.create_nodes(
          context,
          node_name,
          node_count
        )

      %{node_list: node_list}
    end

    test "return :ok list", %{node_list: node_list} do
      assert [:ok, :ok] = ResourceServer.finish_nodes(node_list)
    end
  end
end
