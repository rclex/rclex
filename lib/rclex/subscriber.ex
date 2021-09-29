defmodule Rclex.Subscriber do
  alias Rclex.Nifs
  require Rclex.Macros
  require Logger
  use GenServer

  @moduledoc """
  T.B.A
  """

  ## TODO: ここでsubscriberを生成、トピック名を覚えておく

  @doc """
    subscriberプロセスの生成
  """
  def start_link(sub, context, call_back) do
    Logger.debug("sub link start")
    GenServer.start_link(__MODULE__, {sub, context, call_back})
  end

  @doc """
    subscriberプロセスの初期化
    subscriberとコールバック関数を状態として持つ。
  """
  def init({sub, context, call_back}) do
    children = [
      {Rclex.Loop, {self(), sub, context, call_back}}
    ]
    opts = [strategy: :one_for_one, name: :sub_loop]
    {:ok, loop_id} = Supervisor.start_link(children, opts)
    {:ok, {sub, call_back, loop_id}} 
  end

  @doc """
    コールバックの実行
  """
  def handle_cast({:execute, msg}, {sub, call_back, loop_id}) do
    call_back.(msg)
    {:noreply, {sub, call_back, loop_id}}
  end

  def handle_cast(:stop, {sub, call_back, loop_id}) do
    {:stop, :normal, {sub, call_back, loop_id}}
  end

  def handle_cast(:stop_loop, {sub, call_back, loop_id}) do
    Logger.debug("stop_loop")
    Supervisor.stop(loop_id)
    {:noreply, {sub, call_back, loop_id}}
  end

  def terminate(:normal, {sub, call_back, loop_id}) do
    Logger.debug("sub terminate")
  end

  defp do_nothing do
  end
end
