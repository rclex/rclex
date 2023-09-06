defmodule Rclex.ResourceServerTest do
  use ExUnit.Case
  @moduletag capture_log: true

  import Rclex.TestUtils, only: [get_initialized_context: 0]

  alias Rclex.ResourceServer

  setup do
    pid = start_supervised!(Rclex.ResourceServer)

    context = get_initialized_context()
    on_exit(fn -> Rclex.Nifs.rcl_shutdown(context) end)

    %{context: context, pid: pid}
  end

  describe "create_node/2" do
    test "return {:ok, node_id}", %{context: context, pid: pid} do
      node_id = ~c"node0"

      try do
        assert {:ok, ^node_id} = ResourceServer.create_node(context, _node_name = ~c"node")
      after
        :ok = GenServer.call(pid, {:finish_node, node_id})
      end
    end
  end

  describe "create_node_with_namespace/3" do
    test "return {:ok, node_id}", %{context: context, pid: pid} do
      node_name = ~c"node"
      namespace = ~c"namespace"

      node_id = ~c"namespace/node0"

      try do
        assert {:ok, ^node_id} =
                 ResourceServer.create_node_with_namespace(
                   context,
                   node_name,
                   namespace
                 )
      after
        :ok = GenServer.call(pid, {:finish_node, node_id})
      end
    end
  end

  describe "create_nodes/3" do
    test "return {:ok, [node_id]}", %{context: context, pid: pid} do
      node_name = ~c"node"
      node_count = 2

      node_id_list = [~c"node0", ~c"node1"]

      try do
        assert {:ok, ^node_id_list} =
                 ResourceServer.create_nodes(
                   context,
                   node_name,
                   node_count
                 )
      after
        for node_id <- node_id_list do
          :ok = GenServer.call(pid, {:finish_node, node_id})
        end
      end
    end

    test "return :error, when node already exists", %{context: context, pid: pid} do
      node_name = ~c"node"
      node_count = 2

      node_id = ~c"node0"

      try do
        {:ok, ^node_id} = ResourceServer.create_node(context, node_name)
        # try to create 'node0' and 'node1'
        # but 'node0' already exists so cannot create_nodes
        assert :error = ResourceServer.create_nodes(context, node_name, node_count)
      after
        :ok = GenServer.call(pid, {:finish_node, node_id})
      end
    end
  end

  describe "create_nodes_with_namespace/3" do
    test "return {:ok, [node_id]}", %{context: context, pid: pid} do
      node_name = ~c"node"
      namespace = ~c"namespace"
      another_namespace = ~c"namespace2"
      node_count = 2

      node_id_list = [~c"namespace/node0", ~c"namespace/node1"]
      another_node_id_list = [~c"namespace2/node0", ~c"namespace2/node1"]

      try do
        assert {:ok, ^node_id_list} =
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

        assert {:ok, ^another_node_id_list} =
                 ResourceServer.create_nodes_with_namespace(
                   context,
                   node_name,
                   another_namespace,
                   node_count
                 )
      after
        for node_id <- node_id_list ++ another_node_id_list do
          :ok = GenServer.call(pid, {:finish_node, node_id})
        end
      end
    end
  end

  describe "create_timer/4" do
    test "return {:ok, timer_id}", %{pid: pid} do
      callback = fn _ -> nil end
      args = nil
      time_ms = 1000
      timer_name = ~c"timer"

      timer_id = "timer/Timer"

      try do
        assert {:ok, ^timer_id} = ResourceServer.create_timer(callback, args, time_ms, timer_name)
      after
        :ok = GenServer.call(pid, {:stop_timer, timer_id})
      end
    end
  end

  describe "create_timer_with_limit/5" do
    test "return {:ok, timer_id}", %{pid: pid} do
      callback = fn _ -> nil end
      args = nil
      time_ms = 1000
      timer_name = ~c"timer"
      limit = 5

      timer_id = "timer/Timer"

      try do
        assert {:ok, ^timer_id} =
                 ResourceServer.create_timer_with_limit(
                   callback,
                   args,
                   time_ms,
                   timer_name,
                   limit
                 )
      after
        :ok = GenServer.call(pid, {:stop_timer, timer_id})
      end
    end
  end

  describe "stop_timer/1" do
    setup do
      callback = fn _ -> nil end
      args = nil
      time_ms = 1000
      timer_name = ~c"timer"

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
    setup %{context: context} do
      node_name = ~c"node"

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
    setup %{context: context} do
      node_name = ~c"node"
      node_count = 2

      {:ok, node_id_list} =
        ResourceServer.create_nodes(
          context,
          node_name,
          node_count
        )

      %{node_id_list: node_id_list}
    end

    test "return :ok list", %{node_id_list: node_id_list} do
      assert [:ok, :ok] = ResourceServer.finish_nodes(node_id_list)
    end
  end
end
