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
  end

  describe "create_nodes_with_namespace/3" do
    test "return {:ok, [node_id]}", %{context: context} do
      node_name = 'node'
      namespace = 'namespace'
      node_count = 2

      assert {:ok, ['namespace/node0', 'namespace/node1']} =
               ResourceServer.create_nodes_with_namespace(
                 context,
                 node_name,
                 namespace,
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
end
