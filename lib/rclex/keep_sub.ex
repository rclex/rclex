defmodule Rclex.KeepSub do
  alias Rclex.Nifs
  require Rclex.Macros
  require Logger

  @moduledoc """
    出版の有無にかかわらず購読をし続ける．
    subscribe_loopの中に適宜スリープを挟むことでCPU使用率は下げられる
  """

  def take_once(takemsg, sub, msginfo, sub_alloc, callback) do
    case Nifs.rcl_take(sub, takemsg, msginfo, sub_alloc) do
      {Rclex.Macros.rcl_ret_ok(), _, _, _} ->
        callback.(takemsg)

      {Rclex.Macros.rcl_ret_subscription_invalid(), _, _, _} ->
        Logger.error("subscription invalid")

      {Rclex.Macros.rcl_ret_subscription_take_failed(), _, _, _} ->
        do_nothing()
    end
  end

  def subscribe_loop(takemsg, sub, msginfo, sub_alloc, callback) do
    take_once(takemsg, sub, msginfo, sub_alloc, callback)
    # :timer.sleep(10)
    subscribe_loop(takemsg, sub, msginfo, sub_alloc, callback)
  end

  def sub_task_start(subscriber_list, callback) do
    # 1 process manages all nodes
    {:ok, supervisor} = Task.Supervisor.start_link()

    Enum.map(subscriber_list, fn subscriber ->
      Task.Supervisor.start_child(
        supervisor,
        Rclex.KeepSub,
        :subscribe_loop,
        [
          Rclex.initialize_msg(),
          subscriber,
          Nifs.create_msginfo(),
          Nifs.create_sub_alloc(),
          callback
        ],
        restart: :transient
      )
    end)
  end

  defp do_nothing do
    # noop
  end
end
