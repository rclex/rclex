defmodule Rclex.ResourceServer do
  alias Rclex.Nifs
  require Logger
  use GenServer, restart: :transient

  # TODO: replece any() with Rclex.rcl_contest()
  @type context :: any()

  @moduledoc """
  Defines functions to manage ROS resources, Node and Timer.
  """

  @spec start_link(any()) :: GenServer.on_start()
  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: ResourceServer)
  end

  # TODO: define Resources struct for GerServer state which shows resources explicitly.
  @doc """
      ResourceServerプロセスの初期化
      状態:
          supervisor_ids :: map()
          keyがnode_identifer、valueがnode情報。現在はnodeプロセスのsupervisorのidを格納している
  """
  @impl GenServer
  def init(_) do
    {:ok, {%{}}}
  end

  @doc """
  Create specified name single Node without namespace.
  This function calls `create_node_with_namespace/5` with namespace = ''.
  """
  @spec create_node(context(), charlist(), integer(), (list() -> list())) ::
          {:ok, node_identifier :: charlist()}
  def create_node(context, node_name, queue_length \\ 1, change_order \\ & &1) do
    create_node_with_namespace(context, node_name, '', queue_length, change_order)
  end

  @doc """
  Create specified name single Node with specified namespace.

  ## Arguments

  * context: rcl context
  * node_name: node name
  * node_namespace: node namespace
  * queue_length: executor's queue length
  * change_order: function which change the order of job
  """
  @spec create_node_with_namespace(
          context(),
          charlist(),
          charlist(),
          integer(),
          (list() -> list())
        ) :: {:ok, node_identifier :: charlist()}
  def create_node_with_namespace(
        context,
        node_name,
        node_namespace,
        queue_length \\ 1,
        change_order \\ & &1
      ) do
    {:ok, [node]} =
      GenServer.call(
        ResourceServer,
        {:create_nodes, {context, node_name, node_namespace, 1, {queue_length, change_order}}}
      )

    {:ok, node}
  end

  @doc """
  Create specified name multiple Nodes without namespace.
  This function calls `create_nodes_with_namespace/6` with node_namespace = ''.
  """
  @spec create_nodes(context(), charlist(), integer(), integer(), (list() -> list())) ::
          {:ok, [node_identifier :: charlist()]} | :error
  def create_nodes(context, node_name, num_node, queue_length \\ 1, change_order \\ & &1) do
    create_nodes_with_namespace(context, node_name, '', num_node, queue_length, change_order)
  end

  @doc """
  Create specified name multiple Nodes with specified node namespace.
  """
  @spec create_nodes_with_namespace(
          context(),
          charlist(),
          charlist(),
          integer(),
          integer(),
          (list() -> list())
        ) :: {:ok, [node_identifier :: charlist()]}
  def create_nodes_with_namespace(
        context,
        node_name,
        node_namespace,
        num_node,
        queue_length \\ 1,
        change_order \\ & &1
      ) do
    GenServer.call(
      ResourceServer,
      {:create_nodes,
       {context, node_name, node_namespace, num_node, {queue_length, change_order}}}
    )
  end

  @doc """
  Create a specified name `Rclex.Timer` and a Supervisor which supervise the timer.
  This function calls `create_timer_with_limit/7` with limit = 0(no limit).
  """
  @spec create_timer(function(), any(), integer(), charlist(), integer(), (list() -> list())) ::
          {:ok, timer_identifier :: String.t()}
  def create_timer(
        call_back,
        args,
        time,
        timer_name,
        queue_length \\ 1,
        change_order \\ & &1
      ) do
    create_timer_with_limit(call_back, args, time, timer_name, 0, queue_length, change_order)
  end

  @doc """
  Create a specified name `Rclex.Timer` and a Supervisor which supervise the timer.
  Arguments are used to configure `Rclex.Timer`.

  ## Arguments

  * callback: callback function
  * args: callback arguments
  * time: periodic time, milliseconds
  * timer_name: timer name
  * limit: limit of execution times, 0 means no limit
  * queue_length: executor's queue length
  * change_order: function which change the order of job
  """
  @spec create_timer_with_limit(
          function(),
          any(),
          integer(),
          charlist(),
          integer(),
          integer(),
          (list() -> list())
        ) :: {:ok, timer_identifier :: String.t()}
  def create_timer_with_limit(
        call_back,
        args,
        time,
        timer_name,
        limit,
        queue_length \\ 1,
        change_order \\ & &1
      ) do
    GenServer.call(
      ResourceServer,
      {:create_timer, {call_back, args, time, timer_name, limit, {queue_length, change_order}}}
    )
  end

  @doc """
  Stop `Rclex.Timer` named with timer_identifier by stopping its Supervisor.
  """
  @spec stop_timer(timer_identifier :: String.t()) :: :ok | :error
  def stop_timer(timer_identifier) do
    GenServer.call(ResourceServer, {:stop_timer, timer_identifier})
  end

  @doc """
  Finish `Rclex.Node` named with node_identifier by stopping its Supervisor.
  """
  @spec finish_node(node_identifier :: charlist()) :: :ok | :error
  def finish_node(node_identifier) do
    GenServer.call(ResourceServer, {:finish_node, node_identifier})
  end

  @doc """
  Call `finish_node/1` for each node_identifier_list element.
  """
  @spec finish_nodes([node_identifier :: charlist()]) :: list()
  def finish_nodes(node_identifier_list) do
    Enum.map(
      node_identifier_list,
      fn node_identifier -> GenServer.call(ResourceServer, {:finish_node, node_identifier}) end
    )
  end

  @impl GenServer
  def handle_call(
        {:create_nodes, {context, node_name, namespace, num_node, executor_settings}},
        _from,
        {resources}
      ) do
    node_identifier_list =
      0..(num_node - 1)
      |> Enum.map(fn node_no ->
        get_identifier(namespace, node_name) ++ Integer.to_charlist(node_no)
      end)

    if Enum.any?(node_identifier_list, &Map.has_key?(resources, &1)) do
      # 同名のノードがすでに存在しているときはエラーを返す
      {:reply, :error, {resources}}
    else
      nodes_list =
        node_identifier_list
        # id -> {node, id}
        |> Enum.map(fn node_identifier ->
          {call_nifs_rcl_node_init(
             Nifs.rcl_get_zero_initialized_node(),
             node_identifier,
             namespace,
             context,
             Nifs.rcl_node_get_default_options()
           ), node_identifier}
        end)
        # {node, id} -> {id, {:ok, pid}}
        |> Enum.map(fn {node, node_identifier} ->
          {node_identifier,
           Supervisor.start_link(
             [{Rclex.Node, {node, node_identifier, executor_settings}}],
             strategy: :one_for_one
           )}
        end)
        # {id, {:ok, pid}} -> {id, pid}
        |> Enum.map(fn {node_identifier, {:ok, pid}} ->
          {node_identifier, %{supervisor_id: pid}}
        end)

      new_resources = for {k, v} <- nodes_list, into: resources, do: {k, v}

      {:reply, {:ok, node_identifier_list}, {new_resources}}
    end
  end

  @impl GenServer
  def handle_call(
        {:create_timer, {call_back, args, time, timer_name, limit, executor_settings}},
        _from,
        {resources}
      ) do
    timer_identifier = "#{timer_name}/Timer"

    if Map.has_key?(resources, {"", timer_identifier}) do
      # 同名のノードがすでに存在しているときはエラーを返す
      {:reply, {:error, timer_name}}
    else
      children = [
        {Rclex.Timer, {call_back, args, time, timer_name, limit, executor_settings}}
      ]

      opts = [strategy: :one_for_one]
      {:ok, pid} = Supervisor.start_link(children, opts)
      new_resources = Map.put_new(resources, timer_identifier, %{supervisor_id: pid})
      {:reply, {:ok, timer_identifier}, {new_resources}}
    end
  end

  @impl GenServer
  def handle_call({:finish_node, node_identifier}, _from, {resources}) do
    case Map.fetch(resources, node_identifier) do
      {:ok, node} ->
        GenServer.call({:global, node_identifier}, :finish_node)

        {:ok, supervisor_id} = Map.fetch(node, :supervisor_id)

        Supervisor.stop(supervisor_id)

        # node情報削除
        new_resources = Map.delete(resources, node_identifier)
        Logger.debug("finish node: #{node_identifier}")

        {:reply, :ok, {new_resources}}

      :error ->
        {:reply, :error, {resources}}
    end
  end

  @impl GenServer
  def handle_call({:stop_timer, timer_identifier}, _from, {resources}) do
    case Map.fetch(resources, timer_identifier) do
      {:ok, timer} ->
        {:ok, supervisor_id} = Map.fetch(timer, :supervisor_id)

        Supervisor.stop(supervisor_id)

        # timer情報削除
        new_resources = Map.delete(resources, timer_identifier)
        Logger.debug("finish timer: #{timer_identifier}")
        {:reply, :ok, {new_resources}}

      :error ->
        {:reply, :error, {resources}}
    end
  end

  @impl GenServer
  def handle_info({_, _, reason}, state) do
    Logger.debug(reason)
    {:noreply, state}
  end

  @spec get_identifier(charlist(), charlist()) :: charlist()
  defp get_identifier(node_namespace, node_name) do
    if node_namespace != '' do
      # FIXME: 'node name must not contain characters other than alphanumerics or '_'
      "#{node_namespace}/#{node_name}" |> String.to_charlist()
    else
      node_name
    end
  end

  @spec call_nifs_rcl_node_init(any(), charlist(), charlist(), context(), any()) :: any()
  defp call_nifs_rcl_node_init(node, node_name, node_namespace, context, node_op) do
    if node_namespace != '' do
      Nifs.rcl_node_init(node, node_name, node_namespace, context, node_op)
    else
      Nifs.rcl_node_init_without_namespace(node, node_name, context, node_op)
    end
  end
end
