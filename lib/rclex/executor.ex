defmodule Rclex.Executor do
  alias Rclex.Nifs
  require Rclex.Macros
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
      T.B.A
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: Executor)
  end

  @doc """
      Executorプロセスの初期化
      下位プロセスとしてJobQueue, JobExecutorプロセスを生成する
      状態:
          supervisor_ids :: map()
          keyがnode_identifer、valueがnode情報。現在はnodeプロセスのsupervisorのidを格納している
  """
  def init(_) do
    {:ok, {%{}}}
  end

  @doc """
      ノードをひとつだけ作成
      名前空間の有無を設定可能
      返り値:
          node_identifier :: string()
          作成したノードプロセスのnameを返す
  """
  def create_singlenode(context, node_name, node_namespace) do
    GenServer.call(Executor, {:create_singlenode, {context, node_name, node_namespace}})
  end

  def create_singlenode(context, node_name) do
    GenServer.call(Executor, {:create_singlenode, {context, node_name}})
  end

  @doc """
      複数ノード生成
      create_nodes/4ではcreate_nodes/3に加えて名前空間の指定が可能
      返り値:
          node_identifier_list :: Enumerable.t()
          作成したノードプロセスのnameのリストを返す
  """
  def create_nodes(context, node_name, namespace, num_node) do
    GenServer.call(Executor, {:create_nodes, context, node_name, namespace, num_node})
  end

  def create_nodes(context, node_name, num_node) do
    GenServer.call(Executor, {:create_nodes, context, node_name, num_node})
  end

  def create_timer(call_back, args, time, timer_name) do
    GenServer.call(Executor, {:create_timer, {call_back, args, time, timer_name}})
  end

  def create_timer(call_back, args, time, timer_name, limit) do
    GenServer.call(Executor, {:create_timer, {call_back, args, time, timer_name, limit}})
  end

  @doc """
      タイマープロセスを削除する
      入力
          timer_id :: pid()
          削除するタイマープロセスのid
  """
  def stop_timer(timer_id) do
    Supervisor.stop(timer_id)
  end

  @doc """
      ノードプロセスを削除する
      入力
          node_identifier :: string()
          削除するnodeのプロセス名
  """
  def finish_node(node_identifier) do
    GenServer.call(Executor, {:finish_node, node_identifier})
  end

  def finish_nodes(node_identifier_list) do
    Enum.map(
      node_identifier_list,
      fn node_identifier -> GenServer.call(Executor, {:finish_node, node_identifier}) end
    )
  end

  # def handle_cast({:execute, {key, action, args}}, {nodes}) do
  #   GenServer.cast(key, {action, args})
  #   {:noreply, {nodes}}
  # end

  def handle_call({:create_singlenode, {context, node_name, node_namespace}}, _from, {nodes}) do
    if Map.has_key?(nodes, {node_namespace, node_name}) do
      # 同名のノードがすでに存在しているときはエラーを返す
      {:reply, {:error, node_name}}
    else
      node = Nifs.rcl_get_zero_initialized_node()
      node_op = Nifs.rcl_node_get_default_options()
      Nifs.rcl_node_init(node, node_name, node_namespace, context, node_op)

      children = [
        {Rclex.Node, {node, node_name, node_namespace}}
      ]

      opts = [strategy: :one_for_one]
      {:ok, pid} = Supervisor.start_link(children, opts)
      node_identifier = "#{node_namespace}/{node_name}"
      new_nodes = Map.put_new(nodes, node_identifier, %{supervisor_id: pid})
      {:reply, {:ok, node_identifier}, {new_nodes}}
    end
  end

  def handle_call({:create_singlenode, {context, node_name}}, _from, {nodes}) do
    if Map.has_key?(nodes, {"", node_name}) do
      # 同名のノードがすでに存在しているときはエラーを返す
      {:reply, {:error, node_name}}
    else
      node = Nifs.rcl_get_zero_initialized_node()
      node_op = Nifs.rcl_node_get_default_options()
      Nifs.rcl_node_init_without_namespace(node, node_name, context, node_op)

      children = [
        {Rclex.Node, {node, node_name}}
      ]

      opts = [strategy: :one_for_one]
      {:ok, pid} = Supervisor.start_link(children, opts)
      new_nodes = Map.put_new(nodes, node_name, %{supervisor_id: pid})
      {:reply, {:ok, node_name}, {new_nodes}}
    end
  end

  def handle_call({:create_nodes, context, node_name, namespace, num_node}, _from, {nodes}) do
    name_list =
      Enum.map(0..(num_node - 1), fn n ->
        node_name ++ Integer.to_charlist(n)
      end)

    node_list =
      Enum.map(0..(num_node - 1), fn n ->
        Nifs.rcl_node_init(
          Nifs.rcl_get_zero_initialized_node(),
          Enum.at(name_list, n),
          namespace,
          context,
          Nifs.rcl_node_get_default_options()
        )
      end)

    id_list =
      Enum.map(0..(num_node - 1), fn n ->
        Supervisor.start_link(
          [
            {
              Rclex.Node,
              {
                Enum.at(node_list, n),
                Enum.at(name_list, n),
                namespace
              }
            }
          ],
          strategy: :one_for_one
        )
      end)
      |> Enum.map(fn {:ok, pid} -> pid end)

    node_identifier_list = Enum.map(name_list, fn name -> "#{namespace}/#{name}" end)

    nodes_list =
      Enum.map(0..(num_node - 1), fn n ->
        node_identifier = Enum.at(node_identifier_list, n)
        pid = Enum.at(id_list, n)
        {node_identifier, %{supervisor_id: pid}}
      end)

    new_nodes = for {k, v} <- nodes_list, into: nodes, do: {k, v}

    {:reply, {:ok, node_identifier_list}, {new_nodes}}
  end

  def handle_call({:create_nodes, context, node_name, num_node}, _from, {nodes}) do
    name_list =
      Enum.map(0..(num_node - 1), fn n ->
        node_name ++ Integer.to_charlist(n)
      end)

    node_list =
      Enum.map(0..(num_node - 1), fn n ->
        Nifs.rcl_node_init_without_namespace(
          Nifs.rcl_get_zero_initialized_node(),
          Enum.at(name_list, n),
          context,
          Nifs.rcl_node_get_default_options()
        )
      end)

    id_list =
      Enum.map(0..(num_node - 1), fn n ->
        Supervisor.start_link(
          [
            {
              Rclex.Node,
              {
                Enum.at(node_list, n),
                Enum.at(name_list, n)
              }
            }
          ],
          strategy: :one_for_one
        )
      end)
      |> Enum.map(fn {:ok, pid} -> pid end)

    nodes_list =
      Enum.map(0..(num_node - 1), fn n ->
        node_name = Enum.at(name_list, n)
        pid = Enum.at(id_list, n)
        {node_name, %{supervisor_id: pid}}
      end)

    new_nodes = for {k, v} <- nodes_list, into: nodes, do: {k, v}

    {:reply, {:ok, name_list}, {new_nodes}}
  end

  def handle_call({:create_timer, {call_back, args, time, timer_name}}, _from, state) do
    children = [
      {Rclex.Timer, {call_back, args, time, timer_name}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, pid} = Supervisor.start_link(children, opts)
    {:reply, {:ok, pid}, state}
  end

  def handle_call({:create_timer, {call_back, args, time, timer_name, limit}}, _from, state) do
    children = [
      {Rclex.Timer, {call_back, args, time, timer_name, limit}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, pid} = Supervisor.start_link(children, opts)
    {:reply, {:ok, pid}, state}
  end

  def handle_call({:finish_node, node_identifier}, _from, {nodes}) do
    GenServer.call({:global, node_identifier}, :finish_node)
    {:ok, node} = Map.fetch(nodes, node_identifier)

    {:ok, supervisor_id} = Map.fetch(node, :supervisor_id)

    Supervisor.stop(supervisor_id)

    # node情報削除
    new_nodes = Map.delete(nodes, node_identifier)
    Logger.debug("finish node: #{node_identifier}")

    {:reply, :ok, {new_nodes}}
  end

  def handle_info({_, _, reason}, state) do
    Logger.debug(reason)
    {:noreply, state}
  end
end
