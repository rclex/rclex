defmodule Rclex.Node do
  alias Rclex.Nifs
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
  Defines functions to assign job, subscribe or publish, to Node.
  """

  @type sub_identifier :: {node_identifier :: charlist(), topic_name :: charlist(), :sub}
  @type pub_identifier :: {node_identifier :: charlist(), topic_name :: charlist(), :pub}

  @doc false
  def start_link({node, node_identifier, {queue_length, change_order}}) do
    GenServer.start_link(__MODULE__, {node, node_identifier, queue_length, change_order},
      name: {:global, node_identifier}
    )
  end

  # TODO: define State struct for GerServer state which shows state explicitly.
  @impl GenServer
  def init({node, node_identifier, queue_length, change_order}) do
    children = [
      {Rclex.JobQueue, {node_identifier, queue_length}},
      {Rclex.JobExecutor, {node_identifier, change_order}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, id} = Supervisor.start_link(children, opts)
    # supervisor_idsにはJob、Publisher、Subscriberのsupervisor_idを入れる
    # Publisher、Subscriberは第2クエリとしてトピック名を指定する
    supervisor_ids = Map.put_new(%{}, {:job, "supervisor"}, id)
    {:ok, {node, node_identifier, supervisor_ids}}
  end

  @doc """
  Create subscriber.

  ## Arguments

  * node_identifier: node identifier
  * msg_types: ex) 'StdMsgs.Msg.String'
  * topic_name: topic name, ex) 'test'
  """
  @spec create_subscriber(
          node_identifier :: charlist(),
          msg_type :: charlist(),
          topic_name :: charlist()
        ) :: {:ok, sub_identifier()}
  def create_subscriber(node_identifier, msg_type, topic_name) do
    GenServer.call(
      {:global, node_identifier},
      {:create_subscriber, node_identifier, msg_type, topic_name}
    )
  end

  @doc """
  Create multiple subscribers.

  ## Arguments

  * node_identifier_list: node identifier list
  * msg_types: ex) 'StdMsgs.Msg.String'
  * topic_name: topic name, ex) 'test'
  * type: :single or :multi

  ### type: :single

  Create multiple subscribers to a single topic.

                              +------------+
                    +---------+ subscriber |
                    |         +------------+
                    |
                    |         +------------+
                    +---------+ subscriber |
      +-------+     |         +------------+
      | topic +-----+
      +-------+     |         +------------+
                    +---------+ subscriber |
                    |         +------------+
                    |
                    |         +------------+
                    +---------+ subscriber |
                              +------------+

  ### type: :multi

  Create one-to-one subscribers for multiple topics.

      +-------+               +------------+
      | topic +---------------+ subscriber |
      +-------+               +------------+
                                            
      +-------+               +------------+
      | topic +---------------+ subscriber |
      +-------+               +------------+
                                            
      +-------+               +------------+
      | topic +---------------+ subscriber |
      +-------+               +------------+
                                            
      +-------+               +------------+
      | topic +---------------+ subscriber |
      +-------+               +------------+
  """
  @spec create_subscribers(
          [node_identifier :: charlist()],
          msg_type :: charlist(),
          topic_name :: charlist(),
          type :: atom()
        ) :: {:ok, [sub_identifier()]}
  def create_subscribers(node_identifier_list, msg_type, topic_name, type)

  def create_subscribers(node_identifier_list, msg_type, topic_name, :single) do
    sub_identifier_list =
      Enum.map(node_identifier_list, fn node_identifier ->
        GenServer.call(
          {:global, node_identifier},
          {:create_subscriber, node_identifier, msg_type, topic_name}
        )
      end)
      |> Enum.map(fn {:ok, sub_identifier} -> sub_identifier end)

    {:ok, sub_identifier_list}
  end

  def create_subscribers(node_identifier_list, msg_type, topic_name, :multi) do
    sub_identifier_list =
      Enum.map(0..(node_identifier_list - 1), fn index ->
        GenServer.call(
          {:global, Enum.at(node_identifier_list, index)},
          {:create_subscriber, Enum.at(node_identifier_list, index), msg_type,
           topic_name ++ Integer.to_charlist(index)}
        )
      end)
      |> Enum.map(fn {:ok, sub_identifier} -> sub_identifier end)

    {:ok, sub_identifier_list}
  end

  @doc """
  Create publisher.

  ## Arguments

  * node_identifier: node identifier
  * msg_types: ex) 'StdMsgs.Msg.String'
  * topic_name: topic name, ex) 'test'
  """
  @spec create_publisher(
          node_identifier :: charlist(),
          msg_type :: charlist(),
          topic_name :: charlist()
        ) :: {:ok, pub_identifier()}
  def create_publisher(node_identifier, msg_type, topic_name) do
    GenServer.call(
      {:global, node_identifier},
      {:create_publisher, node_identifier, msg_type, topic_name}
    )
  end

  @doc """
  Create multiple publishers

  ## Arguments

  * node_identifier_list: node identifier list
  * msg_types: ex) 'StdMsgs.Msg.String'
  * topic_name: topic name, ex) 'test'
  * type: :single or :multi

  ### type: :single

  Create multiple publishers to a single topic.

                              +------------+
                    +---------+ publisher  |
                    |         +------------+
                    |
                    |         +------------+
                    +---------+ publisher  |
      +-------+     |         +------------+
      | topic +-----+
      +-------+     |         +------------+
                    +---------+ publisher  |
                    |         +------------+
                    |
                    |         +------------+
                    +---------+ publisher  |
                              +------------+

  ### type: :multi

  Create one-to-one publishers for multiple topics.

      +-------+               +------------+
      | topic +---------------+ publisher  |
      +-------+               +------------+
                                            
      +-------+               +------------+
      | topic +---------------+ publisher  |
      +-------+               +------------+
                                            
      +-------+               +------------+
      | topic +---------------+ publisher  |
      +-------+               +------------+
                                            
      +-------+               +------------+
      | topic +---------------+ publisher  |
      +-------+               +------------+
  """

  @spec create_publishers(
          node_identifier_list :: [node_identifier :: charlist()],
          msg_type :: charlist(),
          topic_name :: charlist(),
          type :: atom()
        ) :: {:ok, [pub_identifier()]}
  def create_publishers(node_identifier_list, msg_type, topic_name, type)

  def create_publishers(node_identifier_list, msg_type, topic_name, :single) do
    pub_identifier_list =
      Enum.map(node_identifier_list, fn node_identifier ->
        GenServer.call(
          {:global, node_identifier},
          {:create_publisher, node_identifier, msg_type, topic_name}
        )
      end)
      |> Enum.map(fn {:ok, pub_identifier} -> pub_identifier end)

    {:ok, pub_identifier_list}
  end

  def create_publishers(node_identifier_list, msg_type, topic_name, :multi) do
    pub_identifier_list =
      Enum.map(0..(length(node_identifier_list) - 1), fn index ->
        GenServer.call(
          {:global, Enum.at(node_identifier_list, index)},
          {:create_publisher, Enum.at(node_identifier_list, index), msg_type,
           topic_name ++ Integer.to_charlist(index)}
        )
      end)
      |> Enum.map(fn {:ok, pub_identifier} -> pub_identifier end)

    {:ok, pub_identifier_list}
  end

  @doc """
  Finish subscribe/publish job.
  """
  @spec finish_job(sub_identifier() | pub_identifier()) :: :ok
  def finish_job({node_identifier, topic_name, role}) do
    :ok = GenServer.call({:global, node_identifier}, {:finish_job, topic_name, role})
  end

  @doc """
  Finish subscribe/publish jobs.
  """
  @spec finish_jobs([sub_identifier() | pub_identifier()]) :: list()
  def finish_jobs(job_list) do
    Enum.map(job_list, fn {node_identifier, topic_name, role} ->
      GenServer.call({:global, node_identifier}, {:finish_job, topic_name, role})
    end)
  end

  # TODO: 必要性の検討、引数がまま返ってくるだけ以上の用途があるか？
  @doc """
  Get Node name.
  """
  @spec node_get_name(node_identifier :: charlist()) :: node_identifier :: charlist()
  def node_get_name(node_identifier) do
    GenServer.call({:global, node_identifier}, :node_get_name)
  end

  @doc """
  Get topic names and types, return example is below
  > [{'/topic', ['std_msgs/msg/String']}]
  """
  @spec get_topic_names_and_types(
          node_identifier :: charlist(),
          allocator :: Rclex.rcl_allocator(),
          no_demangle :: boolean
        ) :: [{charlist(), [charlist()]}]
  def get_topic_names_and_types(node_identifier, allocator, no_demangle) do
    GenServer.call(
      {:global, node_identifier},
      {:get_topic_names_and_types, allocator, no_demangle}
    )
  end

  @impl GenServer
  def handle_call(
        {:create_subscriber, node_identifier, msg_type, topic_name},
        _,
        {node, name, supervisor_ids}
      ) do
    subscriber = Nifs.rcl_get_zero_initialized_subscription()
    sub_op = Nifs.rcl_subscription_get_default_options()
    sub_ts = Rclex.Msg.typesupport(msg_type)
    sub = Nifs.rcl_subscription_init(subscriber, node, topic_name, sub_ts, sub_op)

    children = [
      {Rclex.Subscriber, {sub, msg_type, "#{node_identifier}/#{topic_name}/sub"}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, id} = Supervisor.start_link(children, opts)
    # TODO: has_keyで見る
    new_supervisor_ids = Map.put_new(supervisor_ids, {:sub, topic_name}, id)
    {:reply, {:ok, {node_identifier, topic_name, :sub}}, {node, name, new_supervisor_ids}}
  end

  @impl GenServer
  def handle_call(
        {:create_publisher, node_identifier, msg_type, topic_name},
        _,
        {node, name, supervisor_ids}
      ) do
    publisher = Nifs.rcl_get_zero_initialized_publisher()
    pub_op = Nifs.rcl_publisher_get_default_options()
    pub_ts = Rclex.Msg.typesupport(msg_type)
    pub = Nifs.rcl_publisher_init(publisher, node, topic_name, pub_ts, pub_op)

    children = [
      {Rclex.Publisher, {pub, "#{node_identifier}/#{topic_name}/pub"}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, id} = Supervisor.start_link(children, opts)
    new_supervisor_ids = Map.put_new(supervisor_ids, {:pub, topic_name}, id)
    Logger.debug("#{node_identifier}/#{topic_name}/pub")
    {:reply, {:ok, {node_identifier, topic_name, :pub}}, {node, name, new_supervisor_ids}}
  end

  @impl GenServer
  def handle_call({:finish_job, topic_name, role}, _from, {node, name, supervisor_ids}) do
    {:ok, supervisor_id} = Map.fetch(supervisor_ids, {role, topic_name})

    key = "#{name}/#{topic_name}/#{role}"

    {:ok, text} = GenServer.call({:global, key}, {:finish, node})

    Logger.debug(text ++ key)

    Supervisor.stop(supervisor_id)

    new_supervisor_ids = Map.delete(supervisor_ids, {role, topic_name})

    {:reply, :ok, {node, name, new_supervisor_ids}}
  end

  @impl GenServer
  def handle_call(:finish_node, _from, {node, name, supervisor_ids}) do
    Nifs.rcl_node_fini(node)

    {:ok, supervisor_id} = Map.fetch(supervisor_ids, {:job, "supervisor"})
    Supervisor.stop(supervisor_id)
    new_supervisor_ids = Map.delete(supervisor_ids, {:job, "supervisor"})

    # TODO nodeに紐付いているpub,subをきちんと終了させる

    {:reply, :ok, {node, name, new_supervisor_ids}}
  end

  @impl GenServer
  def handle_call(:node_get_name, _from, state) do
    {node, _, _} = state
    node_name = Nifs.rcl_node_get_name(node)
    {:reply, node_name, state}
  end

  @impl GenServer
  def handle_call({:get_topic_names_and_types, allocator, no_demangle}, _from, state) do
    {node, _, _} = state
    names_and_types_list = Nifs.rcl_get_topic_names_and_types(node, allocator, no_demangle)
    {:reply, names_and_types_list, state}
  end
end
