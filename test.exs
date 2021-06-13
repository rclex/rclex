context = Rclex.rclexinit
node_list = Rclex.create_nodes(context,'test_pub_node',5)

publisher_list = Rclex.create_publishers(node_list,'testtopic',:single)
node_list_2 = Rclex.create_nodes(context,'test_sub_node',5)
subscriber_list = Rclex.create_subscribers(node_list_2, 'testtopic', :single)
node = hd node_list

names_and_types = Rclex.rcl_get_topic_names_and_types(node,Rclex.rcl_get_default_allocator,false)

names = elem(names_and_types,0)
types = elem(names_and_types,1)

IO.inspect(names_and_types)
Enum.map(names, fn name -> IO.inspect(name) end)
Enum.map(types, fn name -> IO.inspect(name) end)

Rclex.publisher_finish(publisher_list,node_list)
Rclex.subscriber_finish(subscriber_list,node_list_2)
Rclex.node_finish(node_list)
Rclex.node_finish(node_list_2)
