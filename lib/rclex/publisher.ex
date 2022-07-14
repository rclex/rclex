defmodule Rclex.Publisher do
  alias Rclex.Nifs
  require Rclex.ReturnCode
  require Logger
  use GenServer

  @moduledoc """
  Defines publish message functions.

  Publisher itself can be created on Node by calling below,
  * `Rclex.Node.create_publisher/3`
  * `Rclex.Node.create_publishers/4`
  """

  @type id_tuple() :: {node_identifier :: charlist(), topic_name :: charlist(), :pub}

  @doc false
  @spec start_link({Nifs.rcl_publisher(), String.t()}) :: GenServer.on_start()
  def start_link({pub, process_name}) do
    GenServer.start_link(__MODULE__, pub, name: {:global, process_name})
  end

  @impl GenServer
  def init(pub) do
    {:ok, pub}
  end

  # FIXME?: 公開されていない内部状態変数 pub を使用するので defp とするべき？
  def publish_once(pub, pubmsg, pub_alloc) do
    case Nifs.rcl_publish(pub, pubmsg, pub_alloc) do
      {Rclex.ReturnCode.rcl_ret_ok(), _, _} ->
        Logger.debug("publish ok")

      {Rclex.ReturnCode.rcl_ret_publisher_invalid(), _, _} ->
        Logger.error("Publisher is invalid")

      {Rclex.ReturnCode.rmw_ret_invalid_argument(), _, _} ->
        Logger.error("invalid argument is contained")

      {Rclex.ReturnCode.rcl_ret_error(), _, _} ->
        Logger.error("unspecified error")

      {_, _, _} ->
        do_nothing()
    end
  end

  # TODO: define message type for reference()
  @spec publish(publisher_list :: [id_tuple()], data :: [reference()]) :: :ok
  def publish(publisher_list, data) do
    n = length(publisher_list)

    for index <- 0..(n - 1) do
      {node_identifier, topic_name, :pub} = Enum.at(publisher_list, index)

      GenServer.cast(
        {:global, "#{node_identifier}/#{topic_name}/pub"},
        {:publish, Enum.at(data, index)}
      )
    end

    :ok
  end

  @impl GenServer
  def handle_cast({:publish, msg}, pub) do
    Rclex.Publisher.publish_once(pub, msg, Nifs.create_pub_alloc())
    {:noreply, pub}
  end

  @impl GenServer
  def handle_call({:finish, node}, _from, pub) do
    Nifs.rcl_publisher_fini(pub, node)
    {:reply, {:ok, 'publisher finished: '}, pub}
  end

  @impl GenServer
  def terminate(:normal, _) do
    Logger.debug("terminate publisher")
  end

  defp do_nothing do
    # noop
    Logger.debug("do nothing")
  end
end
