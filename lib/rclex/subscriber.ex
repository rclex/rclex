defmodule Rclex.Subscriber do
  alias Rclex.Nifs
  require Rclex.Macros
  require Logger

  @moduledoc """
  T.B.A
  """

  @doc """
    購読処理関数
    購読が正常に行われれば，引数に受け取っていたコールバック関数を実行
  """
  def each_subscribe(sub, callback) do
    if Nifs.check_subscription(sub) do
      msg = Rclex.initialize_msg()
      msginfo = Nifs.create_msginfo()
      sub_alloc = Nifs.create_sub_alloc()

      case Nifs.rcl_take(sub, msg, msginfo, sub_alloc) do
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
    Nifs.rcl_wait_set_clear(wait_set)
    # waitsetにサブスクライバを追加する
    Enum.map(sub_list, fn sub -> Nifs.rcl_wait_set_add_subscription(wait_set, sub) end)

    # wait_setからsubのリストを取りだす
    waitset_sublist = Nifs.get_sublist_from_waitset(wait_set)

    # 待機時間によってCPU使用率，購読までの時間は変わる
    Nifs.rcl_wait(wait_set, 5)

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
  def subscribe_start(sub_list, context, call_back) do
    Logger.debug("sub_start")
    id_list = sub_list
              |> Enum.map(fn sub -> Rclex.Loop.init_sub(sub, context, call_back)end )
              |> Enum.map(fn {:ok, pid} -> pid end)

    {:ok, id_list}
    # wait_set =
    #   Nifs.rcl_get_zero_initialized_wait_set()
    #   |> Nifs.rcl_wait_set_init(
    #     length(sub_list),
    #     0,
    #     0,
    #     0,
    #     0,
    #     0,
    #     context,
    #     Nifs.rcl_get_default_allocator()
    #   )

    # {:ok, sv} = Task.Supervisor.start_link()

    # {:ok, child} =
    #   Task.Supervisor.start_child(
    #     sv,
    #     Rclex.Subscriber,
    #     :subscribe_loop,
    #     [wait_set, sub_list, callback],
    #     restart: :transient
    #   )

    # {sv, child}
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
