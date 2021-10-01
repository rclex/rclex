defmodule Rclex.Node do
    alias Rclex.Nifs
    require Rclex.Macros
    require Logger
    use GenServer, restart: :transient

    def start_link({node, node_name}) do
        GenServer.start_link(__MODULE__, node, name: {:global, node_name})
    end

    def start_link(node, node_name, node_namespace) do
        name = node_namespace ++ '/' ++ node_name
        GenServer.start_link(__MODULE__, node, name: {:global, name})
    end

    def init(node) do
        {:ok, {node, %{}}}
    end

    def single_create_subscriber(node_identifier, topic_name) do
        GenServer.call({:global, node_identifier}, {:create_subscriber, node_identifier, topic_name})
    end

    # def handle_call(:create_publisher, _, state) do

    # end

    def handle_call({:create_subscriber, node_identifier, topic_name}, _, {node, supervisor_ids}) do
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
        {:reply, {:ok, {node_identifier, topic_name, :sub}}, {node, new_supervisor_ids}}
    end

    def stop_subscribe({sub_node, topic_name, :sub}) do
        Logger.debug("start stop subscribe")
        GenServer.cast({:global, sub_node}, {:stop_subscribe, topic_name})
        Logger.debug("end loop")
        {:ok, "stop subscribe"}
    end

    def handle_cast({:stop_subscribe, topic_name}, {node, supervisor_ids}) do
        {:ok, supervisor_id} = Map.fetch(supervisor_ids, {:sub, topic_name})
        GenServer.cast(supervisor_id, :stop_loop)
        new_supervisor_ids = Map.delete(supervisor_ids, {:sub, topic_name})
        {:noreply, {node, new_supervisor_ids}}
    end
end