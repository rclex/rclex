defmodule Rclex.Subscription do
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
    {:global, {:subscription, message_type, topic_name, name, namespace}}
  end

  # callbacks

  def init(args) do
    Process.flag(:trap_exit, true)

    context = Keyword.fetch!(args, :context)
    node = Keyword.fetch!(args, :node)
    message_type = Keyword.fetch!(args, :message_type)
    topic_name = Keyword.fetch!(args, :topic_name)
    callback = Keyword.fetch!(args, :callback)
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)
    qos = Keyword.get(args, :qos, Rclex.QoS.profile_default())

    1 = :erlang.fun_info(callback)[:arity]

    type_support = apply(message_type, :type_support!, [])
    subscription = Nif.rcl_subscription_init!(node, type_support, ~c"#{topic_name}", qos)

    {:ok,
     %{
       context: context,
       node: node,
       message_type: message_type,
       topic_name: topic_name,
       callback: callback,
       name: name,
       namespace: namespace,
       subscription: subscription,
       callback_resource: nil
     }, {:continue, nil}}
  end

  def terminate(reason, state) do
    Nif.rcl_subscription_clear_message_callback!(state.subscription, state.callback_resource)
    Nif.rcl_subscription_fini!(state.subscription, state.node)

    Logger.debug("#{__MODULE__}: #{inspect(reason)} #{Path.join(state.namespace, state.name)}")
  end

  def handle_continue(nil, state) do
    callback_resource = Nif.rcl_subscription_set_on_new_message_callback!(state.subscription)
    {:noreply, %{state | callback_resource: callback_resource}}
  end

  def handle_info({:new_message, number_of_events}, state) when number_of_events > 0 do
    for _ <- 1..number_of_events do
      case apply(state.message_type, :take!, [state.subscription]) do
        :subscription_take_failed ->
          Logger.debug("#{__MODULE__}: take failed but no error occurred in the middleware")

        message_struct ->
          {:ok, _pid} =
            Task.Supervisor.start_child(
              {:via, PartitionSupervisor, {Rclex.TaskSupervisors, self()}},
              fn -> state.callback.(message_struct) end
            )
      end
    end

    {:noreply, state}
  end
end
