defmodule PubSample do

  def pubmain do
    init_op_pub = RclEx.rcl_get_zero_initialized_init_options()
    #RclEx.rcl_init_options_init(init_op_sub)
    pub_context = RclEx.rcl_get_zero_initialized_context()
    #RclEx.rcl_init_with_null(init_op_sub,sub_context)
    #RclEx.rcl_init_options_fini(init_op_sub)
    
    RclEx.rclexinit(init_op_pub,pub_context)
    
    pubnode = RclEx.rcl_get_zero_initialized_node()
    pubnode_op = RclEx.rcl_node_get_default_options()
    RclEx.rcl_node_init(pubnode,'test_pub_node','test_pub_namespace_',pub_context,pubnode_op)
    pub = RclEx.rcl_get_zero_initialized_publisher()
    pub_op = RclEx.rcl_publisher_get_default_options()

    RclEx.rcl_publisher_init(pub,pubnode,'testtopic',pub_op)
    pub_alloc = RclEx.create_pub_alloc()
    pubmsg = RclEx.create_empty_msgInt16()
    RclEx.set_data(pubmsg,1)

    #RclEx.rcl_publish(pub,pubmsg,pub_alloc)

    publisher_info = RclEx.Spin.publisher_start(pubmsg,pub,pub_alloc,&callback/1)
    
  end

  def callback(pubmsg) do
    {:ok,number} = RclEx.read_data(pubmsg)
    IO.puts "pubilshed msg:#{number}"
    RclEx.set_data(pubmsg,number+1)
  end
end