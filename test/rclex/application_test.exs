defmodule Rclex.ApplicationTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Rclex.Pkgs.StdMsgs

  setup do
    :ok = Application.ensure_started(:rclex)
    on_exit(fn -> capture_log(fn -> Application.stop(:rclex) end) end)
  end

  test "Application.stop/1, confirm shutdown order" do
    node_names = ["name1", "name2"]

    for name <- node_names do
      :ok = Rclex.start_node(name)
      :ok = Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", name)
      :ok = Rclex.start_subscription(fn _msg -> nil end, StdMsgs.Msg.String, "/chatter", name)
      :ok = Rclex.start_timer(10, fn -> nil end, "timer", name)
    end

    logs =
      capture_log(fn -> :ok = Application.stop(:rclex) end)
      |> String.split("\n")
      |> Enum.filter(&String.contains?(&1, ":shutdown"))

    {logs, [context_should_shutdown_last]} = Enum.split(logs, Enum.count(logs) - 1)

    for name <- node_names do
      node_logs = Enum.filter(logs, &String.contains?(&1, name))
      assert Enum.count(node_logs) == 4
      assert List.last(node_logs) =~ "Node: :shutdown"
    end

    assert context_should_shutdown_last =~ "Context: :shutdown"
  end
end
