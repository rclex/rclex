defmodule PubSample do

  def pubmain(node_count) do
    #rclcppでいうとこのstd::make_shared<std_msgs::msg::String>()を,作りたいpubノード分だけ作る
    msg_list = RclEx.initialize_msgs(:string,node_count)
    IO.inspect msg_list
    Enum.map(0..node_count-1,fn(index)->
      RclEx.setdata_string(Enum.at(msg_list,index),'helloworld'++Integer.to_charlist(index))
    end)
    #ノードをnode_count分だけ作成
    publisher_info
     = RclEx.rclexinit                                 #|> context
    |> RclEx.create_nodes('test_pub_node',node_count)  #|> node_list
    |> RclEx.create_publishers('testtopic')            #|> publisher_list 
    |> RclEx.Spin.pub_task_start(msg_list,&callback/1)
    
  end
  @doc """
    ユーザー定義のコールバック関数
  """
  def callback(pubmsg) do
    {:ok,text} = RclEx.readdata_string(pubmsg)
    IO.puts "pubilshed msg:#{text}"
    RclEx.setdata_string(pubmsg,text++' world')
  end
end