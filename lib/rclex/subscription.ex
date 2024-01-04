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
    qos = Keyword.get(args, :qos, Rclex.Qos.profile_default())

    1 = :erlang.fun_info(callback)[:arity]

    type_support = apply(message_type, :type_support!, [])
    subscription = Nif.rcl_subscription_init!(node, type_support, ~c"#{topic_name}", qos)
    wait_set = Nif.rcl_wait_set_init_subscription!(context)

    send(self(), :take)

    {:ok,
     %{
       node: node,
       message_type: message_type,
       topic_name: topic_name,
       callback: callback,
       name: name,
       namespace: namespace,
       subscription: subscription,
       wait_set: wait_set
     }}
  end

  def terminate(reason, state) do
    Nif.rcl_wait_set_fini!(state.wait_set)
    Nif.rcl_subscription_fini!(state.subscription, state.node)

    Logger.debug("#{__MODULE__}: #{inspect(reason)} #{Path.join(state.namespace, state.name)}")
  end

  def handle_info(:take, state) do
    case Nif.rcl_wait_subscription!(state.wait_set, 1000, state.subscription) do
      :ok ->
        message = apply(state.message_type, :create!, [])

        try do
          case Nif.rcl_take!(state.subscription, message) do
            :ok ->
              message_struct = apply(state.message_type, :get!, [message])

              {:ok, _pid} =
                Task.Supervisor.start_child(
                  {:via, PartitionSupervisor, {Rclex.TaskSupervisors, self()}},
                  fn -> state.callback.(message_struct) end
                )

            :error ->
              Logger.error("#{__MODULE__}: take failed but no error occurred in the middleware")
          end
        after
          :ok = apply(state.message_type, :destroy!, [message])
        end

      :timeout ->
        nil
    end

    send(self(), :take)

    {:noreply, state}
  end
end
