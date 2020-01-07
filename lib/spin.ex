defmodule RclEx.Spin do
  require RclEx.Macros
  require IEx

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
  def subscription_start(takemsg,sub,msginfo,sub_alloc,callback) do
    Task.async(fn -> subtaskspin(takemsg,sub,msginfo,sub_alloc,callback) end)
  end

  def pubtaskspin(pubmsg,pub,pub_alloc,callback) do
    case RclEx.rcl_publish(pub,pubmsg,pub_alloc) do
      {RclEx.Macros.rcl_ret_ok,_,_} -> callback.(pubmsg)
      {RclEx.Macros.rcl_ret_publisher_invalid,_,_} -> IO.puts "Publisher is invalid"
      {RclEx.Macros.rmw_ret_invalid_argument,_,_} -> IO.puts "invalid argument is contained"
      {RclEx.Macros.rcl_ret_error,_,_} -> IO.puts "unspecified error"
      {_,_,_} -> IO.puts "What!?"
    end
    :timer.sleep(5000)
    pubtaskspin(pubmsg,pub,pub_alloc,callback)
  end

  def publisher_start(pubmsg,pub,pub_alloc,callback) do
    pub_pid = Task.async(fn -> pubtaskspin(pubmsg,pub,pub_alloc,callback) end)
  end
end