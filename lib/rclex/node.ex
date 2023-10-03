defmodule Rclex.Node do
  @moduledoc false

  use GenServer

  require Logger

  alias Rclex.Nif
  alias Rclex.EntitiesSupervisor, as: ES

  def start_link(args) do
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    GenServer.start_link(__MODULE__, args, name: name(name, namespace))
  end

  def name(name, namespace \\ "/") do
    {:global, {name, namespace}}
  end

  def start_publisher(message_type, topic_name, name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:start_publisher, message_type, topic_name})
  end

  def stop_publisher(message_type, topic_name, name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:stop_publisher, message_type, topic_name})
  end

  def start_subscription(callback, message_type, topic_name, name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:start_subscription, callback, message_type, topic_name})
  end

  def stop_subscription(message_type, topic_name, name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:stop_subscription, message_type, topic_name})
  end

  # callbacks

  def init(args) do
    Process.flag(:trap_exit, true)

    context = Keyword.fetch!(args, :context)
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    node = Nif.rcl_node_init!(context, ~c"#{name}", ~c"#{namespace}")

    {:ok, %{context: context, node: node, name: name, namespace: namespace}}
  end

  def terminate(reason, state) do
    Nif.rcl_node_fini!(state.node)

    Logger.debug("#{__MODULE__}: #{inspect(reason)} #{Path.join(state.namespace, state.name)}")
  end

  def handle_call({:start_publisher, message_type, topic_name}, _from, state) do
    return = ES.start_publisher(state.node, message_type, topic_name, state.name, state.namespace)

    {:reply, return, state}
  end

  def handle_call({:stop_publisher, message_type, topic_name}, _from, state) do
    return = ES.stop_publisher(message_type, topic_name, state.name, state.namespace)

    {:reply, return, state}
  end

  def handle_call({:start_subscription, callback, message_type, topic_name}, _from, state) do
    return =
      ES.start_subscription(
        state.context,
        state.node,
        callback,
        message_type,
        topic_name,
        state.name,
        state.namespace
      )

    {:reply, return, state}
  end

  def handle_call({:stop_subscription, message_type, topic_name}, _from, state) do
    return = ES.stop_subscription(message_type, topic_name, state.name, state.namespace)

    {:reply, return, state}
  end
end
