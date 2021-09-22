num_node = 1
context = Rclex.rclexinit
node_list = Rclex.create_nodes(context, 'test_pub_node', num_node)
publisher_list = Rclex.create_publishers(node_list, 'testtopic', :single)
msg_list = Rclex.initialize_msgs(1, :string)
data = "test"
n = 1
Enum.map(0..(n - 1), fn index ->
          Rclex.setdata(Enum.at(msg_list, index), data, :string)
        end)
Rclex.Publisher.publish(publisher_list, msg_list)




# Rclex.Publisher.publish_once(Enum.at(publisher_list, 0), Enum.at(msg_list, 0), Rclex.Nifs.create_pub_alloc())
# pub_id_list = publisher_list
#               |> Enum.map(fn pub -> Rclex.Publisher.start_link(pub) end)
#               |> Enum.map(fn {:ok, id} -> id end)
# Rclex.Executor.publish(pub_id_list, msg_list)




# defmodule Call do
# def callback(publisher_list) do
#     # Create messages according to the number of publishers.
#     n = length(publisher_list)
#     msg_list = Rclex.initialize_msgs(n, :string)
#     data = "hello,world"
#     IO.puts("publish message:#{data}")
#     # Set data.
#     Enum.map(0..(n - 1), fn index ->
#       Rclex.setdata(Enum.at(msg_list, index), data, :string)
#     end)

#     # Publish topics.
#     # IO.puts("pub time:#{:os.system_time(:microsecond)}")
#     Rclex.Publisher.publish(publisher_list, msg_list)
#   end
# end

# num_node = 1
# context = Rclex.rclexinit()
# node_list = Rclex.create_nodes(context, 'test_pub_node', num_node)
# publisher_list = Rclex.create_publishers(node_list, 'testtopic', :single)
# {sv, child} = Rclex.Timer.timer_start(publisher_list, 500, &Call.callback/1, 100)

# # In timer_start/2,3, the number of times that the timer process is executed can be set.
# # If it is not set, the timer process loops forever.
# Rclex.waiting_input(sv, child)

# Rclex.publisher_finish(publisher_list, node_list)

# Rclex.node_finish(node_list)

# Rclex.shutdown(context)