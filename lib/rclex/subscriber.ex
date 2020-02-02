
defmodule RclEx.Subscriber do
  require Logger
  require RclEx.Macros
  require IEx
  use Timex
  #pubtaskspinとpubtaskspinはパターンマッチで選べるようにできれば...


  defp do_nothing do
    #noop
  end

  def sub_spin_once(takemsg,sub,msginfo,sub_alloc,callback) do
    case RclEx.rcl_take(sub,takemsg,msginfo,sub_alloc) do
      {RclEx.Macros.rcl_ret_ok,_,_,_} ->
        #IO.puts "sub ok"
        callback.(takemsg)
      {RclEx.Macros.rcl_ret_subscription_invalid,_,_,_} ->
        IO.puts "subscription invalid"
      {RclEx.Macros.rcl_ret_subscription_take_failed,_,_,_} ->
        do_nothing()
    end
  end
  def sub_spin(takemsg,sub,msginfo,sub_alloc,callback) do
    sub_spin_once(takemsg,sub,msginfo,sub_alloc,callback)
    #:timer.sleep(10)
    sub_spin(takemsg,sub,msginfo,sub_alloc,callback)
  end
   def sub_task_start(subscriber_list,callback) do
    #1 process manages all nodes
    {:ok,supervisor} = Task.Supervisor.start_link()
    Enum.map(subscriber_list,fn(subscriber)->
    #  Task.async(fn -> sub_spin(RclEx.create_empty_msgInt16(),subscriber,RclEx.create_msginfo(),RclEx.create_sub_alloc(),callback) end)
       Task.Supervisor.start_child(supervisor,RclEx.Subscriber,:sub_spin,
       [RclEx.initialize_msg(),subscriber,RclEx.create_msginfo(),RclEx.create_sub_alloc(),callback],
       [restart: :transient])
    end)
  end
end
