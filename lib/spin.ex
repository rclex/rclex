defmodule RclEx.Spin do
  require RclEx.Macros
  require IEx

  def subtaskspin(takemsg,sub,msginfo,sub_alloc,callback) do
    case RclEx.rcl_take(sub,takemsg,msginfo,sub_alloc) do
      {RclEx.Macros.rcl_ret_ok,_,_,_} -> 
        IO.puts "subscribe success"
        callback.(takemsg)
      {RclEx.Macros.rcl_ret_subscription_take_failed,_,_,_} ->
        IO.puts "rcl_take nothing"
      end
    :timer.sleep(1000)
    subtaskspin(takemsg,sub,msginfo,sub_alloc,callback)
  end
  def subscription_start(takemsg,sub,msginfo,sub_alloc,callback) do
    Task.async(fn -> subtaskspin(takemsg,sub,msginfo,sub_alloc,callback) end)
  end

  def pubtaskspin(pubmsg,pub,pub_alloc) do
    case RclEx.rcl_publish(pub,pubmsg,pub_alloc) do
      {RclEx.Macros.rcl_ret_ok,_,_} -> 
        {:ok,num} = RclEx.print_msg(pubmsg)
        IO.puts "published number:#{num}"
      {RclEx.Macros.rcl_ret_publisher_invalid,_,_} -> IO.puts "Publisher is invalid"
      {RclEx.Macros.rmw_ret_invalid_argument,_,_} -> IO.puts "invalid argument is contained"
      {RclEx.Macros.rcl_ret_error,_,_} -> IO.puts "unspecified error"
      {_,_,_} -> IO.puts "Why!?"
    end
    {:ok,current_number} = RclEx.print_msg(pubmsg)
    RclEx.set_data(pubmsg,current_number+1)
    :timer.sleep(2000)
    pubtaskspin(pubmsg,pub,pub_alloc)
  end

  def publisher_start(pubmsg,pub,pub_alloc) do
    Task.async(fn -> pubtaskspin(pubmsg,pub,pub_alloc) end)
  end
end