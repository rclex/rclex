defmodule PubSample do
  @moduledoc """
    任意の数のPublisherを作成するサンプル
  """
  def pubmain(num_node) do
    context = RclEx.rclexinit
    node_list = RclEx.create_nodes(context,'test_pub_node',num_node)
    publisher_list = RclEx.create_publishers(node_list,'testtopic',:single)
    {sv,child} = RclEx.Timer.timer_start(publisher_list,500,&callback/1,100)
    #timer_start/2,3ではタイマー処理を何回行うかの設定が可能．回数を指定しなければ永遠にループを続ける
    RclEx.waiting_input(sv,child)
    
    RclEx.publisher_finish(publisher_list,node_list)
    
    RclEx.node_finish(node_list)
    
    RclEx.shutdown(context)
    
  end
  @doc """
    ユーザー定義のタイマーイベントコールバック関数
  """
  def callback(publisher_list) do
    #publisherのかずに応じてメッセージを作成する
    n = length(publisher_list)
    msg_list = RclEx.initialize_msgs(n,:string)
    data = "hello,world"
    IO.puts "publish message:#{data}"
    #データをセット
    Enum.map(0..n-1,fn(index)->
      RclEx.setdata(Enum.at(msg_list,index),data,:string)
    end)

    #出版
    #IO.puts("pub time:#{:os.system_time(:microsecond)}")
    RclEx.Publisher.publish(publisher_list,msg_list)
  end
end
