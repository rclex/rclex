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
end
