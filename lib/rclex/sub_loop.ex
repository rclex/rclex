defmodule Rclex.SubLoop do
  alias Rclex.Nifs
  require Rclex.ReturnCode
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
  Implements subscribing logic.
  """

  def start_link({node_identifier, msg_type, topic_name, sub, context, call_back}) do
    GenServer.start_link(
      __MODULE__,
      {node_identifier, msg_type, topic_name, sub, context, call_back}
    )
  end

  @impl GenServer
  def init({node_identifier, msg_type, topic_name, sub, context, call_back}) do
    wait_set =
      Nifs.rcl_get_zero_initialized_wait_set()
      |> Nifs.rcl_wait_set_init(
        1,
        0,
        0,
        0,
        0,
        0,
        context,
        Nifs.rcl_get_default_allocator()
      )

    GenServer.cast(self(), {:loop})
    {:ok, {node_identifier, msg_type, topic_name, wait_set, sub, call_back}}
  end

  def start_sub(id_list) do
    id_list
    |> Enum.map(fn pid -> GenServer.cast(pid, {:loop}) end)
  end

  @doc """
      購読処理関数
      購読が正常に行われれば，引数に受け取っていたコールバック関数を実行
  """
  @spec each_subscribe(
          sub :: reference(),
          node_identifier :: charlist(),
          msg_type :: charlist(),
          topic_name :: charlist()
        ) :: :ok | nil
  def each_subscribe(sub, node_identifier, msg_type, topic_name) do
    # Logger.debug("each subscribe")
    if Nifs.check_subscription(sub) do
      msg = Rclex.Msg.initialize(msg_type)
      msginfo = Nifs.create_msginfo()
      sub_alloc = Nifs.create_sub_alloc()
      sub_key = {:global, "#{node_identifier}/#{topic_name}/sub"}

      case Nifs.rcl_take(sub, msg, msginfo, sub_alloc) do
        {Rclex.ReturnCode.rcl_ret_ok(), _, _, _} ->
          GenServer.cast(
            {:global, "#{node_identifier}/JobQueue"},
            {:push, {sub_key, :subscribe, msg}}
          )

        {Rclex.ReturnCode.rcl_ret_subscription_invalid(), _, _, _} ->
          Logger.error("subscription invalid")

        {Rclex.ReturnCode.rcl_ret_subscription_take_failed(), _, _, _} ->
          do_nothing()
      end
    end
  end

  @impl GenServer
  def handle_cast({:loop}, {node_identifier, msg_type, topic_name, wait_set, sub, call_back}) do
    {:noreply, {node_identifier, msg_type, topic_name, wait_set, sub, call_back},
     {:continue, :loop}}
  end

  @impl GenServer
  def handle_continue(:loop, {node_identifier, msg_type, topic_name, wait_set, sub, call_back}) do
    Nifs.rcl_wait_set_clear(wait_set)
    # waitsetにサブスクライバを追加する
    Nifs.rcl_wait_set_add_subscription(wait_set, sub)

    # wait_setからsubのリストを取りだす
    [waitset_sub] = Nifs.get_sublist_from_waitset(wait_set)

    # 待機時間によってCPU使用率，購読までの時間は変わる
    Nifs.rcl_wait(wait_set, 5)

    # each_subscribe(waitset_sub, call_back, sub_id)
    each_subscribe(waitset_sub, node_identifier, msg_type, topic_name)

    receive do
      :stop ->
        Process.send("#{node_identifier}/#{topic_name}/sub", :terminate, [:noconnect])
        {:stop, :normal, {node_identifier, msg_type, topic_name, wait_set, sub, call_back}}
    after
      # Optional timeout
      5 ->
        {:noreply, {node_identifier, msg_type, topic_name, wait_set, sub, call_back},
         {:continue, :loop}}
    end
  end

  @impl GenServer
  def terminate(:normal, _) do
    Logger.debug("sub_loop process killed : normal")
  end

  @impl GenServer
  def terminate(:shutdown, _) do
    Logger.debug("sub_loop process killed : shutdown")
  end

  def do_nothing() do
  end
end
