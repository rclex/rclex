defmodule Rclex.PublisherTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Rclex.Publisher
  alias Rclex.Nif
  alias Rclex.Pkgs.StdMsgs

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
             Publisher.start_link(
               context: context,
               node: node,
               message_type: StdMsgs.Msg.String,
               topic_name: "/chatter",
               name: name,
               namespace: namespace
             )

    assert capture_log(fn -> :ok = GenServer.stop(pid, :shutdown) end) =~
             "Publisher: :shutdown"
  end

  test "start_link/1 failed in init/1 callback", %{
    context: context,
    node: node,
    name: name,
    namespace: namespace
  } do
    Process.flag(:trap_exit, true)

    assert {:error, _} =
             Publisher.start_link(
               context: context,
               node: node,
               message_type: StdMsgs.Msg.String,
               topic_name: "no_leading_slash",
               name: name,
               namespace: namespace
             )
  end
end
