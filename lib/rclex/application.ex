defmodule Rclex.Application do
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Rclex.Context, []},
      {Rclex.NodesSupervisor, []},
      {PartitionSupervisor, child_spec: Task.Supervisor, name: Rclex.TaskSupervisors}
    ]

    Supervisor.start_link(children, strategy: :one_for_one)
  end
end
