defmodule Rclex.Subscriber do
  alias Rclex.Nifs
  require Logger
  use GenServer

  @moduledoc """
  Defines control, start/stop, `Rclex.SubLoop` functions.

  Subscriber itself can be created on Node by calling below,
  * `Rclex.Node.create_subscriber/3`
  * `Rclex.Node.create_subscribers/4`

  There are 4 GenServers including this module itself under the Node.
  They work together as shown below.
      
      +-------------+
      | Rclex.Node  |
      +-----+-------+
            |
            |
            |
            |                            +-------------------+                            +-------------------+
            +------Supervisor------------+ Rclex.Subscriber  |------Supervisor------------+ Rclex.SubLoop     |
            |                            +--------^----------+                            +--------+----------+
            |                                     |                                                |
            |                                     |                                                |
            |                                     | GenServer.cast to Rclex.Subscriber             |
            |                                     |                                                |
            |                            +--------+----------+                                     |
            |                    +-------+ Rclex.JobExecutor |          GenServer.cast to JobQueue |
            |                    |       +--------^----------+                                     |
            |                    |                |                                                |
            +------Supervisor----+                | GenServer.cast to JobExecutor                  |
                                 |                |                                                |
                                 |       +--------+----------+                                     |
                                 +-------+ Rclex.JobQueue    <-------------------------------------+
                                         +-------------------+                                      
  * This module stored `call_back` to be executed.
  * `Rclex.SubLoop` triggers the `call_back` execution according to pushing message to `Rclex.JobQueue`.
  """

  @type id_tuple() :: {node_identifier :: charlist(), topic_name :: charlist(), :sub}

  @doc false
  @spec start_link(
          {sub :: Nifs.rcl_subscription(), msg_type :: charlist(), process_name :: String.t()}
        ) ::
          GenServer.on_start()
  def start_link({sub, msg_type, process_name}) do
    Logger.debug("#{process_name} subscriber process start")
    GenServer.start_link(__MODULE__, {sub, msg_type}, name: {:global, process_name})
  end

  # TODO: define State struct for GerServer state which shows state explicitly.
  @impl GenServer
  @doc """
    subscriberを状態として持つ。start_subscribingをした際にcontextとcall_backを追加で状態として持つ。
  """
  @spec init({sub :: Nifs.rcl_subscription(), msg_type :: charlist()}) :: {:ok, state :: map()}
  def init({sub, msg_type}) do
    {:ok, %{subscriber: sub, msgtype: msg_type}}
  end

  @spec start_subscribing(id_tuple(), Nifs.rcl_context(), call_back :: function()) :: :ok
  def start_subscribing({node_identifier, topic_name, :sub}, context, call_back) do
    sub_identifier = "#{node_identifier}/#{topic_name}/sub"

    GenServer.cast(
      {:global, sub_identifier},
      {:start_subscribing, {context, call_back, node_identifier, topic_name}}
    )
  end

  @spec start_subscribing([id_tuple()], Nifs.rcl_context(), call_back :: function()) :: list()
  def start_subscribing(sub_list, context, call_back) do
    Enum.map(sub_list, fn {node_identifier, topic_name, :sub} ->
      sub_identifier = "#{node_identifier}/#{topic_name}/sub"

      GenServer.cast(
        {:global, sub_identifier},
        {:start_subscribing, {context, call_back, node_identifier, topic_name}}
      )
    end)
  end

  @spec stop_subscribing(id_tuple()) :: :ok | :error
  def stop_subscribing({node_identifier, topic_name, :sub}) do
    sub_identifier = "#{node_identifier}/#{topic_name}/sub"
    GenServer.call({:global, sub_identifier}, :stop_subscribing)
  end

  @spec stop_subscribing([id_tuple()]) :: list()
  def stop_subscribing(sub_list) do
    Enum.map(sub_list, fn {node_identifier, topic_name, :sub} ->
      sub_identifier = "#{node_identifier}/#{topic_name}/sub"
      GenServer.call({:global, sub_identifier}, :stop_subscribing)
    end)
  end

  @impl GenServer
  def handle_cast({:start_subscribing, {context, call_back, node_identifier, topic_name}}, state) do
    {:ok, sub} = Map.fetch(state, :subscriber)
    {:ok, msg_type} = Map.fetch(state, :msgtype)

    children = [
      {Rclex.SubLoop, {node_identifier, msg_type, topic_name, sub, context, call_back}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, supervisor_id} = Supervisor.start_link(children, opts)

    {:noreply,
     %{
       subscriber: sub,
       msgtype: msg_type,
       context: context,
       call_back: call_back,
       supervisor_id: supervisor_id
     }}
  end

  @impl GenServer
  def handle_cast({:subscribe, msg}, state) do
    {:ok, call_back} = Map.fetch(state, :call_back)
    call_back.(msg)
    {:noreply, state}
  end

  @impl GenServer
  def handle_cast(:stop, state) do
    {:stop, :normal, state}
  end

  @impl GenServer
  def handle_call(:stop_subscribing, _from, state) do
    case Map.fetch(state, :supervisor_id) do
      {:ok, supervisor_id} ->
        Supervisor.stop(supervisor_id)
        new_state = Map.delete(state, :supervisor_id)
        {:reply, :ok, new_state}

      :error ->
        {:reply, :error, state}
    end
  end

  @impl GenServer
  def handle_call({:finish, node}, _from, state) do
    {:ok, sub} = Map.fetch(state, :subscriber)
    Nifs.rcl_subscription_fini(sub, node)
    {:reply, {:ok, ~c"subscriber finished: "}, state}
  end

  @impl GenServer
  def handle_call({:finish_subscriber, node}, _from, state) do
    {:ok, sub} = Map.fetch(state, :subscriber)
    Nifs.rcl_subscription_fini(sub, node)
    {:reply, :ok, state}
  end

  @impl GenServer
  def terminate(:normal, _) do
    Logger.debug("terminate subscriber")
  end
end
