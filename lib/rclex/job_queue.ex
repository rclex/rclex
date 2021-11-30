defmodule Rclex.JobQueue do
  alias Rclex.Nifs
  require Rclex.Macros
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
    T.B.A
  """

  def start_link(_) do
    GenServer.start_link(__MODULE__, {}, name: JobQueue)
  end

  def init(_) do
    {:ok, :queue.new()}
  end

  def handle_cast({:push, job}, job_queue) do
    new_job_queue = :queue.in(job, job_queue)
    {:noreply, new_job_queue}
  end

  def handle_call(:pop, _from, job_queue) do
    if :queue.len(job_queue) > 0 do
      {{:value, job}, new_job_queue} = :queue.out(job_queue)
      {:reply, {:exist_job, job}, new_job_queue}
    else
      {:reply, {:no_job, {}}, job_queue}
    end
  end
end
