defmodule Rclex.Publisher do
  @moduledoc false

  use GenServer, restart: :temporary

  require Logger

  alias Rclex.Nif

  def start_link(args) do
    message_type = Keyword.fetch!(args, :message_type)
    topic_name = Keyword.fetch!(args, :topic_name)
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    GenServer.start_link(__MODULE__, args, name: name(message_type, topic_name, name, namespace))
  end

  def name(message_type, topic_name, name, namespace \\ "/") do
    {:global, {:publisher, message_type, topic_name, name, namespace}}
  end

  def publish(%message_type{} = message, topic_name, name, namespace \\ "/") do
    server = name(message_type, topic_name, name, namespace)
    GenServer.call(server, {:publish, message})
  end

  # callbacks

  def init(args) do
    Process.flag(:trap_exit, true)

    node = Keyword.fetch!(args, :node)
    message_type = Keyword.fetch!(args, :message_type)
    topic_name = Keyword.fetch!(args, :topic_name)
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    type_support = apply(message_type, :type_support!, [])
    publisher = Nif.rcl_publisher_init!(node, type_support, ~c"#{topic_name}")

    {:ok,
     %{
       node: node,
       publisher: publisher,
       message_type: message_type,
       topic_name: topic_name,
       name: name,
       namespace: namespace
     }}
  end

  def terminate(reason, state) do
    Nif.rcl_publisher_fini!(state.publisher, state.node)

    Logger.debug("#{__MODULE__}: #{inspect(reason)} #{Path.join(state.namespace, state.name)}")
  end

  def handle_call({:publish, data}, _from, %{message_type: message_type} = state) do
    message = apply(message_type, :create!, [])

    try do
      :ok = apply(message_type, :set!, [message, data])
      :ok = Nif.rcl_publish!(state.publisher, message)
    after
      :ok = apply(message_type, :destroy!, [message])
    end

    {:reply, :ok, state}
  end
end
