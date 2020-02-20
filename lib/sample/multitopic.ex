defmodule Multitopic do
  @moduledoc """
    publisher-topic-subscriberのペアを任意の数だけ作成するサンプル
    create_publishersの引数に:multiを指定
    別VMでそれぞれ出版購読させることを想定
  """
  def pubmain(num_node) do
    context = RclEx.rclexinit
    node_list = RclEx.create_nodes(context,'test_pub_node',num_node)
    publisher_list = RclEx.create_publishers(node_list,'topic',:multi)
    {sv,child} = RclEx.Timer.timer_start(publisher_list,1000,&timer_callback/1,100)

    RclEx.waiting_input(sv,child)
    RclEx.publisher_finish(publisher_list,node_list)
    RclEx.node_finish(node_list)
    RclEx.shutdown(context)
  end
  @doc """
    ユーザー定義のタイマーイベントコールバック関数
  """
  def timer_callback(publisher_list) do

    n = length(publisher_list)
    msg_list = RclEx.initialize_msgs(n,:string)
    data = "hello,world"
    #データをセット
    Enum.map(0..n-1,fn(index)->
      RclEx.setdata(Enum.at(msg_list,index),data,:string)
    end)
    #出版
    RclEx.Publisher.publish(publisher_list,msg_list)
  end

  def submain(num_node) do

    context = RclEx.rclexinit()
    node_list = RclEx.create_nodes(context,'test_sub_node',num_node)
    subscriber_list = RclEx.create_subscribers(node_list,'topic',:multi)
    {sv,child} = RclEx.Subscriber.subscribe_start(subscriber_list,context,&callback_sub/1)
    RclEx.waiting_input(sv,child)
    RclEx.subscriber_finish(subscriber_list,node_list)
    RclEx.node_finish(node_list)
    RclEx.shutdown(context)
  end
  #コールバック関数を記述
  def callback_sub(msg) do
    received_msg = RclEx.readdata_string(msg)
    IO.puts "received msg:#{received_msg}"
  end
end
