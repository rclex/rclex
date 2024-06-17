defmodule RclexTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Rclex.Pkgs.StdMsgs
  alias Rclex.Pkgs.StdSrvs
  alias Rclex.Pkgs.RclInterfaces
  alias Rclex.NodeSupervisor

  setup do
    :ok = Application.ensure_started(:rclex)
    on_exit(fn -> capture_log(fn -> Application.stop(:rclex) end) end)
  end

  describe "node" do
    test "start_node/1" do
      assert :ok = Rclex.start_node("name")
      assert {:error, :already_started} = Rclex.start_node("name")

      assert is_pid(GenServer.whereis(NodeSupervisor.name("name"))) == true
    end

    test "start_node/1, wrong node name" do
      assert {:error, _} = Rclex.start_node("/name")
    end

    test "stop_node/1" do
      :ok = Rclex.start_node("name")
      true = is_pid(GenServer.whereis(NodeSupervisor.name("name")))

      assert capture_log(fn -> :ok = Rclex.stop_node("name") end) =~ "Node: :shutdown"
      assert {:error, :not_found} = Rclex.stop_node("name")

      assert is_nil(GenServer.whereis(NodeSupervisor.name("name")))
    end

    test "stop_node/1, node doesn't exist" do
      assert {:error, :not_found} = Rclex.stop_node("notexists")
    end

    test "stop_node/1, confirm shutdown order" do
      :ok = Rclex.start_node("name")
      :ok = Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "name")
      :ok = Rclex.start_subscription(fn _msg -> nil end, StdMsgs.Msg.String, "/chatter", "name")
      :ok = Rclex.start_timer(10, fn -> nil end, "timer", "name")

      logs =
        capture_log(fn -> :ok = Rclex.stop_node("name") end)
        |> String.split("\n")
        |> Enum.filter(&String.contains?(&1, ":shutdown"))

      assert Enum.count(logs) == 4
      assert List.last(logs) =~ "Node: :shutdown"
    end
  end

  describe "publisher" do
    setup do
      :ok = Rclex.start_node("name")
      on_exit(fn -> capture_log(fn -> Rclex.stop_node("name") end) end)
    end

    test "start_publisher/3" do
      assert :ok = Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "name")

      assert {:error, :already_started} =
               Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "name")
    end

    test "start_publisher/3, node doesn't exist" do
      assert {:noproc, _} =
               catch_exit(Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "notexists"))
    end

    test "start_publisher/3, wrong topic name" do
      assert {:error, _} = Rclex.start_publisher(StdMsgs.Msg.String, "chatter", "name")
    end

    test "stop_publisher/3" do
      :ok = Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "name")

      assert capture_log(fn ->
               :ok = Rclex.stop_publisher(StdMsgs.Msg.String, "/chatter", "name")
             end) =~ "Publisher: :shutdown"

      assert {:error, :not_found} = Rclex.stop_publisher(StdMsgs.Msg.String, "/chatter", "name")
    end

    test "stop_publisher/3, node doesn't exist" do
      assert {:noproc, _} =
               catch_exit(Rclex.stop_publisher(StdMsgs.Msg.String, "/chatter", "notexists"))
    end
  end

  describe "subscription" do
    setup do
      :ok = Rclex.start_node("name")
      on_exit(fn -> capture_log(fn -> Rclex.stop_node("name") end) end)

      %{callback: fn _message -> nil end}
    end

    test "start_subscription/4", %{callback: callback} do
      assert :ok = Rclex.start_subscription(callback, StdMsgs.Msg.String, "/chatter", "name")

      assert {:error, :already_started} =
               Rclex.start_subscription(callback, StdMsgs.Msg.String, "/chatter", "name")
    end

    test "start_subscription/4, node doesn't exist", %{callback: callback} do
      assert {:noproc, _} =
               catch_exit(
                 Rclex.start_subscription(callback, StdMsgs.Msg.String, "/chatter", "notexists")
               )
    end

    test "start_subscription/4, wrong topic name", %{callback: callback} do
      assert {:error, _} =
               Rclex.start_subscription(callback, StdMsgs.Msg.String, "chatter", "name")
    end

    test "stop_subscription/3", %{callback: callback} do
      :ok = Rclex.start_subscription(callback, StdMsgs.Msg.String, "/chatter", "name")

      assert capture_log(fn ->
               :ok = Rclex.stop_subscription(StdMsgs.Msg.String, "/chatter", "name")
             end) =~ "Subscription: :shutdown"

      assert {:error, :not_found} =
               Rclex.stop_subscription(StdMsgs.Msg.String, "/chatter", "name")
    end

    test "stop_subscription/3, node doesn't exist", %{callback: _callback} do
      assert {:noproc, _} =
               catch_exit(Rclex.stop_subscription(StdMsgs.Msg.String, "/chatter", "notexists"))
    end
  end

  describe "pub/sub" do
    setup do
      name = "name"
      topic_name = "/chatter"

      :ok = Rclex.start_node(name)

      me = self()
      :ok = Rclex.start_subscription(&send(me, &1), StdMsgs.Msg.String, topic_name, name)
      :ok = Rclex.start_publisher(StdMsgs.Msg.String, topic_name, name)

      on_exit(fn -> capture_log(fn -> Rclex.stop_node(name) end) end)

      %{topic_name: topic_name, name: name}
    end

    test "publish/3", %{topic_name: topic_name, name: name} do
      for i <- 1..100 do
        message = struct(StdMsgs.Msg.String, %{data: "publish #{i}"})
        assert Rclex.publish(message, topic_name, name) == :ok
        assert_receive ^message
      end
    end
  end

  describe "service" do
    setup do
      :ok = Rclex.start_node("name")
      on_exit(fn -> capture_log(fn -> Rclex.stop_node("name") end) end)

      %{
        callback: fn %StdSrvs.Srv.SetBoolRequest{data: data} ->
          %StdSrvs.Srv.SetBoolResponse{success: data}
        end
      }
    end

    test "start_service/4", %{callback: callback} do
      assert :ok = Rclex.start_service(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "name")

      assert {:error, :already_started} =
               Rclex.start_service(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "name")
    end

    test "start_service/4, node doesn't exist", %{callback: callback} do
      assert {:noproc, _} =
               catch_exit(
                 Rclex.start_service(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "notexists")
               )
    end

    test "start_service/4, wrong service name", %{callback: callback} do
      assert {:error, _} =
               Rclex.start_service(callback, StdSrvs.Srv.SetBool, "set_test_bool", "name")
    end

    test "stop_service/3", %{callback: callback} do
      :ok = Rclex.start_service(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "name")

      assert capture_log(fn ->
               :ok = Rclex.stop_service(StdSrvs.Srv.SetBool, "/set_test_bool", "name")
             end) =~ "Service: :shutdown"

      assert {:error, :not_found} =
               Rclex.stop_service(StdSrvs.Srv.SetBool, "/set_test_bool", "name")
    end

    test "stop_service/3, node doesn't exist", %{callback: _callback} do
      assert {:noproc, _} =
               catch_exit(Rclex.stop_service(StdSrvs.Srv.SetBool, "/chatter", "notexists"))
    end
  end

  describe "client" do
    setup do
      :ok = Rclex.start_node("name")
      on_exit(fn -> capture_log(fn -> Rclex.stop_node("name") end) end)

      %{
        callback: fn _request, _response ->
          nil
        end
      }
    end

    test "start_client/4", %{callback: callback} do
      assert :ok = Rclex.start_client(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "name")

      assert {:error, :already_started} =
               Rclex.start_client(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "name")
    end

    test "start_client/4, node doesn't exist", %{callback: callback} do
      assert {:noproc, _} =
               catch_exit(
                 Rclex.start_client(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "notexists")
               )
    end

    test "start_client/4, wrong client name", %{callback: callback} do
      assert {:error, _} =
               Rclex.start_client(callback, StdSrvs.Srv.SetBool, "set_test_bool", "name")
    end

    test "stop_client/3", %{callback: callback} do
      :ok = Rclex.start_client(callback, StdSrvs.Srv.SetBool, "/set_test_bool", "name")

      assert capture_log(fn ->
               :ok = Rclex.stop_client(StdSrvs.Srv.SetBool, "/set_test_bool", "name")
             end) =~ "Client: :shutdown"

      assert {:error, :not_found} =
               Rclex.stop_client(StdSrvs.Srv.SetBool, "/set_test_bool", "name")
    end

    test "stop_client/3, node doesn't exist", %{callback: _callback} do
      assert {:noproc, _} =
               catch_exit(Rclex.stop_client(StdSrvs.Srv.SetBool, "/chatter", "notexists"))
    end
  end

  describe "calling services" do
    setup do
      name = "name"
      service_name = "/set_test_bool"

      :ok = Rclex.start_node(name)

      service_callback = fn %RclInterfaces.Srv.GetParameterTypesRequest{names: names} ->
        %RclInterfaces.Srv.GetParameterTypesResponse{
          types: Enum.map_join(names, fn n -> String.length(to_string(n)) end)
        }
      end

      me = self()

      receive_callback = fn _request, response ->
        send(me, response)
      end

      :ok =
        Rclex.start_service(
          service_callback,
          RclInterfaces.Srv.GetParameterTypes,
          service_name,
          name
        )

      :ok =
        Rclex.start_client(
          receive_callback,
          RclInterfaces.Srv.GetParameterTypes,
          service_name,
          name
        )

      on_exit(fn -> capture_log(fn -> Rclex.stop_node(name) end) end)

      %{
        name: name,
        service_name: service_name
      }
    end

    test "call_async/4", %{service_name: service_name, name: name} do
      request = struct(RclInterfaces.Srv.GetParameterTypesRequest, %{names: [~c"test"]})
      assert Rclex.call_async(request, "does_not_exist", name) == {:error, :not_found}

      for i <- 1..10 do
        names = Enum.map(0..i, fn _ -> ~c"abc" end)
        request = struct(RclInterfaces.Srv.GetParameterTypesRequest, %{names: names})

        response =
          struct(RclInterfaces.Srv.GetParameterTypesResponse, %{
            types: Enum.map_join(names, fn n -> String.length(to_string(n)) end)
          })

        assert Rclex.call_async(request, service_name, name) == :ok
        assert_receive ^response
      end
    end
  end

  describe "timer" do
    setup do
      :ok = Rclex.start_node("name")
      on_exit(fn -> capture_log(fn -> Rclex.stop_node("name") end) end)

      %{callback: fn -> nil end}
    end

    test "start_timer/4", %{callback: callback} do
      assert :ok = Rclex.start_timer(10, callback, "timer", "name")
      assert {:error, :already_started} = Rclex.start_timer(10, callback, "timer", "name")
    end

    test "start_timer/4, node doesn't exist", %{callback: callback} do
      assert {:noproc, _} = catch_exit(Rclex.start_timer(10, callback, "timer", "notexists"))
    end

    test "start_timer/4, wrong callback" do
      assert {:error, _} = Rclex.start_timer(10, fn _wrong_args -> nil end, "timer", "name")
    end

    test "stop_timer/3", %{callback: callback} do
      :ok = Rclex.start_timer(10, callback, "timer", "name")

      assert capture_log(fn -> :ok = Rclex.stop_timer("timer", "name") end) =~ "Timer: :shutdown"
      assert {:error, :not_found} = Rclex.stop_timer("timer", "name")
    end

    test "stop_timer/3, node doesn't exist", %{callback: _callback} do
      assert {:noproc, _} = catch_exit(Rclex.stop_timer("timer", "notexists"))
    end
  end
end
