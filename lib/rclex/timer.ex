defmodule Rclex.Timer do
  require Rclex.Macros
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
    T.B.A
  """

  def start_link({callback, args, time, timer_name}) do
    GenServer.start_link(__MODULE__, {callback, args, time, timer_name},
      name: {:global, "#{timer_name}/Timer"}
    )
  end

  def start_link({callback, args, time, timer_name, limit}) do
    GenServer.start_link(__MODULE__, {callback, args, time, timer_name, limit},
      name: {:global, "#{timer_name}/Timer"}
    )
  end

  def start_link({callback, args, time, timer_name, :executor_setting, executor_settings}) do
    GenServer.start_link(
      __MODULE__,
      {callback, args, time, timer_name, :executor_setting, executor_settings},
      name: {:global, "#{timer_name}/Timer"}
    )
  end

  def start_link({callback, args, time, timer_name, limit, :executor_setting, executor_settings}) do
    GenServer.start_link(
      __MODULE__,
      {callback, args, time, timer_name, limit, :executor_setting, executor_settings},
      name: {:global, "#{timer_name}/Timer"}
    )
  end

  # callback: コールバック関数
  # args: コールバック関数に渡す引数
  # time: 周期。ミリ秒で指定。
  # count: 現在何回目の実行か。初期値は0。
  # limit: 最大実行回数
  # queue_length: エグゼキュータのキューの長さ
  # change_order: ジョブの実行順序を変更する関数
  def init({callback, args, time, timer_name}) do
    job_children = [
      {Rclex.JobQueue, {timer_name}},
      {Rclex.JobExecutor, {timer_name}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, job_supervisor_id} = Supervisor.start_link(job_children, opts)

    children = [
      {Rclex.TimerLoop, {timer_name, time}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, loop_supervisor_id} = Supervisor.start_link(children, opts)
    {:ok, {callback, args, time, loop_supervisor_id, job_supervisor_id}}
  end

  def init({callback, args, time, timer_name, limit}) do
    job_children = [
      {Rclex.JobQueue, {timer_name}},
      {Rclex.JobExecutor, {timer_name}}
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

  def init({callback, args, time, timer_name, :executor_setting, {queue_length}}) do
    job_children = [
      {Rclex.JobQueue, {timer_name, queue_length}},
      {Rclex.JobExecutor, {timer_name}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, job_supervisor_id} = Supervisor.start_link(job_children, opts)

    children = [
      {Rclex.TimerLoop, {timer_name, time}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, loop_supervisor_id} = Supervisor.start_link(children, opts)
    {:ok, {callback, args, time, loop_supervisor_id, job_supervisor_id}}
  end

  def init({callback, args, time, timer_name, :executor_setting, {queue_length, change_order}}) do
    job_children = [
      {Rclex.JobQueue, {timer_name, queue_length}},
      {Rclex.JobExecutor, {timer_name, change_order}}
    ]

    Logger.debug(change_order.("timer"))

    opts = [strategy: :one_for_one]
    {:ok, job_supervisor_id} = Supervisor.start_link(job_children, opts)

    children = [
      {Rclex.TimerLoop, {timer_name, time}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, loop_supervisor_id} = Supervisor.start_link(children, opts)
    {:ok, {callback, args, time, loop_supervisor_id, job_supervisor_id}}
  end

  def init({callback, args, time, timer_name, limit, :executor_setting, {queue_length}}) do
    job_children = [
      {Rclex.JobQueue, {timer_name, queue_length}},
      {Rclex.JobExecutor, {timer_name}}
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

  def init(
        {callback, args, time, timer_name, limit, :executor_setting, {queue_length, change_order}}
      ) do
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

  def handle_cast({:execute, _}, {callback, args, time, loop_supervisor_id, job_supervisor_id}) do
    callback.(args)
    {:noreply, {callback, args, time, loop_supervisor_id, job_supervisor_id}}
  end

  def handle_cast({:stop, _}, {callback, args, time, loop_supervisor_id, job_supervisor_id}) do
    Logger.info("the number of timer loop reaches limit")
    Supervisor.stop(loop_supervisor_id)
    {:stop, :normal, {callback, args, time, loop_supervisor_id, job_supervisor_id}}
  end

  def handle_call(:stop, _from, {callback, args, time, loop_supervisor_id, job_supervisor_id}) do
    Logger.debug("stop timer")
    Supervisor.stop(loop_supervisor_id)
    {:reply, :ok, {callback, args, time, loop_supervisor_id, job_supervisor_id}}
  end

  def terminate(:normal, _) do
    Logger.debug("terminate timer")
  end
end
