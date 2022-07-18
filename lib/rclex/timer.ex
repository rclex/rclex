defmodule Rclex.Timer do
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
  For periodically execution of jobs.
  This module supervises two supervisor tree, one is for job control, one is for timer loop.

  There are 4 GenServers including this module itself.
  They work together as shown below.
     
      +-------------+
      | Rclex.Timer <-----------------------------+
      +-----+-------+                             |
            |                                     | GenServer.cast to Rclex.Timer
            |                                     |
            |                            +--------+----------+
            |                    +-------+ Rclex.JobExecutor |
            |                    |       +--------^----------+
            |                    |                |
            +------Supervisor----+                | GenServer.cast to JobExecutor
            |                    |                |
            |                    |       +--------+----------+
            |                    +-------+ Rclex.JobQueue    |
            |                            +--------^----------+
            |                                     |
            |                                     | GenServer.cast to JobQueue
            |                                     |
            |                            +--------+----------+
            +------Supervisor------------+ Rclex.TimerLoop   |
                                         +-------------------+

  * This module stored `callback` and `args` to be executed.
  * `Rclex.TimerLoop` triggers the execution according to the `time` [msec].
    * The number of executions is limited by `limit`.
  """

  @doc false
  @spec start_link(
          {function(), any(), integer(), charlist(), integer(), {integer(), (list() -> list())}}
        ) :: GenServer.on_start()
  def start_link({callback, args, time, timer_name, limit, executor_settings}) do
    GenServer.start_link(
      __MODULE__,
      {callback, args, time, timer_name, limit, executor_settings},
      name: {:global, "#{timer_name}/Timer"}
    )
  end

  @doc """
  Initialize GenServer


  ## Arguments in tuple

  * callback: callback function
  * args: callback arguments
  * time: execution interval time, milli seconds
  * limit: execution times limit
  * queue_length: queue length for `Rclex.JobQueue`
  * change_order: change order function for `Rclex.JobExecutor`
  """
  @impl GenServer
  @spec init({
          callback :: function(),
          args :: any(),
          time :: integer(),
          timer_name :: charlist(),
          limit :: integer,
          {queue_length :: integer(), change_order :: (list() -> list())}
        }) :: {:ok, tuple()}
  def init({callback, args, time, timer_name, limit, {queue_length, change_order}}) do
    job_children = [
      {Rclex.JobQueue, {timer_name, queue_length}},
      {Rclex.JobExecutor, {timer_name, change_order}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, job_supervisor_id} = Supervisor.start_link(job_children, opts)

    children = [
      {Rclex.TimerLoop, {timer_name, time, limit}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, loop_supervisor_id} = Supervisor.start_link(children, opts)
    {:ok, {callback, args, time, loop_supervisor_id, job_supervisor_id}}
  end

  @impl GenServer
  def handle_cast({:execute, _}, {callback, args, time, loop_supervisor_id, job_supervisor_id}) do
    callback.(args)
    {:noreply, {callback, args, time, loop_supervisor_id, job_supervisor_id}}
  end

  @impl GenServer
  def handle_cast({:stop, _}, {callback, args, time, loop_supervisor_id, job_supervisor_id}) do
    Logger.info("the number of timer loop reaches limit")
    Supervisor.stop(loop_supervisor_id)
    {:stop, :normal, {callback, args, time, loop_supervisor_id, job_supervisor_id}}
  end

  @impl GenServer
  def handle_call(:stop, _from, {callback, args, time, loop_supervisor_id, job_supervisor_id}) do
    Logger.debug("stop timer")
    Supervisor.stop(loop_supervisor_id)
    {:reply, :ok, {callback, args, time, loop_supervisor_id, job_supervisor_id}}
  end

  @impl GenServer
  def terminate(:normal, _) do
    Logger.debug("terminate timer")
  end
end
