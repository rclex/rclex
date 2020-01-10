defmodule PubSample do

  def pubmain do
    node_count = 5
    #rclcppでいうとこのstd::make_shared<std_msgs::msg::Int16>()を,作りたいpubノード分だけ作る
    msg_list = RclEx.create_msgs(node_count)
    Enum.map(0..node_count-1,fn(index)->
      RclEx.set_data(Enum.at(msg_list,index),index)
    end)
    #ノードをnode_count分だけ作成
    publisher_info
     = RclEx.rclexinit                                                   #|> context
    |> RclEx.create_nodes('test_pub_node','test_pub_namespace_',node_count)  #|> node_list
    |> RclEx.create_publishers('testtopic')                              #|> publisher_list 
    |> RclEx.Spin.publisher_spin(msg_list,&callback/1)
    
  end
  @doc """
    ユーザー定義のコールバック関数
  """
  def callback(pubmsg) do
    {:ok,number} = RclEx.read_data(pubmsg)
    IO.puts "pubilshed msg:#{number}"
    RclEx.set_data(pubmsg,number+1)
  end
end