defmodule RclEx.Spin do
  require RclEx.Macros
  require IEx
  def taskspin(takemsg,sub,msginfo,sub_alloc,callback) do
    case RclEx.rcl_take(sub,takemsg,msginfo,sub_alloc) do
      {RclEx.Macros.rcl_ret_ok,_,_,_} -> 
        IO.puts "subscribe success"
        callback.(takemsg)
      {RclEx.Macros.rcl_ret_subscription_take_failed,_,_,_} ->
        IO.puts "rcl_take nothing"
      end
    :timer.sleep(1000)
    taskspin(takemsg,sub,msginfo,sub_alloc,callback)
  end
  def subscription_start(takemsg,sub,msginfo,sub_alloc,callback) do
    Task.async(fn -> taskspin(takemsg,sub,msginfo,sub_alloc,callback) end)
  end

end