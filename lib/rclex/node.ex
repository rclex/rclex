defmodule Rclex.Node do
  @moduledoc false

  use GenServer

  require Logger

  alias Rclex.Nif
  alias Rclex.EntitiesSupervisor, as: ES
  alias Rclex.Graph, as: Graph

  def start_link(args) do
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    GenServer.start_link(__MODULE__, args, name: name(name, namespace))
  end

  def name(name, namespace \\ "/") do
    {:global, {name, namespace}}
  end

  def start_publisher(message_type, topic_name, name, namespace, qos) do
    server = name(name, namespace)
    GenServer.call(server, {:start_publisher, message_type, topic_name, qos})
  end

  def stop_publisher(message_type, topic_name, name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:stop_publisher, message_type, topic_name})
  end

  def start_subscription(callback, message_type, topic_name, name, namespace, qos) do
    server = name(name, namespace)
    GenServer.call(server, {:start_subscription, callback, message_type, topic_name, qos})
  end

  def stop_subscription(message_type, topic_name, name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:stop_subscription, message_type, topic_name})
  end

  def start_service(callback, service_type, service_name, name, namespace, qos) do
    server = name(name, namespace)
    GenServer.call(server, {:start_service, callback, service_type, service_name, qos})
  end

  def stop_service(service_type, service_name, name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:stop_service, service_type, service_name})
  end

  def start_client(callback, service_type, service_name, name, namespace, qos) do
    server = name(name, namespace)
    GenServer.call(server, {:start_client, callback, service_type, service_name, qos})
  end

  def stop_client(service_type, service_name, name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:stop_client, service_type, service_name})
  end

  def start_timer(period_ms, callback, timer_name, name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:start_timer, period_ms, callback, timer_name})
  end

  def stop_timer(timer_name, name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:stop_timer, timer_name})
  end

  def count_publishers(name, namespace, topic_name) do
    server = name(name, namespace)
    GenServer.call(server, {:count_publishers, topic_name})
  end

  def count_subscribers(name, namespace, topic_name) do
    server = name(name, namespace)
    GenServer.call(server, {:count_subscribers, topic_name})
  end

  def get_client_names_and_types_by_node(name, namespace, node_name, node_namespace) do
    server = name(name, namespace)
    GenServer.call(server, {:get_client_names_and_types_by_node, node_name, node_namespace})
  end

  def get_node_names(name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:get_node_names})
  end

  def get_node_names_with_enclaves(name, namespace \\ "/") do
    server = name(name, namespace)
    GenServer.call(server, {:get_node_names_with_enclaves})
  end

  def get_publisher_names_and_types_by_node(
        name,
        namespace,
        node_name,
        node_namespace,
        no_demangle \\ false
      ) do
    server = name(name, namespace)

    GenServer.call(
      server,
      {:get_publisher_names_and_types_by_node, node_name, node_namespace, no_demangle}
    )
  end

  def get_publishers_info_by_topic(
        name,
        namespace,
        topic_name,
        no_mangle \\ false
      ) do
    server = name(name, namespace)

    GenServer.call(
      server,
      {:get_publishers_info_by_topic, topic_name, no_mangle}
    )
  end

  def get_service_names_and_types(name, namespace) do
    server = name(name, namespace)
    GenServer.call(server, {:get_service_names_and_types})
  end

  def get_service_names_and_types_by_node(name, namespace, node_name, node_namespace) do
    server = name(name, namespace)
    GenServer.call(server, {:get_service_names_and_types_by_node, node_name, node_namespace})
  end

  def get_subscriber_names_and_types_by_node(
        name,
        namespace,
        node_name,
        node_namespace,
        no_demangle \\ false
      ) do
    server = name(name, namespace)

    GenServer.call(
      server,
      {:get_subscriber_names_and_types_by_node, node_name, node_namespace, no_demangle}
    )
  end

  def get_subscribers_info_by_topic(
        name,
        namespace,
        topic_name,
        no_mangle \\ false
      ) do
    server = name(name, namespace)

    GenServer.call(
      server,
      {:get_subscribers_info_by_topic, topic_name, no_mangle}
    )
  end

  def get_topic_names_and_types(name, namespace, no_demangle \\ false) do
    server = name(name, namespace)
    GenServer.call(server, {:get_topic_names_and_types, no_demangle})
  end

  # helpers

  defp names_and_types_charlist_to_string({:error, term}) do
    {:error, term}
  end

  defp names_and_types_charlist_to_string(names_and_types) do
    Enum.map(names_and_types, &name_and_types_charlist_to_string/1)
  end

  defp name_and_types_charlist_to_string({name, types}) do
    {"#{name}", Enum.map(types, &"#{&1}")}
  end

  defp topic_endpoint_info_list_charlist_to_string(topic_endpoint_info_list) do
    Enum.map(topic_endpoint_info_list, &topic_endpoint_info_charlist_to_string/1)
  end

  defp topic_endpoint_info_charlist_to_string(%{
         node_name: node_name,
         node_namespace: node_namespace,
         topic_type: topic_type,
         endpoint_gid: gid,
         endpoint_type: endpoint_type,
         qos_profile: qos
       }) do
    %{
      node_name: "#{node_name}",
      node_namespace: "#{node_namespace}",
      topic_type: "#{topic_type}",
      endpoint_gid: gid,
      endpoint_type: endpoint_type,
      qos_profile: qos
    }
  end

  # callbacks

  def init(args) do
    Process.flag(:trap_exit, true)

    context = Keyword.fetch!(args, :context)
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    node = Nif.rcl_node_init!(context, ~c"#{name}", ~c"#{namespace}")

    {:ok, %{context: context, node: node, name: name, namespace: namespace}}
  end

  def terminate(reason, state) do
    Nif.rcl_node_fini!(state.node)

    Logger.debug("#{__MODULE__}: #{inspect(reason)} #{Path.join(state.namespace, state.name)}")
  end

  def handle_call({:start_publisher, message_type, topic_name, qos}, _from, state) do
    return =
      ES.start_publisher(state.node, message_type, topic_name, state.name, state.namespace, qos)

    {:reply, return, state}
  end

  def handle_call({:stop_publisher, message_type, topic_name}, _from, state) do
    return = ES.stop_publisher(message_type, topic_name, state.name, state.namespace)

    {:reply, return, state}
  end

  def handle_call({:start_service, callback, service_type, service_name, qos}, _from, state) do
    return =
      ES.start_service(
        state.context,
        callback,
        state.node,
        service_type,
        service_name,
        state.name,
        state.namespace,
        qos
      )

    {:reply, return, state}
  end

  def handle_call({:stop_service, message_type, service_name}, _from, state) do
    return = ES.stop_service(message_type, service_name, state.name, state.namespace)

    {:reply, return, state}
  end

  def handle_call({:start_client, callback, service_type, service_name, qos}, _from, state) do
    return =
      ES.start_client(
        state.context,
        callback,
        state.node,
        service_type,
        service_name,
        state.name,
        state.namespace,
        qos
      )

    {:reply, return, state}
  end

  def handle_call({:stop_client, message_type, service_name}, _from, state) do
    return = ES.stop_client(message_type, service_name, state.name, state.namespace)

    {:reply, return, state}
  end

  def handle_call({:start_subscription, callback, message_type, topic_name, qos}, _from, state) do
    return =
      ES.start_subscription(
        state.context,
        state.node,
        callback,
        message_type,
        topic_name,
        state.name,
        state.namespace,
        qos
      )

    {:reply, return, state}
  end

  def handle_call({:stop_subscription, message_type, topic_name}, _from, state) do
    return = ES.stop_subscription(message_type, topic_name, state.name, state.namespace)

    {:reply, return, state}
  end

  def handle_call({:start_timer, period_ms, callback, timer_name}, _from, state) do
    return =
      ES.start_timer(state.context, period_ms, callback, timer_name, state.name, state.namespace)

    {:reply, return, state}
  end

  def handle_call({:stop_timer, timer_name}, _from, state) do
    return = ES.stop_timer(timer_name, state.name, state.namespace)

    {:reply, return, state}
  end

  def handle_call({:count_publishers, topic_name}, _from, state) do
    return = Graph.count_publishers(state.node, ~c"#{topic_name}")

    {:reply, return, state}
  end

  def handle_call({:count_subscribers, topic_name}, _from, state) do
    return = Graph.count_subscribers(state.node, ~c"#{topic_name}")

    {:reply, return, state}
  end

  def handle_call({:get_client_names_and_types_by_node, node_name, node_namespace}, _from, state) do
    return =
      Graph.get_client_names_and_types_by_node(
        state.node,
        ~c"#{node_name}",
        ~c"#{node_namespace}"
      )
      |> names_and_types_charlist_to_string()

    {:reply, return, state}
  end

  def handle_call({:get_node_names}, _from, state) do
    return =
      Graph.get_node_names(state.node)
      |> Enum.map(&{"#{elem(&1, 0)}", "#{elem(&1, 1)}"})

    {:reply, return, state}
  end

  def handle_call({:get_node_names_with_enclaves}, _from, state) do
    return =
      Graph.get_node_names_with_enclaves(state.node)
      |> Enum.map(&{"#{elem(&1, 0)}", "#{elem(&1, 1)}", "#{elem(&1, 2)}"})

    {:reply, return, state}
  end

  def handle_call(
        {:get_publisher_names_and_types_by_node, node_name, node_namespace, no_demangle},
        _from,
        state
      ) do
    return =
      Graph.get_publisher_names_and_types_by_node(
        state.node,
        ~c"#{node_name}",
        ~c"#{node_namespace}",
        no_demangle
      )
      |> names_and_types_charlist_to_string()

    {:reply, return, state}
  end

  def handle_call(
        {:get_publishers_info_by_topic, topic_name, no_mangle},
        _from,
        state
      ) do
    return =
      Graph.get_publishers_info_by_topic(
        state.node,
        ~c"#{topic_name}",
        no_mangle
      )
      |> topic_endpoint_info_list_charlist_to_string()

    {:reply, return, state}
  end

  def handle_call({:get_service_names_and_types}, _form, state) do
    return =
      Graph.get_service_names_and_types(state.node)
      |> names_and_types_charlist_to_string()

    {:reply, return, state}
  end

  def handle_call({:get_service_names_and_types_by_node, node_name, node_namespace}, _from, state) do
    return =
      Graph.get_service_names_and_types_by_node(
        state.node,
        ~c"#{node_name}",
        ~c"#{node_namespace}"
      )
      |> names_and_types_charlist_to_string()

    {:reply, return, state}
  end

  def handle_call(
        {:get_subscriber_names_and_types_by_node, node_name, node_namespace, no_demangle},
        _from,
        state
      ) do
    return =
      Graph.get_subscriber_names_and_types_by_node(
        state.node,
        ~c"#{node_name}",
        ~c"#{node_namespace}",
        no_demangle
      )
      |> names_and_types_charlist_to_string()

    {:reply, return, state}
  end

  def handle_call(
        {:get_subscribers_info_by_topic, topic_name, no_mangle},
        _from,
        state
      ) do
    return =
      Graph.get_subscribers_info_by_topic(
        state.node,
        ~c"#{topic_name}",
        no_mangle
      )
      |> topic_endpoint_info_list_charlist_to_string()

    {:reply, return, state}
  end

  def handle_call({:get_topic_names_and_types, no_demangle}, _from, state) do
    return =
      Graph.get_topic_names_and_types(state.node, no_demangle)
      |> names_and_types_charlist_to_string()

    {:reply, return, state}
  end

  def handle_call({:service_server_is_available, client}, _from, state) do
    return = Graph.service_server_is_available(state.node, client)

    {:reply, return, state}
  end
end
