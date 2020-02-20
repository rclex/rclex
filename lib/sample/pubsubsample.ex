defmodule PubSubSample do
  @moduledoc """
    Publisher,Subscriber両方の役割をノードにもたせるサンプル
  """
  def main(num_node) do
    context = RclEx.rclexinit
    node_list = RclEx.create_nodes(context,'test_pubsub_node',num_node)                          #|> node_list,
    subscriber_list = RclEx.create_subscribers(node_list,'testtopic_sub',:single)                           #|> subscribers_list
    {sub_sv,sub_child} = RclEx.Subscriber.subscribe_start(subscriber_list,context,&sub_callback/1)

    publisher_list = RclEx.create_publishers(node_list,'testtopic_pub',:single)
    {pub_sv,pub_child} = RclEx.Timer.timer_start(publisher_list,1000,&pub_callback/1,100)

    RclEx.waiting_input(pub_sv,pub_child)
    RclEx.waiting_input(sub_sv,sub_child)
    RclEx.publisher_finish(publisher_list,node_list)
    RclEx.subscriber_finish(subscriber_list,node_list)
    RclEx.node_finish(node_list)
    RclEx.shutdown(context)
  end
  def pub_callback(publisher_list) do
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

  #コールバック関数を記述
  def sub_callback(msg) do
    received_msg = RclEx.readdata_string(msg)
    IO.puts "received msg:#{received_msg}"
  end

end
