defmodule RclEx.Wait do
  require RclEx.Macros
  require IEx

  def each_subscribe(sub,callback) do
      msg = RclEx.initialize_msg()
      msginfo = RclEx.create_msginfo()
      sub_alloc = RclEx.create_sub_alloc()
      case RclEx.rcl_take(sub,msg,msginfo,sub_alloc) do
        {RclEx.Macros.rcl_ret_ok,_,_,_} ->
          IO.puts("sub time:#{:os.system_time(:microsecond)}")
          callback.(msg)
        {RclEx.Macros.rcl_ret_subscription_invalid,_,_,_} ->
          IO.puts "subscription invalid"
        {RclEx.Macros.rcl_ret_subscription_take_failed,_,_,_} ->
          do_nothing()
      end
  end
  def subscribe_loop(wait_set,sub_list,callback) do
    RclEx.rcl_wait_set_clear(wait_set)

    Enum.map(sub_list,fn(sub)->RclEx.rcl_wait_set_add_subscription(wait_set,sub) end)

    #wait_setからsubのリストを取得する
    waitset_sublist = RclEx.get_sublist_from_waitset(wait_set)

    RclEx.rcl_wait(wait_set,1000)
    {:ok,sv} = Task.Supervisor.start_link()
    #wait_setのインデックスでcheckしてreadyであればsubごとに購読を始める

    Enum.map(0..length(waitset_sublist)-1,fn(index) ->
      if RclEx.check_subscription(wait_set,index) do
        Task.Supervisor.start_child(sv,RclEx.Wait,:each_subscribe,
        [Enum.at(waitset_sublist,index),callback],[restart: :transient])
      end
#
    end)
    subscribe_loop(wait_set,sub_list,callback)
  end
  #waitset
  def subscribe_start(sub_list,context,callback) do
    wait_set =
    RclEx.rcl_get_zero_initialized_wait_set()
    |> RclEx.rcl_wait_set_init(length(sub_list),0,0,0,0,0,context,RclEx.rcl_get_default_allocator())
    {:ok,supervisor} = Task.Supervisor.start_link()
    Task.Supervisor.start_child(supervisor,RclEx.Wait,:subscribe_loop,
    [wait_set,sub_list,callback],[restart: :transient])
  end

  defp do_nothing do
  end
end

