defmodule Rclex.Publisher do
  alias Rclex.Nifs
  require Rclex.Macros
  require Logger
  use GenServer

  @moduledoc """
  T.B.A
  """

  @doc """
    publisherプロセスの生成
  """
  def start_link({pub, process_name}) do
    GenServer.start_link(__MODULE__, pub, name: {:global, process_name})
  end

  @doc """
    publisherプロセスの初期化
  """
  def init(pub) do
    {:ok, pub}
  end

  def publish_once(pub, pubmsg, pub_alloc) do
    case Nifs.rcl_publish(pub, pubmsg, pub_alloc) do
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

  def publish(publisher_list, data) do
    n = length(publisher_list)

    Enum.map(0..(n - 1), fn index ->
      {node_identifier, topic_name, :pub} = Enum.at(publisher_list, index)

      GenServer.cast(
        {:global, "#{node_identifier}/#{topic_name}/pub"},
        {:publish, Enum.at(data, index)}
      )
    end)

    :ok
  end

  def handle_cast({:publish, msg}, pub) do
    Rclex.Publisher.publish_once(pub, msg, Nifs.create_pub_alloc())
    {:noreply, pub}
  end

  def handle_call({:finish, node}, _from, pub) do
    Nifs.rcl_publisher_fini(pub, node)
    {:reply, {:ok, 'publisher finished: '}, pub}
  end

  def terminate(:normal, _) do
    Logger.debug("terminate publisher")
  end

  defp do_nothing do
    # noop
    Logger.debug("do nothing")
  end
end
