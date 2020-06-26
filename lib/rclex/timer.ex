defmodule Rclex.Timer do
  @doc """
    タイマー処理関数
    timer_loop/3はループの上限つき
    上限後，例外処理が行われる．
    timer_loop/2はループの上限なし

  """
  def timer_loop(publisher_list, time, callback, count, limit) do
    count = count + 1

    if(count > limit) do
      raise "input times repeated"
    end

    callback.(publisher_list)
    # timeはミリ秒
    :timer.sleep(time)
    timer_loop(publisher_list, time, callback, count, limit)
  end

  def timer_loop(publisher_list, time, callback) do
    callback.(publisher_list)
    # timeはミリ秒
    :timer.sleep(time)
    timer_loop(publisher_list, time, callback)
  end

  @doc """
    タイマーによるループ処理を監視するためのスーパーバイザと
    実行タスクを生成
    timer_start/4はループの上限つき
    timer_start/3はループの上限なし
  """
  def timer_start(pub_list, time, callback, limit) do
    {:ok, sv} = Task.Supervisor.start_link()

    {:ok, child} =
      Task.Supervisor.start_child(
        sv,
        Rclex.Timer,
        :timer_loop,
        [pub_list, time, callback, 0, limit],
        restart: :transient
      )

    {sv, child}
  end

  def timer_start(pub_list, time, callback) do
    {:ok, sv} = Task.Supervisor.start_link()

    {:ok, child} =
      Task.Supervisor.start_child(sv, Rclex.Timer, :timer_loop, [pub_list, time, callback],
        restart: :transient
      )

    {sv, child}
  end

  @doc """
    タイマー処理の終了
    スーパバイザプロセスと実行タスクを停止する
  """
  def terminate_timer(sv, child) do
    Task.Supervisor.terminate_child(sv, child)
  end
end
