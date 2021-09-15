defmodule Rclex.Subscriber do
  alias Rclex.Nifs
  require Rclex.Macros
  require Logger
  use GenServer

  @moduledoc """
  T.B.A
  """

  @doc """
    subscriberプロセスの生成
  """
  def start_link(sub, context, call_back) do
    GenServer.start_link(__MODULE__, {sub, context, call_back})
  end

  @doc """
    subscriberプロセスの初期化
    subscriberとコールバック関数を状態として持つ。
  """
  def init({sub, context, call_back}) do
    Rclex.Loop.start_link(self(), sub, context, call_back)
    {:ok, {sub, call_back}} 
  end

  @doc """
    コールバックの実行
  """
  def handle_cast({:execute, msg}, {sub, call_back}) do
    call_back.(msg)
    {:noreply, {sub, call_back}}
  end

  defp do_nothing do
  end
end
