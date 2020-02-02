defmodule SubSample do

  def submain(num_node) do
    #ノードをnode_count分だけ作成
    context = RclEx.rclexinit                                                       #|> context
    RclEx.create_nodes(context,'test_sub_node',num_node)                          #|> node_list,
    #|> RclEx.create_nodes('test_sub_node','test_sub_namespace_',num_node)
    |> RclEx.create_subscribers('testtopic')                              #|> subscribers_list
    #|> RclEx.Subscriber.sub_task_start(&callback/1)
    |> RclEx.Wait.subscribe_start(context,&callback/1)
    #typesupport = RclEx.get_message_type_from_std_msgs_msg_Int16 ---->nif_sub_init内で直接やってる
  end
  #コールバック関数を記述
  def callback(msg) do
    #{:ok,file} = File.open "receivedmsg.txt",[:write]
    #{:ok,received_msg} = RclEx.readdata_string(msg)
    #File.write("receivedmsg.txt",received_msg,[:append])
    #IO.binwrite(file,received_msg,[:append])
    #File.close(file)

    #IO.puts "received msg:#{received_msg}"
  end

end
