defmodule SubSample do
  @moduledoc """
    任意の数のサブスクライバを作成するサンプル
  """
  def submain(num_node) do
    #ノードをnum_nodeに指定した数だけ作成
    context = RclEx.rclexinit
    RclEx.create_nodes(context,'test_sub_node',num_node)         #|> node_list
    |> RclEx.create_subscribers('testtopic',:single)             #|> subscribers_list
    |> RclEx.Subscriber.subscribe_start(context,&callback/1)
  end
  #コールバック関数を記述
  def callback(msg) do
    #IO.puts("sub time:#{:os.system_time(:microsecond)}")
    {:ok,received_msg} = RclEx.readdata_string(msg)
    IO.puts "received msg:#{received_msg}"
  end

end
