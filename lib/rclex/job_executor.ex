defmodule Rclex.JobExecutor do
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
    T.B.A
  """

  # ジョブの実行順序をユーザーが設定できる
  # change_order関数を渡すことで順序を変えられる。change_order関数はjobのlistを引数にとってjobのlistを返す関数
  def start_link({target_identifier}) do
    GenServer.start_link(__MODULE__, {}, name: {:global, "#{target_identifier}/JobExecutor"})
  end

  def start_link({target_identifier, change_order}) do
    GenServer.start_link(__MODULE__, {change_order},
      name: {:global, "#{target_identifier}/JobExecutor"}
    )
  end

  @impl GenServer
  def init({}) do
    Logger.debug("JobExecutor start")
    {:ok, {}}
  end

  @impl GenServer
  def init({change_order}) do
    Logger.debug("JobExecutor start")
    {:ok, {change_order}}
  end

  @impl GenServer
  def handle_cast({:execute, job_queue}, {}) do
    :queue.to_list(job_queue)
    |> Enum.map(fn {key, action, args} -> GenServer.cast(key, {action, args}) end)

    {:noreply, {}}
  end

  @impl GenServer
  def handle_cast({:execute, job_queue}, {change_order}) do
    job_list = :queue.to_list(job_queue)

    change_order.(job_list)
    |> Enum.map(fn {key, action, args} -> GenServer.cast(key, {action, args}) end)

    {:noreply, {change_order}}
  end
end
