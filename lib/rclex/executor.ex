defmodule Rclex.Executor do
    alias Rclex.Nifs
    require Rclex.Macros
    require Logger
    use GenServer, restart: :transient

    def start_link(_) do
        GenServer.start_link(__MODULE__, {}, name: Executor)
    end

    def init(_) do
        {:ok, %{}} 
    end

    @doc """
        購読開始の準備
        監視されるタスクを生成し，購読ループ処理を実行させる
    """
    def subscribe_start(sub_list, context, call_back) do
        Logger.debug("subscribe start")
        id_list = sub_list
                |> Enum.map(fn sub -> GenServer.call(Executor, {:sub_start_link, sub, context, call_back}) end )
        Logger.debug("subscribe start 2")
        {:ok, id_list}
    end

    @doc """
        プロセスを終了する
    """
    def stop_process(id_list) do
        Logger.debug("start stop process")
        Enum.map(id_list, fn id -> GenServer.stop({:global, id}, :normal, 3000) end)
        Logger.debug("end subscribe")
        {:ok, "stop process"}
    end

    def stop_subscribe(sub_id_list) do
        Logger.debug("start stop subscribe")
        Enum.map(sub_id_list, fn id -> GenServer.cast(id, :stop_loop) end)
        Logger.debug("end loop")
        {:ok, "stop subscribe"}
    end

    def publish(id_list, data) do
        n = length(id_list)
        pubmsg_list = Rclex.initialize_msgs(n, :string)
        Enum.map(0..(n - 1), fn index ->
                  Rclex.setdata(Enum.at(pubmsg_list, index), data, :string)
                end)
        Enum.map(0..(n - 1), fn index ->
            GenServer.cast(Enum.at(id_list, index), {:publish, Enum.at(pubmsg_list, index)})
        end)
    end

    @doc """
        ノードをひとつだけ作成
        名前空間の有無を設定可能
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
    """
    def create_nodes(context, node_name, namespace, num_node) do
        GenServer.call(Executor, {:create_nodes, {context, node_name, namespace, num_node}})
    end

    def create_nodes(context, node_name, num_node) do
        GenServer.call(Executor, {:create_nodes, {context, node_name, num_node}})
    end

    def single_create_subscriber(sub_node, topic_name) do
        subscriber = Nifs.rcl_get_zero_initialized_subscription()
        sub_op = Nifs.rcl_subscription_get_default_options()
        Nifs.rcl_subscription_init(subscriber, sub_node, topic_name, sub_op)
        subscriber
      end
    
    def handle_cast({:subscribe, {id, msg}}, state) do
        GenServer.cast(id, {:execute, msg})
        {:noreply, state}
    end

    def handle_call({:create_singlenode, {context, node_name, node_namespace}}, _from, supervisor_ids ) do
        if Map.has_key?(supervisor_ids, {node_namespace, node_name}) do
            # 同名のノードがすでに存在しているときはエラーを返す
             {:reply, {:error, node_name}}
        else
            node = Nifs.rcl_get_zero_initialized_node()
            node_op = Nifs.rcl_node_get_default_options()
            Nifs.rcl_node_init(node, node_name, node_namespace, context, node_op)
            children =[
                {Rclex.Node, {node, node_name, node_namespace}}
            ]
            opts = [strategy: :one_for_one]
            {:ok, pid} = Supervisor.start_link(children, opts)
            new_supervisor_ids = Map.put_new(supervisor_ids, {node_namespace, node_name}, pid)
            {:reply, {:ok, node_name}, new_supervisor_ids}
        end
    end

    def handle_call({:create_singlenode, {context, node_name}}, _from, supervisor_ids ) do
        if Map.has_key?(supervisor_ids, {"", node_name}) do
            # 同名のノードがすでに存在しているときはエラーを返す
             {:reply, {:error, node_name}}
        else
            node = Nifs.rcl_get_zero_initialized_node()
            node_op = Nifs.rcl_node_get_default_options()
            Nifs.rcl_node_init_without_namespace(node, node_name, context, node_op)
            children =[
                {Rclex.Node, {node, node_name}}
            ]
            opts = [strategy: :one_for_one]
            {:ok, pid} = Supervisor.start_link(children, opts)
            new_supervisor_ids = Map.put_new(supervisor_ids, {"", node_name}, pid)
            {:reply, {:ok, node_name}, new_supervisor_ids}
        end
    end

    def handle_call({:create_nodes, context, node_name, namespace, num_node}, _from, supervisor_ids) do
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
                [strategy: :one_for_one]
            )
            end
        )
        |> Enum.map(fn {:ok, pid} -> pid end)

        for n <- 0..(num_node - 1) do
            node_name = Enum.at(name_list, n)
            pid = Enum.at(id_list, n)
            supervisor_ids = Map.put_new(supervisor_ids, {namespace, node_name}, pid)
        end
        {:reply, {:ok, name_list}, supervisor_ids}
    end

    def handle_call({:create_nodes, context, node_name, num_node}, _from, supervisor_ids) do
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
                [strategy: :one_for_one]
            )
            end
        )
        |> Enum.map(fn {:ok, pid} -> pid end)

        for n <- 0..(num_node - 1) do
            node_name = Enum.at(name_list, n)
            pid = Enum.at(id_list, n)
            supervisor_ids = Map.put_new(supervisor_ids, {"", node_name}, pid)
        end
        {:reply, {:ok, name_list}, supervisor_ids}
    end

    # def handle_call({:sub_start_link, sub, context, call_back},_from, state) do
    #     {:ok, pid} = Rclex.Subscriber.start_link(sub, context, call_back)
    #     {:reply, pid, state}
    # end

    def handle_info({_, _, reason}, state) do
        Logger.debug(reason)
        {:noreply, state}
    end
end