defmodule Rclex.ActionClientTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Rclex.ActionClient
  alias Rclex.Nif
  alias Rclex.Pkgs.Turtlesim.Action

  setup do
    capture_log(fn -> Application.stop(:rclex) end)
    Process.flag(:trap_exit, true)

    name = "name"
    namespace = "/namespace"

    context = Nif.rcl_init!()
    node = Nif.rcl_node_init!(context, ~c"#{name}", ~c"#{namespace}")

    on_exit(fn ->
      :ok = Nif.rcl_node_fini!(node)
      :ok = Nif.rcl_fini!(context)
    end)

    %{context: context, node: node, name: name, namespace: namespace}
  end

  test "start_link/1", %{context: context, node: node, name: name, namespace: namespace} do
    Process.flag(:trap_exit, true)

    assert {:ok, pid} =
             ActionClient.start_link(
               context: context,
               node: node,
               action_type: Action.RotateAbsolute,
               action_name: "/rotate_absolute",
               name: name,
               namespace: namespace
             )

    assert capture_log(fn -> :ok = GenServer.stop(pid, :shutdown) end) =~
             "ActionClient: :shutdown"
  end

  test "start_link/1 failed in init/1 callback", %{
    context: context,
    node: node,
    name: name,
    namespace: namespace
  } do
    Process.flag(:trap_exit, true)

    assert {:error, _} =
             ActionClient.start_link(
               context: context,
               node: node,
               action_type: Action.RotateAbsolute,
               action_name: "rotate_absolute",
               name: name,
               namespace: namespace
             )
  end
end
