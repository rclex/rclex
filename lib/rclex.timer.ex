defmodule RclEx.Timer do
  def create_wall_timer(publisher_list,time,callback) do
    callback.(publisher_list)
    :timer.sleep(time)  #timeはミリ秒
    create_wall_timer(publisher_list,time,callback)

  end
end
