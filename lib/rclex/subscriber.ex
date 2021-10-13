defmodule Rclex.Subscriber do
  alias Rclex.Nifs
  require Rclex.Macros
  require Logger
  use GenServer

  @moduledoc """
  T.B.A
  """

  ## TODO: ここでsubscriberを生成、トピック名を覚えておく

  # @doc """
  #   subscriberプロセスの生成
  # """
  # def start_link(sub, context, call_back) do
  #   Logger.debug("sub link start")
  #   GenServer.start_link(__MODULE__, {sub, context, call_back}, name: )
  # end

  @doc """
    subscriberプロセスの生成
  """
  def start_link({sub, process_name}) do
    Logger.debug("sub link start")
    GenServer.start_link(__MODULE__, sub, name: {:global, process_name})
  end

  # @doc """
  #   subscriberプロセスの初期化
  #   subscriberとコールバック関数を状態として持つ。
  #   同時に購読を開始する
  # """
  # def init({sub, context, call_back}) do
  #   children = [
  #     {Rclex.Loop, {self(), sub, context, call_back}}
  #   ]
  #   opts = [strategy: :one_for_one]
  #   {:ok, supervisor_id} = Supervisor.start_link(children, opts)
  #   {:ok, %{subscriber: sub, context: context, call_back: call_back, supervisor_id: supervisor_id}} 
  # end

  @doc """
    subscriberプロセスの初期化
    subscriberを状態として持つ。
  """
  def init(sub) do
    {:ok,  %{subscriber: sub}}
  end

  def subscribe_start({node_identifier, topic_name, :sub}, context, call_back) do
    sub_identifier = node_identifier ++ '/' ++ topic_name
    GenServer.cast({:global, sub_identifier}, {:subscribe_start, {context, call_back}})
  end

  def handle_cast({:subscribe_start, {context, call_back}}, state) do
    {:ok, sub} = Map.fetch(state, :subscriber)
    children = [
      {Rclex.SubLoop, {self(), sub, context, call_back}}
    ]
    opts = [strategy: :one_for_one]
    {:ok, supervisor_id} = Supervisor.start_link(children, opts)
    {:noreply, %{subscriber: sub, context: context, call_back: call_back, supervisor_id: supervisor_id}}
  end

  @doc """
    コールバックの実行
  """
  def handle_cast({:execute, msg}, state) do
    {:ok, call_back} = Map.fetch(state, :call_back)
    call_back.(msg)
    {:noreply, state}
  end

  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  def handle_call(:subscribe_stop, _from, state) do
    {:ok, supervisor_id} = Map.fetch(state, :supervisor_id)
    Supervisor.stop(supervisor_id)
    new_state = Map.delete(state, :supervisor_id)
    {:reply, {:ok, "stop_loop"}, new_state}
  end

  def handle_call({:finish_subscriber, node}, _from, state) do
    {:ok, sub} = Map.fetch(state, :subscriber)
    Nifs.rcl_subscription_fini(sub, node)
    Logger.debug("finish_subscriber")
    #{:stop, :normal, state}
    {:reply, {:ok, "subscriber process deleted"}, state}
  end

  def terminate(:normal, _) do
    Logger.debug("sub terminate")
  end

  # defp do_nothing do
  # end
end
