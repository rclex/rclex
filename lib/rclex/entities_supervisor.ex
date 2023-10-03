defmodule Rclex.EntitiesSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(args) do
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    DynamicSupervisor.start_link(__MODULE__, args, name: name(name, namespace))
  end

  def name(name, namespace \\ "/") do
    {:global, {:entities_supervisor, name, namespace}}
  end

  def start_publisher(node, message_type, topic_name, name, namespace \\ "/") do
    DynamicSupervisor.start_child(
      name(name, namespace),
      {Rclex.Publisher,
       [
         node: node,
         message_type: message_type,
         topic_name: topic_name,
         name: name,
         namespace: namespace
       ]}
    )
  end

  def start_subscription(
        context,
        node,
        callback,
        message_type,
        topic_name,
        name,
        namespace \\ "/"
      ) do
    DynamicSupervisor.start_child(
      name(name, namespace),
      {Rclex.Subscription,
       [
         context: context,
         node: node,
         callback: callback,
         message_type: message_type,
         topic_name: topic_name,
         name: name,
         namespace: namespace
       ]}
    )
  end

  def stop_publisher(message_type, topic_name, name, namespace) do
    entity_name = Rclex.Publisher.name(message_type, topic_name, name, namespace)
    stop_entity(entity_name, name, namespace)
  end

  def stop_subscription(message_type, topic_name, name, namespace) do
    entity_name = Rclex.Subscription.name(message_type, topic_name, name, namespace)
    stop_entity(entity_name, name, namespace)
  end

  defp stop_entity(entity_name, name, namespace) do
    case GenServer.whereis(entity_name) do
      nil -> {:error, :not_found}
      {_atom, _node} -> raise("should not happen")
      pid -> DynamicSupervisor.terminate_child(name(name, namespace), pid)
    end
  end

  # callbacks

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
