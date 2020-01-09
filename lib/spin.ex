defmodule RclEx.Spin do
  require RclEx.Macros
  require IEx

  #pubtaskspinとpubtaskspinはパターンマッチで選べるようにできれば...

  def pubtaskspin(pub,pubmsg,pub_alloc,callback) do
    case RclEx.rcl_publish(pub,pubmsg,pub_alloc) do
      {RclEx.Macros.rcl_ret_ok,_,_} -> callback.(pubmsg)
      {RclEx.Macros.rcl_ret_publisher_invalid,_,_} -> IO.puts "Publisher is invalid"
      {RclEx.Macros.rmw_ret_invalid_argument,_,_} -> IO.puts "invalid argument is contained"
      {RclEx.Macros.rcl_ret_error,_,_} -> IO.puts "unspecified error"
      {_,_,_} -> IO.puts "What!?"
    end
    :timer.sleep(2000)
    pubtaskspin(pub,pubmsg,pub_alloc,callback)
  end

  def subtaskspin(takemsg,sub,msginfo,sub_alloc,callback) do
    case RclEx.rcl_take(sub,takemsg,msginfo,sub_alloc) do
      {RclEx.Macros.rcl_ret_ok,_,_,_} -> 
        callback.(takemsg)
      {RclEx.Macros.rcl_ret_subscription_take_failed,_,_,_} ->
        IO.puts "take nothing"
      end
    :timer.sleep(1000)
    subtaskspin(takemsg,sub,msginfo,sub_alloc,callback)
  end
  
  def singlepublisher_start(pub,pubmsg,callback) do
    pub_alloc = RclEx.create_pub_alloc()
    pub_pid = Task.async(fn -> pubtaskspin(pub,pubmsg,pub_alloc,callback) end)
  end

  def publisher_start(publisher_list,pubmsg_list,callback) do
    Enum.map(0..length(publisher_list)-1,fn(index)-> 
      Task.async(fn -> 
        pubtaskspin(Enum.at(publisher_list,index),Enum.at(pubmsg_list,index),RclEx.create_pub_alloc(),callback) 
      end)  
    end)
  end

  def subscriber_start(subscriber_list,callback) do
    Enum.map(subscriber_list,fn(subscriber)->
      Task.async(fn -> subtaskspin(RclEx.create_empty_msgInt16(),subscriber,RclEx.create_msginfo(),RclEx.create_sub_alloc(),callback) end)
    end)
  end
end