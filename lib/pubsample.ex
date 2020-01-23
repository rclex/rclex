defmodule PubSample do

  def pubmain(num_node) do
    #rclcppでいうとこのstd::make_shared<std_msgs::msg::String>()を,作りたいpubノード分だけ作る
    msg_list = RclEx.initialize_msgs(:string,num_node)
    data="hello,world"
    Enum.map(0..num_node-1,fn(index)->
      RclEx.setdata_string(Enum.at(msg_list,index),data)
    end)

    RclEx.rclexinit                                   #|> context
    |> RclEx.create_nodes('test_pub_node',num_node)   #|> node_list
    |> RclEx.create_publishers('testtopic')           #|> publisher_list
    |> RclEx.Spin.pub_task_start(msg_list,&callback/1)


  end
  @doc """
    ユーザー定義のコールバック関数
  """
  def callback(pubmsg) do
    #{:ok,text} = RclEx.readdata_string(pubmsg)
    #IO.puts "text:#{text}"
    #charlistがtextに入る
    #String.length(text) |> IO.puts
    #text = Integer.to_charlist(1+(hd(text)-48))++tl(text)
    #RclEx.setdata_string(pubmsg,text)
  end
end
