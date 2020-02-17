defmodule Multitopic do
  @moduledoc """
    publisher-topic-subscriberのペアを任意の数だけ作成するサンプル
    create_publishersの引数に:multiを指定
  """
  def pubmain(num_node) do
    RclEx.rclexinit
    |> RclEx.create_nodes('test_pub_node',num_node)   #|> node_list
    |> RclEx.create_publishers('topic',:multi)        #|> publisher_list
    |> RclEx.Timer.timer_start(1000,&callback_pub/1,10)
  end
  @doc """
    ユーザー定義のタイマーイベントコールバック関数
  """
  def callback_pub(publisher_list) do
    #publisherのかずに応じてメッセージを作成する
    n = length(publisher_list)
    msg_list = RclEx.initialize_msgs(n,:string)
    {:ok,data} = File.read("/home/imanishi/rclex/textdata/hello.txt")
    #データをセット
    Enum.map(0..n-1,fn(index)->
      RclEx.setdata(Enum.at(msg_list,index),data,:string)
    end)
    #出版
    RclEx.Publisher.publish(publisher_list,msg_list)
  end

  def submain(num_node) do
    #ノードをnode_count分だけ作成
    context = RclEx.rclexinit()                                                     #|> context
    RclEx.create_nodes(context,'test_sub_node',num_node)                          #|> node_list,
    |> RclEx.create_subscribers('topic',:multi)                              #|> subscribers_list
    |> RclEx.Subscriber.subscribe_start(context,&callback_sub/1)
  end
  #コールバック関数を記述
  def callback_sub(msg) do
    {:ok,received_msg} = RclEx.readdata_string(msg)
    IO.puts "received msg:#{received_msg}"
  end
end
