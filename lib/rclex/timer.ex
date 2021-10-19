defmodule Rclex.Timer do
  alias Rclex.Nifs
  require Rclex.Macros
  require Logger
  use GenServer, restart: :transient

  def start_link({callback, args, time}) do
    GenServer.start_link(__MODULE__, {callback, args, time})
  end

  def start_link({callback, args, time, limit}) do
    GenServer.start_link(__MODULE__, {callback, args, time, limit})
  end

  def start_link({callback, args, time, limit, name}) do
    GenServer.start_link(__MODULE__, {callback, args, time, limit}, name: name)
  end

  # callback: コールバック関数
  # args: コールバック関数に渡す引数
  # time: 周期。ミリ秒で指定。
  # count: 現在何回目の実行か。初期値は0。
  # limit: 最大実行回数
  def init({callback, args, time}) do
    GenServer.cast(self(), :loop)
    {:ok, {callback, args, time}}
  end

  def init({callback, args, time, limit}) do
    GenServer.cast(self(), :loop)
    {:ok, {callback, args, time, 0, limit}}
  end

  def handle_cast(:loop, state) do
    {:noreply, state, {:continue, :loop}}
  end

  def handle_continue(:loop, {callback, args, time}) do
    callback.(args)

    receive do
      :stop ->
        {:stop, :normal, {callback, args, time}}
    after
      # Optional timeout
      time ->
        {:noreply, {callback, args, time}, {:continue, :loop}}
    end
  end

  def handle_continue(:loop, {callback, args, time, count, limit}) do
    count = count + 1

    if count > limit do
      Logger.info("the number of timer loop reaches limit")
      {:stop, :normal, {}}
    else
      callback.(args)
      # timeはミリ秒
      receive do
        :stop ->
          {:stop, :normal, {callback, args, time}}
      after
        # Optional timeout
        time ->
          {:noreply, {callback, args, time, count, limit}, {:continue, :loop}}
      end
    end
  end
end
