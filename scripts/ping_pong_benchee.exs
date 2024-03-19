require Logger

alias Rclex.Pkgs.StdMsgs

Logger.configure(level: :none)

Benchee.run(
  %{
    "PingPong" => fn input ->
      for _ <- 1..100 do
        Rclex.publish(input.message, "/ping", input.start_node_name)

        receive do
          :next -> nil
        end
      end
    end
  },
  inputs: %{
    "same  node 64bytes message" => %{
      message: %StdMsgs.Msg.String{data: String.duplicate("a", 64)},
      node_names: ["node1"],
      start_node_name: "node1"
    },
    "other node 64bytes message" => %{
      message: %StdMsgs.Msg.String{data: String.duplicate("a", 64)},
      node_names: ["node1", "node2"],
      start_node_name: "node1"
    }
  },
  before_scenario: fn input ->
    :ok = Application.ensure_started(:rclex)

    node = Enum.at(input.node_names, 0)
    Rclex.start_node(node)
    Rclex.start_publisher(StdMsgs.Msg.String, "/ping", node)
    pid = self()
    callback = fn _message -> send(pid, :next) end
    Rclex.start_subscription(callback, StdMsgs.Msg.String, "/pong", node)

    node = Enum.at(input.node_names, 1) || Enum.at(input.node_names, 0)
    Rclex.start_node(node)
    Rclex.start_publisher(StdMsgs.Msg.String, "/pong", node)
    callback = fn message -> Rclex.publish(message, "/pong", node) end
    Rclex.start_subscription(callback, StdMsgs.Msg.String, "/ping", node)

    input
  end,
  after_scenario: fn _input -> :ok = Application.stop(:rclex) end
)
