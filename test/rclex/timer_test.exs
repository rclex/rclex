defmodule Rclex.TimerTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Rclex.Timer
  alias Rclex.Nif

  setup do
    capture_log(fn -> Application.stop(:rclex) end)

    name = "name"
    namespace = "/namespace"

    context = Nif.rcl_init!()

    on_exit(fn ->
      :ok = Nif.rcl_fini!(context)
    end)

    %{context: context, name: name, namespace: namespace}
  end

  test "start_link/1", %{context: context, name: name, namespace: namespace} do
    Process.flag(:trap_exit, true)

    assert {:ok, pid} =
             Timer.start_link(
               context: context,
               period_ms: 10,
               timer_name: "timer",
               name: name,
               namespace: namespace,
               callback: fn -> nil end
             )

    assert capture_log(fn -> :ok = GenServer.stop(pid, :shutdown) end) =~
             "Timer: :shutdown"
  end

  test "start_link/1 failed in init/1 callback", %{
    context: context,
    name: name,
    namespace: namespace
  } do
    Process.flag(:trap_exit, true)

    assert {:error, _} =
             Timer.start_link(
               context: context,
               period_ms: 10,
               timer_name: "timer",
               name: name,
               namespace: namespace,
               callback: fn _bad_args -> nil end
             )
  end
end
