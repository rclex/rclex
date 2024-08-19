defmodule Rclex.NodesSupervisor do
  @moduledoc false

  use DynamicSupervisor

  def start_link(args) do
    DynamicSupervisor.start_link(__MODULE__, args, name: name())
  end

  def name() do
    __MODULE__
  end

  def start_child(context, name, namespace \\ "/", graph_change_callback \\ nil) do
    DynamicSupervisor.start_child(
      name(),
      {Rclex.NodeSupervisor, [context: context, name: name, namespace: namespace, graph_change_callback: graph_change_callback]}
    )
  end

  def terminate_child(name, namespace \\ "/") do
    name = Rclex.NodeSupervisor.name(name, namespace)

    case GenServer.whereis(name) do
      nil -> {:error, :not_found}
      {_atom, _node} -> raise("should not happen")
      pid -> DynamicSupervisor.terminate_child(name(), pid)
    end
  end

  # callbacks

  def init(_args) do
    DynamicSupervisor.init(strategy: :one_for_one)
  end
end
