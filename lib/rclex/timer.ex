defmodule RclEx.Timer do
  @doc """
    タイマー処理関数
    create_wall_timer/3はループの上限つき
    上限後，例外処理が行われる．
    create_wall_timer/2はループの上限なし

  """
  def create_wall_timer(publisher_list,time,callback,count,limit) do
    count = count + 1
    if(count>limit) do
      raise "input times repeated"
    end
    callback.(publisher_list)
    :timer.sleep(time)  #timeはミリ秒
    create_wall_timer(publisher_list,time,callback,count,limit)

  end

  def create_wall_timer(publisher_list,time,callback) do
    callback.(publisher_list)
    :timer.sleep(time)  #timeはミリ秒
    create_wall_timer(publisher_list,time,callback)
  end

  @doc """
    タイマーによるループ処理を監視するためのスーパーバイザと
    実行タスクを生成
    timer_start/4はループの上限つき
    timer_start/3はループの上限なし
  """
  def timer_start(pub_list,time,callback,limit) do
    {:ok,sv} = Task.Supervisor.start_link()
    Task.Supervisor.start_child(sv,RclEx.Timer,:create_wall_timer,
    [pub_list,time,callback,0,limit],[restart: :transient])
  end
  def timer_start(pub_list,time,callback) do
    {:ok,sv} = Task.Supervisor.start_link()
    Task.Supervisor.start_child(sv,RclEx.Timer,:create_wall_timer,
    [pub_list,time,callback],[restart: :transient])
  end
end
