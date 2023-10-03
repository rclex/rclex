defmodule Rclex.NodeTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Rclex.Node
  alias Rclex.Nif

  setup do
    capture_log(fn -> Application.stop(:rclex) end)

    context = Nif.rcl_init!()
    on_exit(fn -> :ok = Nif.rcl_fini!(context) end)

    %{context: context}
  end

  test "start_link/1", %{context: context} do
    Process.flag(:trap_exit, true)

    assert {:ok, pid} = Node.start_link(context: context, name: "name", namespace: "/namespace")

    assert capture_log(fn -> :ok = GenServer.stop(pid, :shutdown) end) =~
             "Node: :shutdown"
  end

  test "start_link/1 failed in init/1 callback", %{context: context} do
    Process.flag(:trap_exit, true)

    assert {:error, _} =
             Node.start_link(context: context, name: "name", namespace: "no_leading_slash")
  end
end
