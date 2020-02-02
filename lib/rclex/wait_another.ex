defmodule RclEx.WaitAnother do
    require RclEx.Macros

    def sub_loop(subscription,context,callback) do
      wait_set = RclEx.rcl_get_zero_initialized_wait_set()
      RclEx.rcl_wait_set_init(wait_set,1,0,0,0,0,0,context,RclEx.rcl_get_default_allocator())
      RclEx.rcl_wait_set_clear(wait_set)
      RclEx.rcl_wait_set_add_subscription(wait_set,subscription)
      RclEx.rcl_wait(wait_set,1000)
      #check_subscription
      if RclEx.check_subscription(wait_set,0) do
       msg = RclEx.initialize_msg()
       msginfo = RclEx.create_msginfo()
       sub_alloc = RclEx.create_sub_alloc()
       case RclEx.rcl_take(subscription,msg,msginfo,sub_alloc) do
        {RclEx.Macros.rcl_ret_ok,_,_,_} ->
          callback.(msg)
        {RclEx.Macros.rcl_ret_subscription_invalid,_,_,} ->
          IO.puts "subscription invalid"
        {RclEx.Macros.rcl_ret_subscription_take_failed,_,_,_} ->
          do_nothing()
      end
    end
      sub_loop(subscription,context,wait_set)
    end
    #waitset
    def wait_start(sub_list,context,callback) do

      Enum.map(sub_list,fn(sub) -> sub_loop(sub,context,callback) end)
    end

    defp do_nothing do
      IO.puts "do_nothing"
    end

end
