defmodule Rclex.Publisher do
  require Rclex.Macros
  require Logger

  @moduledoc """
  T.B.A
  """

  def publish_once(pub, pubmsg, pub_alloc) do
    case Rclex.rcl_publish(pub, pubmsg, pub_alloc) do
      {Rclex.Macros.rcl_ret_ok(), _, _} ->
        Logger.debug("publish ok")

      {Rclex.Macros.rcl_ret_publisher_invalid(), _, _} ->
        Logger.error("Publisher is invalid")

      {Rclex.Macros.rmw_ret_invalid_argument(), _, _} ->
        Logger.error("invalid argument is contained")

      {Rclex.Macros.rcl_ret_error(), _, _} ->
        Logger.error("unspecified error")

      {_, _, _} ->
        do_nothing()
    end
  end

  @doc """
    出版関数
    スーパーバイザを作成し，パブリッシャの数だけタスクを生成
    タスクにpublish_onceを実行させる
  """
  def publish(publisher_list, pubmsg_list) do
    {:ok, supervisor} = Task.Supervisor.start_link()

    Enum.map(0..(length(publisher_list) - 1), fn index ->
      #  Task.async(fn -> sub_spin(Rclex.create_empty_msgInt16(),subscriber,Rclex.create_msginfo(),Rclex.create_sub_alloc(),callback) end)
      Task.Supervisor.start_child(
        supervisor,
        Rclex.Publisher,
        :publish_once,
        [Enum.at(publisher_list, index), Enum.at(pubmsg_list, index), Rclex.create_pub_alloc()],
        restart: :transient
      )

      # Task.async(fn ->
      # publoop(Enum.at(publisher_list,index),Enum.at(pubmsg_list,index),Rclex.create_pub_alloc(),callback)
    end)
  end

  defp do_nothing do
    # noop
  end
end
