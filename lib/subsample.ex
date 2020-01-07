#ユーザーが使うような書き方を模索
defmodule SubSample do
  require RclEx.Macros
  
  def submain do
    init_op_sub = RclEx.rcl_get_zero_initialized_init_options()
    #RclEx.rcl_init_options_init(init_op_sub)
    sub_context = RclEx.rcl_get_zero_initialized_context()
    #RclEx.rcl_init_with_null(init_op_sub,sub_context)
    #RclEx.rcl_init_options_fini(init_op_sub)
    
    RclEx.rclexinit(init_op_sub,sub_context)
    
    subnode = RclEx.rcl_get_zero_initialized_node()
    subnode_op = RclEx.rcl_node_get_default_options()
    RclEx.rcl_node_init(subnode,'test_sub_node','test_sub_namespace_',sub_context,subnode_op)

    #typesupport = RclEx.get_message_type_from_std_msgs_msg_Int16 ---->nif_sub_init内で直接やってる
    sub = RclEx.rcl_get_zero_initialized_subscription()
    IO.inspect(sub)
    sub_op = RclEx.rcl_subscription_get_default_options()

    RclEx.rcl_subscription_init(sub,subnode,'testtopic',sub_op)

    takemsg = RclEx.create_empty_msgInt16()
    msginfo = RclEx.create_msginfo()
    sub_alloc = RclEx.create_sub_alloc()
    IO.inspect(msginfo)
    IO.inspect(sub_alloc)
    worker_info = RclEx.Spin.subscription_start(takemsg,sub,msginfo,sub_alloc,&callback/1)
    
    #{:ok,agent} = RclEx.subscription_start(fn -> {:substart,sub,msginfo,sub_alloc} end)
    #RclEx.spin(subagent,takemsg,&callback/1)
  end
  #コールバック関数を記述
  defp callback(msg) do
    IO.puts "enter callback"
    {:ok,received_msg} = RclEx.print_msg(msg)
    IO.puts "received msg:#{received_msg}"
    IO.puts "finish callback"
  end

end