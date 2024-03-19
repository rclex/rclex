defmodule Rclex.NodeSupervisor do
  @moduledoc false

  use Supervisor, restart: :transient

  alias Rclex.Node
  alias Rclex.EntitiesSupervisor

  def start_link(args) do
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    Supervisor.start_link(__MODULE__, args, name: name(name, namespace))
  end

  def name(name, namespace \\ "/") do
    {:global, {:supervisor, name, namespace}}
  end

  # callbacks

  def init(args) do
    children = [
      {Node, args},
      {EntitiesSupervisor, args}
    ]

    Supervisor.init(children, strategy: :one_for_all)
  end
end
