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
          types: Enum.map(names, fn n -> String.length(to_string(n)) end)
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
            types: Enum.map(names, fn n -> String.length(to_string(n)) end)
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

  describe "graph" do
    setup do
      name = "name"
      topic_name = "/chatter"
      service_name = "/get_test_params_types"
      service_type = RclInterfaces.Srv.GetParameterTypes

      :ok = Rclex.start_node("name")
      :ok = Rclex.start_publisher(StdMsgs.Msg.String, topic_name, name)
      :ok = Rclex.start_subscription(fn _msg -> nil end, StdMsgs.Msg.String, topic_name, name)

      service_callback = fn %RclInterfaces.Srv.GetParameterTypesRequest{names: names} ->
        %RclInterfaces.Srv.GetParameterTypesResponse{
          types: Enum.map(names, fn n -> String.length(to_string(n)) end)
        }
      end

      receive_callback = fn _request, _response ->
        nil
      end

      :ok =
        Rclex.start_service(
          service_callback,
          service_type,
          service_name,
          name
        )

      :ok = Rclex.start_client(receive_callback, service_type, service_name, name)

      on_exit(fn -> capture_log(fn -> Rclex.stop_node("name") end) end)
      :timer.sleep(50)

      %{
        name: name,
        topic_name: topic_name,
        service_type: service_type,
        service_name: service_name
      }
    end

    test "count_publishers/2", %{} do
      assert 1 = Rclex.count_publishers("name", "/chatter")
    end

    test "count_subscribers/2", %{name: name, topic_name: topic_name} do
      assert 1 = Rclex.count_subscribers(name, topic_name)
    end

    test "get_client_names_and_types_by_node/4", %{name: name, service_name: service_name} do
      assert [{^service_name, ["rcl_interfaces/srv/GetParameterTypes"]}] =
               Rclex.get_client_names_and_types_by_node(
                 name,
                 name,
                 "/"
               )
    end

    test "get_node_names/2", %{} do
      assert [{"name", "/"}] = Rclex.get_node_names("name")
    end

    test "get_node_names_with_enclaves/2", %{} do
      assert [{"name", "/", "/"}] = Rclex.get_node_names_with_enclaves("name")
    end

    test "get_publisher_names_and_types_by_node/4", %{topic_name: topic_name} do
      assert [{^topic_name, ["std_msgs/msg/String"]}] =
               Rclex.get_publisher_names_and_types_by_node("name", "name", "/")

      assert {:error, :not_found} =
               Rclex.get_publisher_names_and_types_by_node("name", "non_existent", "/")
    end

    test "get_publishers_info_by_topic/3", %{topic_name: topic_name} do
      [info] = Rclex.get_publishers_info_by_topic("name", topic_name)

      assert is_binary(info.endpoint_gid)
      %qos_type{} = info.qos_profile
      assert qos_type == Rclex.QoS

      assert %{
               node_name: "name",
               node_namespace: "/",
               topic_type: "std_msgs/msg/String",
               endpoint_type: :publisher
               # endpoint_gid: <<_gid>>,
               # qos_profile: %Rclex.QoS{...}
             } = Map.drop(info, [:endpoint_gid, :qos_profile])
    end

    test "get_service_names_and_types/2", %{name: name, service_name: service_name} do
      assert [{^service_name, ["rcl_interfaces/srv/GetParameterTypes"]}] =
               Rclex.get_service_names_and_types(name)
    end

    test "get_service_names_and_types_by_node/4", %{name: name, service_name: service_name} do
      [{^service_name, ["rcl_interfaces/srv/GetParameterTypes"]}] =
        Rclex.get_service_names_and_types_by_node(name, name, "/")
    end

    test "get_subscriber_names_and_types_by_node/4", %{topic_name: topic_name} do
      assert [{^topic_name, ["std_msgs/msg/String"]}] =
               Rclex.get_subscriber_names_and_types_by_node("name", "name", "/")

      assert {:error, :not_found} =
               Rclex.get_subscriber_names_and_types_by_node("name", "non_existent", "/")
    end

    test "get_subscribers_info_by_topic/3", %{topic_name: topic_name} do
      [info] = Rclex.get_subscribers_info_by_topic("name", topic_name)

      assert is_binary(info.endpoint_gid)
      %qos_type{} = info.qos_profile
      assert qos_type == Rclex.QoS

      assert %{
               node_name: "name",
               node_namespace: "/",
               topic_type: "std_msgs/msg/String",
               endpoint_type: :subscription
               # endpoint_gid: <<_gid>>,
               # qos_profile: %Rclex.QoS{...}
             } = Map.drop(info, [:endpoint_gid, :qos_profile])
    end

    test "get_topic_names_and_types/2", %{} do
      assert [{"/chatter", ["std_msgs/msg/String"]}] = Rclex.get_topic_names_and_types("name")
    end

    test "service_server_available?/4", %{
      name: name,
      service_type: service_type,
      service_name: service_name
    } do
      true = Rclex.service_server_available?(service_type, service_name, name)

      {:error, :not_found} =
        Rclex.service_server_available?(service_type, "/does_not_exist", name)
    end
  end
end
