defmodule Rclex.JobExecutor do
  require Rclex.Macros
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
    T.B.A
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: JobExecutor)
  end

  def init(_) do
    GenServer.cast(self(), {:start_loop})
    Logger.debug("JobExecutor start")
    {:ok, {}}
  end

  def handle_cast({:start_loop}, state) do
    {:noreply, state, {:continue, :start_loop}}
  end

  def handle_continue(:start_loop, state) do
    {is_job, job} = GenServer.call(JobQueue, :pop)

    if is_job == :exist_job do
      GenServer.cast(Executor, {:execute, job})
    end

    receive do
      :stop ->
        {:stop, :normal, state}
    after
      # Optional timeout
      50 ->
        {:noreply, state, {:continue, :start_loop}}
    end
  end
end
