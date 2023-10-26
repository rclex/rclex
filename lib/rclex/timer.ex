defmodule Rclex.Timer do
  @moduledoc false

  use GenServer, restart: :temporary

  require Logger

  alias Rclex.Nif

  def start_link(args) do
    timer_name = Keyword.fetch!(args, :timer_name)
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    GenServer.start_link(__MODULE__, args, name: name(timer_name, name, namespace))
  end

  def name(timer_name, name, namespace \\ "/") do
    {:global, {:timer, timer_name, name, namespace}}
  end

  # callbacks
  def init(args) do
    Process.flag(:trap_exit, true)

    context = Keyword.fetch!(args, :context)
    period_ms = Keyword.fetch!(args, :period_ms)
    callback = Keyword.fetch!(args, :callback)
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    0 = :erlang.fun_info(callback)[:arity]

    clock = Nif.rcl_clock_init!()
    timer = Nif.rcl_timer_init!(context, clock, period_ms)
    wait_set = Nif.rcl_wait_set_init_timer!(context)

    send(self(), :tick)

    {:ok,
     %{
       callback: callback,
       name: name,
       namespace: namespace,
       clock: clock,
       timer: timer,
       wait_set: wait_set
     }}
  end

  def terminate(reason, state) do
    Nif.rcl_wait_set_fini!(state.wait_set)
    Nif.rcl_timer_fini!(state.timer)
    Nif.rcl_clock_fini!(state.clock)

    Logger.debug("#{__MODULE__}: #{inspect(reason)} #{Path.join(state.namespace, state.name)}")
  end

  def handle_info(:tick, state) do
    case Nif.rcl_wait_timer!(state.wait_set, 1000, state.timer) do
      :ok ->
        if Nif.rcl_timer_is_ready!(state.timer) do
          {:ok, _pid} =
            Task.Supervisor.start_child(
              {:via, PartitionSupervisor, {Rclex.TaskSupervisors, self()}},
              fn -> state.callback.() end
            )

          :ok = Nif.rcl_timer_call!(state.timer)
        end

      :timeout ->
        nil
    end

    send(self(), :tick)

    {:noreply, state}
  end
end
