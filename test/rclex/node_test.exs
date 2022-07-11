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
end
