defmodule Rclex.TimerLoop do
  require Rclex.Macros
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
      T.B.A
  """

  def start_link({timer_name, time}) do
    GenServer.start_link(__MODULE__, {timer_name, time})
  end

  def start_link({timer_name, time, limit}) do
    GenServer.start_link(__MODULE__, {timer_name, time, limit})
  end

  def init({timer_name, time}) do
    GenServer.cast(self(), :loop)
    {:ok, {timer_name, time}}
  end

  def init({timer_name, time, limit}) do
    GenServer.cast(self(), :loop)
    {:ok, {timer_name, time, 0, limit}}
  end

  def handle_cast(:loop, state) do
    {:noreply, state, {:continue, :loop}}
  end

  def handle_continue(:loop, {timer_name, time}) do
    timer_id = {:global, "#{timer_name}/Timer"}
    GenServer.cast({:global, "#{timer_name}/JobQueue"}, {:push, {timer_id, :execute, {}}})

    receive do
      :stop ->
        {:stop, :normal, {timer_name, time}}
    after
      # Optional timeout
      time ->
        {:noreply, {timer_name, time}, {:continue, :loop}}
    end
  end

  def handle_continue(:loop, {timer_name, time, count, limit}) do
    timer_id = {:global, "#{timer_name}/Timer"}
    count = count + 1

    if count > limit do
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

  def terminate(:normal, _) do
    Logger.debug("timer_loop process killed : normal")
  end

  def terminate(:shutdown, _) do
    Logger.debug("timer_loop process killed : shutdown")
  end
end
