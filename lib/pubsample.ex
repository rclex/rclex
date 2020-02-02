defmodule PubSample do
  require IEx
  def pubmain(num_node) do
    #rclcppでいうとこのstd::make_shared<std_msgs::msg::String>()を,作りたいpubノード分だけ作る

    RclEx.rclexinit                                   #|> context
    |> RclEx.create_nodes('test_pub_node',num_node)   #|> node_list
    |> RclEx.create_publishers('testtopic')           #|> publisher_list
    |> RclEx.Timer.create_wall_timer(1000,&callback/1,0)  #コールバック関数とタイマー間隔を設定
  end
  @doc """
    ユーザー定義のタイマーイベントコールバック関数
  """
  def callback(publisher_list) do
    #publisherのかずに応じてメッセージを作成する
    n = length(publisher_list)
    msg_list = RclEx.initialize_msgs(n,:string)
    {:ok,data} = File.read("/home/imanishi/rclex/textdata/256byte.txt")
    #データをセット
    Enum.map(0..n-1,fn(index)->
      RclEx.setdata_string(Enum.at(msg_list,index),data)
    end)
    #出版
    RclEx.Publisher.publish(publisher_list,msg_list)
  end
end
