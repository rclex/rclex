defmodule RclEx.Subscriber do
  require RclEx.Macros

  @doc """
    購読処理関数
    購読が正常に行われれば，引数に受け取っていたコールバック関数を実行
  """
  def each_subscribe(sub, callback) do
    if RclEx.check_subscription(sub) do
      msg = RclEx.initialize_msg()
      msginfo = RclEx.create_msginfo()
      sub_alloc = RclEx.create_sub_alloc()

      case RclEx.rcl_take(sub, msg, msginfo, sub_alloc) do
        {RclEx.Macros.rcl_ret_ok(), _, _, _} ->
          callback.(msg)

        {RclEx.Macros.rcl_ret_subscription_invalid(), _, _, _} ->
          IO.puts("subscription invalid")

        {RclEx.Macros.rcl_ret_subscription_take_failed(), _, _, _} ->
          do_nothing()
      end
    end
  end

  @doc """
    非同期購読ループ処理
    waitsetにsubscriberを登録後，
    出版通知が来れば購読タスクが生成されてそれぞれで購読する．
  """
  def subscribe_loop(wait_set, sub_list, callback) do
    RclEx.rcl_wait_set_clear(wait_set)
    # waitsetにサブスクライバを追加する
    Enum.map(sub_list, fn sub -> RclEx.rcl_wait_set_add_subscription(wait_set, sub) end)

    # wait_setからsubのリストを取りだす
    waitset_sublist = RclEx.get_sublist_from_waitset(wait_set)

    # 待機時間によってCPU使用率，購読までの時間は変わる
    RclEx.rcl_wait(wait_set, 5)

    # 購読タスク達のスーパーバイザを作成
    {:ok, sv} = Task.Supervisor.start_link()

    # 購読タスクをサブスクライバの数だけ生成，each_subscribe/2を実行させる．
    Enum.map(waitset_sublist, fn sub ->
      Task.Supervisor.start_child(sv, RclEx.Subscriber, :each_subscribe, [sub, callback],
        restart: :transient
      )
    end)

    subscribe_loop(wait_set, sub_list, callback)
  end

  @doc """
    購読開始の準備
    waitsetを作成
    スーパーバイザを生成
    監視されるタスクを生成し，購読ループ処理を実行させる
  """
  def subscribe_start(sub_list, context, callback) do
    wait_set =
      RclEx.rcl_get_zero_initialized_wait_set()
      |> RclEx.rcl_wait_set_init(
        length(sub_list),
        0,
        0,
        0,
        0,
        0,
        context,
        RclEx.rcl_get_default_allocator()
      )

    {:ok, sv} = Task.Supervisor.start_link()

    {:ok, child} =
      Task.Supervisor.start_child(
        sv,
        RclEx.Subscriber,
        :subscribe_loop,
        [wait_set, sub_list, callback],
        restart: :transient
      )

    {sv, child}
  end

  defp do_nothing do
  end
end
