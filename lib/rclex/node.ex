defmodule Rclex.Node do
    alias Rclex.Nifs
    require Rclex.Macros
    require Logger
    use GenServer, restart: :transient

    def start_link({node, node_name}) do
        GenServer.start_link(__MODULE__, {node, node_name}, name: {:global, node_name})
    end

    def start_link(node, node_name, node_namespace) do
        name = node_namespace ++ '/' ++ node_name
        GenServer.start_link(__MODULE__, {node, name}, name: {:global, name})
    end

    def init({node, name}) do
        {:ok, {node, name, %{}}}
    end

    def single_create_subscriber(node_identifier, topic_name) do
        GenServer.call({:global, node_identifier}, {:create_subscriber, node_identifier, topic_name})
    end

    # def handle_call(:create_publisher, _, state) do

    # end

    def finish_subscriber({sub_node, topic_name, :sub}) do
        {:ok, _} = GenServer.call({:global, sub_node}, {:finish_subscriber, topic_name})
        {:ok, "finish_subscribe"}
    end

    def subscribe_stop({sub_node, topic_name, :sub}) do
        {:ok, _} = GenServer.call({:global, sub_node}, {:subscribe_stop, topic_name})
        {:ok, "stop subscribe"}
    end

    def handle_call({:create_subscriber, node_identifier, topic_name}, _, {node, name, supervisor_ids}) do
        subscriber = Nifs.rcl_get_zero_initialized_subscription()
        sub_op = Nifs.rcl_subscription_get_default_options()
        sub = Nifs.rcl_subscription_init(subscriber, node, topic_name, sub_op)
        children = [
            {Rclex.Subscriber, {sub, node_identifier ++ '/' ++ topic_name}}
        ]
        opts = [strategy: :one_for_one]
        {:ok, id} = Supervisor.start_link(children, opts)
        # TODO: has_keyで見る
        new_supervisor_ids = Map.put_new(supervisor_ids, {:sub, topic_name}, id)
        {:reply, {:ok, {node_identifier, topic_name, :sub}}, {node, name, new_supervisor_ids}}
    end

    def handle_call({:finish_subscriber, topic_name}, _from, {node, name, supervisor_ids}) do
        Logger.debug("finish subscriber")
        # n = length(sub_list)

        {:ok, supervisor_id} = Map.fetch(supervisor_ids, {:sub, topic_name})

        # Enum.map(0..(n - 1), fn index ->
        # Nifs.rcl_subscription_fini(Enum.at(sub_list, index), Enum.at(node_list, index))
        # end)

        sub_key = name ++ '/' ++ topic_name

        {:ok, text} = GenServer.call({:global, sub_key}, {:finish_subscriber, node})

        Logger.debug(text)

        Supervisor.stop(supervisor_id)

        new_supervisor_ids = Map.delete(supervisor_ids, topic_name)

        {:reply, {:ok, "finish supervisor"}, {node, name, new_supervisor_ids}}
    end

    def handle_call({:subscribe_stop, topic_name}, _from, {node, name, supervisor_ids}) do
        sub_identifier = name ++ '/' ++ topic_name
        # replyしないと怒られるのでtextを渡している
        {:ok, text} = GenServer.call({:global, name ++ '/' ++ topic_name}, :subscribe_stop)
        Logger.debug(text)
        {:reply, {:ok, sub_identifier}, {node, name, supervisor_ids}}
    end
end