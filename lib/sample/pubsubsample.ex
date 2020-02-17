defmodule PubSubSample do
  @moduledoc """
    Publisher,Subscriber両方の役割をノードにもたせるサンプル
  """
  def main(num_node) do
    context = RclEx.rclexinit
    node_list = RclEx.create_nodes(context,'test_pubsub_node',num_node)                          #|> node_list,
    RclEx.create_subscribers(node_list,'testtopic_sub',:single)                           #|> subscribers_list
    |> RclEx.Subscriber.subscribe_start(context,&sub_callback/1)

    RclEx.create_publishers(node_list,'testtopic_pub',:single)
    |> RclEx.Timer.timer_start(1000,&pub_callback/1,50)
  end
  def pub_callback(publisher_list) do
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

  #コールバック関数を記述
  def sub_callback(msg) do
    {:ok,received_msg} = RclEx.readdata_string(msg)
    IO.puts "received msg:#{received_msg}"
  end

end
