defmodule Rclex.Subscriber do
  require Rclex.Macros
  require Logger

  @doc """
    購読処理関数
    購読が正常に行われれば，引数に受け取っていたコールバック関数を実行
  """
  def each_subscribe(sub, callback) do
    if Rclex.check_subscription(sub) do
      msg = Rclex.initialize_msg()
      msginfo = Rclex.create_msginfo()
      sub_alloc = Rclex.create_sub_alloc()

      case Rclex.rcl_take(sub, msg, msginfo, sub_alloc) do
        {Rclex.Macros.rcl_ret_ok(), _, _, _} ->
          callback.(msg)

        {Rclex.Macros.rcl_ret_subscription_invalid(), _, _, _} ->
          Logger.error("subscription invalid")

        {Rclex.Macros.rcl_ret_subscription_take_failed(), _, _, _} ->
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
    Rclex.rcl_wait_set_clear(wait_set)
    # waitsetにサブスクライバを追加する
    Enum.map(sub_list, fn sub -> Rclex.rcl_wait_set_add_subscription(wait_set, sub) end)

    # wait_setからsubのリストを取りだす
    waitset_sublist = Rclex.get_sublist_from_waitset(wait_set)

    # 待機時間によってCPU使用率，購読までの時間は変わる
    Rclex.rcl_wait(wait_set, 5)

    # 購読タスク達のスーパーバイザを作成
    {:ok, sv} = Task.Supervisor.start_link()

    # 購読タスクをサブスクライバの数だけ生成，each_subscribe/2を実行させる．
    Enum.map(waitset_sublist, fn sub ->
      Task.Supervisor.start_child(sv, Rclex.Subscriber, :each_subscribe, [sub, callback],
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
      Rclex.rcl_get_zero_initialized_wait_set()
      |> Rclex.rcl_wait_set_init(
        length(sub_list),
        0,
        0,
        0,
        0,
        0,
        context,
        Rclex.rcl_get_default_allocator()
      )

    {:ok, sv} = Task.Supervisor.start_link()

    {:ok, child} =
      Task.Supervisor.start_child(
        sv,
        Rclex.Subscriber,
        :subscribe_loop,
        [wait_set, sub_list, callback],
        restart: :transient
      )

    {sv, child}
  end

  @doc """
    サブスクライバの終了
    スーパバイザプロセスと実行タスクを停止する
  """
  def subscribe_stop(sv, child) do
    Task.Supervisor.terminate_child(sv, child)
    Supervisor.stop(sv)
  end

  defp do_nothing do
  end
end
