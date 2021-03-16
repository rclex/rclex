context = Rclex.rclexinit
node_list = Rclex.create_nodes(context,'test_pub_node',5)

publisher_list = Rclex.create_publishers(node_list,'testtopic',:single)
node_list_2 = Rclex.create_nodes(context,'test_sub_node',5) 
subscriber_list = Rclex.create_subscribers(node_list_2, 'testtopic', :single)
node = hd node_list

names_and_types = Rclex.rcl_get_topic_names_and_types(node,Rclex.rcl_get_default_allocator,false)

Enum.map(names_and_types, fn name -> IO.puts(name) end)
Rclex.publisher_finish(publisher_list,node_list)
Rclex.subscriber_finish(subscriber_list,node_list_2)
Rclex.node_finish(node_list)   
Rclex.node_finish(node_list_2)