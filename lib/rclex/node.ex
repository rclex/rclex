defmodule Rclex.Node do
  alias Rclex.Nifs
  require Rclex.Macros
  require Logger
  use GenServer, restart: :transient

  @moduledoc """
    T.B.A
  """

  def start_link({node, node_name}) do
    GenServer.start_link(__MODULE__, {node, node_name}, name: {:global, node_name})
  end

  def start_link(node, node_name, node_namespace) do
    node_identifier = "#{node_namespace}/#{node_name}"

    children = [
      {Rclex.JobQueue, {node_identifier}},
      {Rclex.JobExecutor, {node_identifier}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, id} = Supervisor.start_link(children, opts)
    # supervisor_idsにはJob、Publisher、Subscriberのsupervisor_idを入れる
    # Publisher、Subscriberは第2クエリとしてトピック名を指定する
    supervisor_ids = Map.put_new(%{}, {:job, "supervisor"}, id)

    GenServer.start_link(__MODULE__, {node, node_identifier, supervisor_ids},
      name: {:global, node_identifier}
    )
  end

  def init({node, node_name}) do
    children = [
      {Rclex.JobQueue, {node_name}},
      {Rclex.JobExecutor, {node_name}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, id} = Supervisor.start_link(children, opts)
    # supervisor_idsにはJob、Publisher、Subscriberのsupervisor_idを入れる
    # Publisher、Subscriberは第2クエリとしてトピック名を指定する
    supervisor_ids = Map.put_new(%{}, {:job, "supervisor"}, id)
    {:ok, {node, node_name, supervisor_ids}}
  end

  def create_single_subscriber(node_identifier, topic_name) do
    GenServer.call({:global, node_identifier}, {:create_subscriber, node_identifier, topic_name})
  end

  @doc """
      サブスクライバを複数生成
      :singleもしくは:multiを指定する．
      :single...一つのトピックに複数の出版者または購読者
      :multi...1つのトピックに出版者または購読者1つのペアを複数
  """

  def create_subscribers(node_identifier_list, topic_name, :single) do
    sub_identifier_list =
      Enum.map(node_identifier_list, fn node_identifier ->
        GenServer.call(
          {:global, node_identifier},
          {:create_subscriber, node_identifier, topic_name}
        )
      end)
      |> Enum.map(fn {:ok, sub_identifier} -> sub_identifier end)

    {:ok, sub_identifier_list}
  end

  def create_subscribers(node_identifier_list, topic_name, :multi) do
    sub_identifier_list =
      Enum.map(0..(node_identifier_list - 1), fn index ->
        GenServer.call(
          {:global, Enum.at(node_identifier_list, index)},
          {:create_subscriber, Enum.at(node_identifier_list, index),
           topic_name ++ Integer.to_charlist(index)}
        )
      end)
      |> Enum.map(fn {:ok, sub_identifier} -> sub_identifier end)

    {:ok, sub_identifier_list}
  end

  def create_single_publisher(node_identifier, topic_name) do
    GenServer.call({:global, node_identifier}, {:create_publisher, node_identifier, topic_name})
  end

  @doc """
      パブリッシャを複数生成
      :singleもしくは:multiを指定する．
      :single...一つのトピックに複数の出版者または購読者
      :multi...1つのトピックに出版者または購読者1つのペアを複数
  """

  def create_publishers(node_identifier_list, topic_name, :single) do
    pub_identifier_list =
      Enum.map(node_identifier_list, fn node_identifier ->
        GenServer.call(
          {:global, node_identifier},
          {:create_publisher, node_identifier, topic_name}
        )
      end)
      |> Enum.map(fn {:ok, pub_identifier} -> pub_identifier end)

    {:ok, pub_identifier_list}
  end

  def create_publishers(node_identifier_list, topic_name, :multi) do
    pub_identifier_list =
      Enum.map(0..(length(node_identifier_list) - 1), fn index ->
        GenServer.call(
          {:global, Enum.at(node_identifier_list, index)},
          {:create_publisher, Enum.at(node_identifier_list, index),
           topic_name ++ Integer.to_charlist(index)}
        )
      end)
      |> Enum.map(fn {:ok, pub_identifier} -> pub_identifier end)

    {:ok, pub_identifier_list}
  end

  def finish_job({node_identifier, topic_name, role}) do
    :ok = GenServer.call({:global, node_identifier}, {:finish_job, topic_name, role})
  end

  def finish_jobs(job_list) do
    Enum.map(job_list, fn {node_identifier, topic_name, role} ->
      GenServer.call({:global, node_identifier}, {:finish_job, topic_name, role})
    end)
  end

  @doc """
    ノード名の取得
  """
  def node_get_name(node_identifier) do
    GenServer.call({:global, node_identifier}, :node_get_name)
  end

  @doc """
    トピックの名前と型の取得
  """
  def get_topic_names_and_types(node_identifier, allocator, no_demangle) do
    GenServer.call(
      {:global, node_identifier},
      {:get_topic_names_and_types, allocator, no_demangle}
    )
  end

  def handle_call(
        {:create_subscriber, node_identifier, topic_name},
        _,
        {node, name, supervisor_ids}
      ) do
    subscriber = Nifs.rcl_get_zero_initialized_subscription()
    sub_op = Nifs.rcl_subscription_get_default_options()
    sub = Nifs.rcl_subscription_init(subscriber, node, topic_name, sub_op)

    children = [
      {Rclex.Subscriber, {sub, "#{node_identifier}/#{topic_name}/sub"}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, id} = Supervisor.start_link(children, opts)
    # TODO: has_keyで見る
    new_supervisor_ids = Map.put_new(supervisor_ids, {:sub, topic_name}, id)
    {:reply, {:ok, {node_identifier, topic_name, :sub}}, {node, name, new_supervisor_ids}}
  end

  def handle_call(
        {:create_publisher, node_identifier, topic_name},
        _,
        {node, name, supervisor_ids}
      ) do
    publisher = Nifs.rcl_get_zero_initialized_publisher()
    pub_op = Nifs.rcl_publisher_get_default_options()
    pub = Nifs.rcl_publisher_init(publisher, node, topic_name, pub_op)

    children = [
      {Rclex.Publisher, {pub, "#{node_identifier}/#{topic_name}/pub"}}
    ]

    opts = [strategy: :one_for_one]
    {:ok, id} = Supervisor.start_link(children, opts)
    new_supervisor_ids = Map.put_new(supervisor_ids, {:pub, topic_name}, id)
    Logger.debug("#{node_identifier}/#{topic_name}/pub")
    {:reply, {:ok, {node_identifier, topic_name, :pub}}, {node, name, new_supervisor_ids}}
  end

  # Publisher、Subscriberを終了する
  # roleには"pub"、"sub"のどちらかを指定する
  def handle_call({:finish_job, topic_name, role}, _from, {node, name, supervisor_ids}) do
    {:ok, supervisor_id} = Map.fetch(supervisor_ids, {role, topic_name})

    key = "#{name}/#{topic_name}/#{role}"

    {:ok, text} = GenServer.call({:global, key}, {:finish, node})

    Logger.debug(text ++ key)

    Supervisor.stop(supervisor_id)

    new_supervisor_ids = Map.delete(supervisor_ids, {role, topic_name})

    {:reply, :ok, {node, name, new_supervisor_ids}}
  end

  # def handle_call({:finish_subscriber, topic_name}, _from, {node, node_name, supervisor_ids}) do
  #   {:ok, supervisor_id} = Map.fetch(supervisor_ids, {:sub, topic_name})

  #   sub_key = "#{node_name}/sub/#{topic_name}"

  #   :ok = GenServer.call({:global, sub_key}, {:finish_subscriber, node})

  #   Supervisor.stop(supervisor_id)

  #   new_supervisor_ids = Map.delete(supervisor_ids, topic_name)

  #   {:reply, :ok, {node, node_name, new_supervisor_ids}}
  # end

  def handle_call(:finish_node, _from, {node, name, supervisor_ids}) do
    Nifs.rcl_node_fini(node)

    {:ok, supervisor_id} = Map.fetch(supervisor_ids, {:job, "supervisor"})
    Supervisor.stop(supervisor_id)
    new_supervisor_ids = Map.delete(supervisor_ids, {:job, "supervisor"})

    # TODO nodeに紐付いているpub,subをきちんと終了させる

    {:reply, :ok, {node, name, new_supervisor_ids}}
  end

  def handle_call(:node_get_name, _from, state) do
    {node, _, _} = state
    node_name = Nifs.rcl_node_get_name(node)
    {:reply, node_name, state}
  end

  def handle_call({:get_topic_names_and_types, allocator, no_demangle}, _from, state) do
    {node, _, _} = state
    names_and_types_list = Nifs.rcl_get_topic_names_and_types(node, allocator, no_demangle)
    {:reply, names_and_types_list, state}
  end
end
