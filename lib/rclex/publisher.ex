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
    GenServer.call(name(message_type, topic_name, name, namespace), {:publish, message})
  end

  # callbacks

  def init(args) do
    Process.flag(:trap_exit, true)

    node = Keyword.fetch!(args, :node)
    message_type = Keyword.fetch!(args, :message_type)
    topic_name = Keyword.fetch!(args, :topic_name)
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)
    qos = Keyword.get(args, :qos, Rclex.QoS.profile_default())

    type_support = apply(message_type, :type_support!, [])
    publisher = Nif.rcl_publisher_init!(node, type_support, ~c"#{topic_name}", qos)

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
    apply(message_type, :publish!, [state.publisher, data])
    |> then(&{:reply, &1, state})
  end
end
