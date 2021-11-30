defmodule Rclex.TimerLoop do
  require Rclex.Macros
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
      T.B.A
  """

  def start_link({timer_id, time}) do
    GenServer.start_link(__MODULE__, {timer_id, time})
  end

  def start_link({timer_id, time, limit}) do
    GenServer.start_link(__MODULE__, {timer_id, time, limit})
  end

  def init({timer_id, time}) do
    GenServer.cast(self(), :loop)
    {:ok, {timer_id, time}}
  end

  def init({timer_id, time, limit}) do
    GenServer.cast(self(), :loop)
    {:ok, {timer_id, time, 0, limit}}
  end

  def handle_cast(:loop, state) do
    {:noreply, state, {:continue, :loop}}
  end

  def handle_continue(:loop, {timer_id, time}) do
    GenServer.cast(JobQueue, {:push, {timer_id, :execute, {}}})

    receive do
      :stop ->
        {:stop, :normal, {timer_id, time}}
    after
      # Optional timeout
      time ->
        {:noreply, {timer_id, time}, {:continue, :loop}}
    end
  end

  def handle_continue(:loop, {timer_id, time, count, limit}) do
    count = count + 1

    if count > limit do
      GenServer.cast(JobQueue, {:push, {timer_id, :stop, {}}})
      {:noreply, :normal, {}}
    else
      GenServer.cast(JobQueue, {:push, {timer_id, :execute, {}}})
      # timeはミリ秒
      receive do
        :stop ->
          {:stop, :normal, {}}
      after
        # Optional timeout
        time ->
          {:noreply, {timer_id, time, count, limit}, {:continue, :loop}}
      end
    end
  end

  def terminate(:normal, _) do
    Logger.debug("timer_loop process killed : normal")
  end

  def terminate(:shutdown, _) do
    Logger.debug("timer_loop process killed : shutdown")
  end
end
