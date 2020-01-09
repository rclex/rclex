#ユーザーが使うような書き方を模索
defmodule SubSample do
  require RclEx.Macros
  require IEx
  def submain do
    node_count = 1

    #ノードをnode_count分だけ作成
    subscriber_info
     = RclEx.rclexinit                                                       #|> context
    |> RclEx.create_nodes('test_sub_node','test_sub_namespace_',node_count)  #|> node_list
    |> RclEx.create_subscribers('testtopic')                                 #|> subscribers_list
    |> RclEx.Spin.subscriber_start(&callback/1)
    #typesupport = RclEx.get_message_type_from_std_msgs_msg_Int16 ---->nif_sub_init内で直接やってる
    
  end
  #コールバック関数を記述
  defp callback(msg) do
    {:ok,received_msg} = RclEx.read_data(msg)
    IO.puts "received msg:#{received_msg}"
  end

end