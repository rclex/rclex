defmodule RclEx.Timer do
  def create_wall_timer(publisher_list,time,callback,count) do
    count = count + 1
    if(count>100) do
      raise "100 published"
    end
    callback.(publisher_list)
    :timer.sleep(time)  #timeはミリ秒
    create_wall_timer(publisher_list,time,callback,count)

  end
end
