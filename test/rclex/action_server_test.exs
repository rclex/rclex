defmodule Rclex.ActionServerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Rclex.ActionServer
  alias Rclex.Nif
  alias Rclex.Pkgs.Turtlesim.Action

  setup do
    capture_log(fn -> Application.stop(:rclex) end)

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
             ActionServer.start_link(
               context: context,
               node: node,
               action_type: Action.RotateAbsolute,
               action_name: "/rotate_absolute",
               name: name,
               namespace: namespace,
               execute_callback: fn _req, _fb_cb -> nil end,
               goal_callback: fn _req ->
                 false
               end
             )

    assert capture_log(fn -> :ok = GenServer.stop(pid, :shutdown) end) =~
             "ActionServer: :shutdown"
  end

  test "start_link/1 failed in init/1 callback", %{
    context: context,
    node: node,
    name: name,
    namespace: namespace
  } do
    Process.flag(:trap_exit, true)

    assert {:error, _} =
             ActionServer.start_link(
               context: context,
               node: node,
               action_type: Action.RotateAbsolute,
               action_name: "rotate_absolute",
               name: name,
               namespace: namespace,
               execute_callback: nil,
               goal_callback: nil
             )
  end
end
