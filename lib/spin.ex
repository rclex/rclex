defmodule RclEx.Spin do
  require RclEx.Macros
  require IEx

  #pubtaskspinとpubtaskspinはパターンマッチで選べるようにできれば...
  def singlepublisher_spin(pub,pubmsg,callback) do
    pub_alloc = RclEx.create_pub_alloc()
    pub_pid = Task.async(fn -> pub_spin(pub,pubmsg,pub_alloc,callback) end)
  end

  def pub_spin_once(pub,pubmsg,pub_alloc,callback) do
    case RclEx.rcl_publish(pub,pubmsg,pub_alloc) do
      {RclEx.Macros.rcl_ret_ok,_,_} -> callback.(pubmsg)
      {RclEx.Macros.rcl_ret_publisher_invalid,_,_} -> IO.puts "Publisher is invalid"
      {RclEx.Macros.rmw_ret_invalid_argument,_,_} -> IO.puts "invalid argument is contained"
      {RclEx.Macros.rcl_ret_error,_,_} -> IO.puts "unspecified error"
      {_,_,_} -> do_nothing()
    end
    :timer.sleep(2000)
  end
  
  def pub_spin(pub,pubmsg,pub_alloc,callback) do
    pub_spin_once(pub,pubmsg,pub_alloc,callback)
    pub_spin(pub,pubmsg,pub_alloc,callback)
  end

  def pub_task_start(publisher_list,pubmsg_list,callback) do
    {:ok,supervisor} = Task.Supervisor.start_link()
    Enum.map(0..length(publisher_list)-1,fn(index)->
      #  Task.async(fn -> sub_spin(RclEx.create_empty_msgInt16(),subscriber,RclEx.create_msginfo(),RclEx.create_sub_alloc(),callback) end)
         Task.Supervisor.start_child(supervisor,RclEx.Spin,:pub_spin,
         [Enum.at(publisher_list,index),Enum.at(pubmsg_list,index),RclEx.create_pub_alloc(),callback],
         [restart: :transient])  
      #Task.async(fn -> 
        #publoop(Enum.at(publisher_list,index),Enum.at(pubmsg_list,index),RclEx.create_pub_alloc(),callback)  
    end)
  end
  
  defp do_nothing do
    #noop
  end

  #def subloop(takemsg,sub,msginfo,sub_alloc,callback) do
  #  case RclEx.rcl_take(sub,takemsg,msginfo,sub_alloc) do
  #    {RclEx.Macros.rcl_ret_ok,_,_,_} -> 
  #      callback.(takemsg)
  #    {RclEx.Macros.rcl_ret_subscription_take_failed,_,_,_} ->
  #      do_nothing()
  #    end
  #  #:timer.sleep(1000)
  #  subloop(takemsg,sub,msginfo,sub_alloc,callback)
  #end
  #def subscriber_spin(subscriber_list,callback) do
  #  Enum.map(subscriber_list,fn(subscriber)->
  #    Task.async(fn -> subloop(RclEx.create_empty_msgInt16(),subscriber,RclEx.create_msginfo(),RclEx.create_sub_alloc(),callback) end)
  #  end)
  #end

#----------------subscriberのspinを書き直す---------------------
  def sub_spin_once(takemsg,sub,msginfo,sub_alloc,callback) do
    case RclEx.rcl_take(sub,takemsg,msginfo,sub_alloc) do
      {RclEx.Macros.rcl_ret_ok,_,_,_} -> 
        callback.(takemsg)
      {RclEx.Macros.rcl_ret_subscription_invalid,_,_,} ->
        IO.puts "subscription invalid"
      {RclEx.Macros.rcl_ret_subscription_take_failed,_,_,_} ->
        do_nothing()
    end
  end
  def sub_spin(takemsg,sub,msginfo,sub_alloc,callback) do
    sub_spin_once(takemsg,sub,msginfo,sub_alloc,callback)
    sub_spin(takemsg,sub,msginfo,sub_alloc,callback)
  end
  def sub_task_start(subscriber_list,callback) do
    #1 process manages all nodes
    {:ok,supervisor} = Task.Supervisor.start_link()
    Enum.map(subscriber_list,fn(subscriber)->
    #  Task.async(fn -> sub_spin(RclEx.create_empty_msgInt16(),subscriber,RclEx.create_msginfo(),RclEx.create_sub_alloc(),callback) end)
       Task.Supervisor.start_child(supervisor,RclEx.Spin,:sub_spin,
       [RclEx.initialize_msg(),subscriber,RclEx.create_msginfo(),RclEx.create_sub_alloc(),callback],
       [restart: :transient])
    end)
    
  end

end