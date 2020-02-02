defmodule RclEx.Publisher do
  require RclEx.Macros

  def publish_once(pub,pubmsg,pub_alloc) do
    case RclEx.rcl_publish(pub,pubmsg,pub_alloc) do
      {RclEx.Macros.rcl_ret_ok,_,_} ->
        IO.puts("pub time:#{:os.system_time(:microsecond)}")

      {RclEx.Macros.rcl_ret_publisher_invalid,_,_} -> IO.puts "Publisher is invalid"
      {RclEx.Macros.rmw_ret_invalid_argument,_,_} -> IO.puts "invalid argument is contained"
      {RclEx.Macros.rcl_ret_error,_,_} -> IO.puts "unspecified error"
      {_,_,_} -> do_nothing()
    end
  end


  def publish(publisher_list,pubmsg_list) do
    {:ok,supervisor} = Task.Supervisor.start_link()
    Enum.map(0..length(publisher_list)-1,fn(index)->
      #  Task.async(fn -> sub_spin(RclEx.create_empty_msgInt16(),subscriber,RclEx.create_msginfo(),RclEx.create_sub_alloc(),callback) end)
         Task.Supervisor.start_child(supervisor,RclEx.Publisher,:publish_once,
         [Enum.at(publisher_list,index),Enum.at(pubmsg_list,index),RclEx.create_pub_alloc()],
         [restart: :transient])
      #Task.async(fn ->
        #publoop(Enum.at(publisher_list,index),Enum.at(pubmsg_list,index),RclEx.create_pub_alloc(),callback)
    end)
  end
  defp do_nothing do
    #noop
  end
end

#defmodule Example do
#  def sum(a,b) do
#    a + b
#  end
#  def add(a,b) do
#    sum(a,b)
#  end
#end
