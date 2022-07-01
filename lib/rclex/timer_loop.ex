defmodule Rclex.TimerLoop do
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
  Pushes timer jobs to `Rclex.JobQueue`.
  """

  def start_link({timer_name, time, limit}) do
    GenServer.start_link(__MODULE__, {timer_name, time, limit})
  end

  @impl GenServer
  def init({timer_name, time, limit}) do
    GenServer.cast(self(), :loop)
    {:ok, {timer_name, time, _count = 0, limit}}
  end

  @impl GenServer
  def handle_cast(:loop, state) do
    {:noreply, state, {:continue, :loop}}
  end

  @impl GenServer
  def handle_continue(:loop, {timer_name, time, count, limit}) do
    timer_id = {:global, "#{timer_name}/Timer"}
    count = count + 1

    if limit != 0 && count > limit do
      GenServer.cast({:global, "#{timer_name}/JobQueue"}, {:push, {timer_id, :stop, {}}})
      {:noreply, :normal, {}}
    else
      GenServer.cast({:global, "#{timer_name}/JobQueue"}, {:push, {timer_id, :execute, {}}})
      # timeはミリ秒
      receive do
        :stop ->
          {:stop, :normal, {}}
      after
        # Optional timeout
        time ->
          {:noreply, {timer_name, time, count, limit}, {:continue, :loop}}
      end
    end
  end

  @impl GenServer
  def terminate(:normal, _) do
    Logger.debug("timer_loop process killed : normal")
  end

  @impl GenServer
  def terminate(:shutdown, _) do
    Logger.debug("timer_loop process killed : shutdown")
  end
end
