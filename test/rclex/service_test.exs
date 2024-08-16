defmodule Rclex.ServiceTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Rclex.Service
  alias Rclex.Nif
  alias Rclex.Pkgs.StdSrvs

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
             Service.start_link(
               context: context,
               node: node,
               service_type: StdSrvs.Srv.SetBool,
               service_name: "/set_test_bool",
               name: name,
               namespace: namespace,
               callback: fn _message -> %StdSrvs.Srv.SetBool.Response{success: true} end
             )

    assert capture_log(fn -> :ok = GenServer.stop(pid, :shutdown) end) =~
             "Service: :shutdown"
  end

  test "start_link/1 failed in init/1 callback", %{
    context: context,
    node: node,
    name: name,
    namespace: namespace
  } do
    Process.flag(:trap_exit, true)

    assert {:error, _} =
             Service.start_link(
               context: context,
               node: node,
               service_type: StdSrvs.Srv.SetBool,
               service_name: "set_test_bool",
               name: name,
               namespace: namespace,
               callback: fn _message -> %StdSrvs.Srv.SetBool.Response{success: true} end
             )
  end
end
