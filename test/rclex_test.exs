defmodule RclexTest do
  use ExUnit.Case

  import ExUnit.CaptureLog

  alias Rclex.Pkgs.Turtlesim
  alias Rclex.Pkgs.StdMsgs
  alias Rclex.Pkgs.StdSrvs
  alias Rclex.Pkgs.RclInterfaces
  alias Rclex.Pkgs.Turtlesim.Action
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

    test "start_node\2, graph change events" do
      me = self()
      graph_change_callback = fn -> send(me, :graph_changed) end

      :ok = Rclex.start_node("name", namespace: "/", graph_change_callback: graph_change_callback)
      assert_receive :graph_changed
      :ok = Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "name", namespace: "/")
      assert_receive :graph_changed

      :ok =
        Rclex.start_subscription(fn _msg -> nil end, StdMsgs.Msg.String, "/chatter", "name",
          namespace: "/"
        )

      assert_receive :graph_changed
      :ok = Rclex.start_timer(10, fn -> nil end, "timer", "name", namespace: "/")
      assert_receive :graph_changed

      logs =
        capture_log(fn ->
          :ok = Rclex.stop_node("name", namespace: "/")
          assert_receive :graph_changed
          assert_receive :graph_changed
        end)
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
        callback: fn %StdSrvs.Srv.SetBool.Request{data: data} ->
          %StdSrvs.Srv.SetBool.Response{success: data}
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

      service_callback = fn %RclInterfaces.Srv.GetParameterTypes.Request{names: names} ->
        %RclInterfaces.Srv.GetParameterTypes.Response{
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
      request = struct(RclInterfaces.Srv.GetParameterTypes.Request, %{names: [~c"test"]})
      assert Rclex.call_async(request, "does_not_exist", name) == {:error, :not_found}

      for i <- 1..10 do
        names = Enum.map(0..i, fn _ -> ~c"abc" end)
        request = struct(RclInterfaces.Srv.GetParameterTypes.Request, %{names: names})

        response =
          struct(RclInterfaces.Srv.GetParameterTypes.Response, %{
            types: Enum.map_join(names, fn n -> String.length(to_string(n)) end)
          })

        assert Rclex.call_async(request, service_name, name) == :ok
        assert_receive ^response
      end
    end
  end

  describe "action server" do
    setup do
      :ok = Rclex.start_node("name")
      on_exit(fn -> capture_log(fn -> Rclex.stop_node("name") end) end)

      execute_callback = fn %Action.RotateAbsolute.Goal{theta: val}, fb_cb ->
        for i <- 1..10 do
          Process.sleep(200)
          fb_cb.(%Action.RotateAbsolute.Feedback{remaining: val - val * 0.1 * i})
        end

        %Action.RotateAbsolute.Result{delta: 1.0 * val}
      end

      %{
        action_type: Action.RotateAbsolute,
        execute_callback: execute_callback
      }
    end

    test "start_action_server/4", %{
      execute_callback: execute_callback,
      action_type: action_type
    } do
      assert :ok =
               Rclex.start_action_server(
                 execute_callback,
                 action_type,
                 "/rotate_absolute",
                 "name",
                 goal_callback: fn _req -> :accept end
               )

      # Process.sleep(20000)

      assert {:error, :already_started} =
               Rclex.start_action_server(
                 execute_callback,
                 action_type,
                 "/rotate_absolute",
                 "name"
               )
    end

    test "start_action_server/4, node doesn't exist", %{
      execute_callback: execute_callback,
      action_type: action_type
    } do
      assert {:noproc, _} =
               catch_exit(
                 Rclex.start_action_server(
                   execute_callback,
                   action_type,
                   "/rotate_absolute",
                   "not_exist"
                 )
               )
    end

    test "start_action_server/4, wrong action name", %{
      execute_callback: execute_callback,
      action_type: action_type
    } do
      assert {:error, _} =
               Rclex.start_action_server(
                 execute_callback,
                 action_type,
                 "rotate_absolute",
                 "name"
               )
    end

    test "stop_action_server/3", %{
      execute_callback: execute_callback,
      action_type: action_type
    } do
      :ok =
        Rclex.start_action_server(
          execute_callback,
          action_type,
          "/rotate_absolute",
          "name"
        )

      assert capture_log(fn ->
               :ok = Rclex.stop_action_server(action_type, "/rotate_absolute", "name")
             end) =~ "ActionServer: :shutdown"

      assert {:error, :not_found} =
               Rclex.stop_action_server(action_type, "/rotate_absolute", "name")
    end

    test "stop_action_server/3, node doesn't exist", %{action_type: action_type} do
      assert {:noproc, _} =
               catch_exit(Rclex.stop_action_server(action_type, "/rotate_absolute", "notexists"))
    end
  end

  describe "action client" do
    setup do
      :ok = Rclex.start_node("name")
      on_exit(fn -> capture_log(fn -> Rclex.stop_node("name") end) end)

      %{
        action_type: Action.RotateAbsolute
      }
    end

    test "start_action_client/3", %{
      action_type: action_type
    } do
      assert :ok =
               Rclex.start_action_client(
                 action_type,
                 "/rotate_absolute",
                 "name"
               )

      assert {:error, :already_started} =
               Rclex.start_action_client(
                 action_type,
                 "/rotate_absolute",
                 "name"
               )
    end

    test "start_action_client/3, node doesn't exist", %{
      action_type: action_type
    } do
      assert {:noproc, _} =
               catch_exit(
                 Rclex.start_action_client(
                   action_type,
                   "/rotate_absolute",
                   "not_exist"
                 )
               )
    end

    test "start_action_client/3, wrong action name", %{
      action_type: action_type
    } do
      assert {:error, _} =
               Rclex.start_action_client(
                 action_type,
                 "rotate_absolute",
                 "name"
               )
    end

    test "action_server_available?/3", %{
      action_type: action_type
    } do
      :ok =
        Rclex.start_action_client(
          action_type,
          "/rotate_absolute",
          "name"
        )

      assert false == Rclex.action_server_available?(action_type, "/rotate_absolute", "name")

      execute_callback = fn %Action.RotateAbsolute.Goal{theta: val}, _fb_cb ->
        %Action.RotateAbsolute.Result{delta: 0.5 * val}
      end

      :ok =
        Rclex.start_action_server(
          execute_callback,
          action_type,
          "/rotate_absolute",
          "name"
        )

      Process.sleep(10)
      assert true == Rclex.action_server_available?(action_type, "/rotate_absolute", "name")

      assert capture_log(fn ->
               :ok = Rclex.stop_action_server(action_type, "/rotate_absolute", "name")
             end) =~ "ActionServer: :shutdown"

      assert capture_log(fn ->
               :ok = Rclex.stop_action_client(action_type, "/rotate_absolute", "name")
             end) =~ "ActionClient: :shutdown"
    end

    test "stop_action_client/3", %{action_type: action_type} do
      :ok =
        Rclex.start_action_client(
          action_type,
          "/rotate_absolute",
          "name"
        )

      assert capture_log(fn ->
               :ok = Rclex.stop_action_client(action_type, "/rotate_absolute", "name")
             end) =~ "ActionClient: :shutdown"

      assert {:error, :not_found} =
               Rclex.stop_action_client(action_type, "/rotate_absolute", "name")
    end

    test "stop_action_client/3, node doesn't exist", %{action_type: action_type} do
      assert {:noproc, _} =
               catch_exit(Rclex.stop_action_client(action_type, "/rotate_absolute", "notexists"))
    end
  end

  describe "setting action goals" do
    setup do
      me = self()

      execute_callback = fn %Action.RotateAbsolute.Goal{theta: val}, publish_feedback ->
        send(me, :started_execute_callback)
        # simulate some work
        for i <- 1..3 do
          Process.sleep(50)
          feedback = %Action.RotateAbsolute.Feedback{remaining: i * 0.1}
          send(me, :feedback)
          publish_feedback.(feedback)
        end

        send(me, :finished_execute_callback)
        %Action.RotateAbsolute.Result{delta: 0.5 * val}
      end

      goal_callback = fn _req ->
        send(me, :goal_callback)
        :accept
      end

      handle_accepted_callback = fn goal_info_struct, action_type, action_name, name, namespace ->
        Rclex.execute_goal(goal_info_struct, action_type, action_name, name, namespace: namespace)
      end

      cancel_callback = fn _goal_info ->
        :accept
      end

      action_type = Action.RotateAbsolute

      :ok = Rclex.start_node("name")

      status_topic_qos = %Rclex.QoS{
        history: :keep_last,
        depth: 1,
        reliability: :reliable,
        durability: :transient_local,
        deadline: 0.0,
        lifespan: 0.0,
        liveliness: :system_default,
        liveliness_lease_duration: 0.0,
        avoid_ros_namespace_conventions: false
      }

      :ok =
        Rclex.start_action_server(
          execute_callback,
          action_type,
          "/rotate_absolute",
          "name",
          goal_callback: goal_callback,
          handle_accepted_callback: handle_accepted_callback,
          cancel_callback: cancel_callback,
          status_topic_qos: status_topic_qos,
          result_timeout: 0.2
        )

      :ok =
        Rclex.start_action_client(
          action_type,
          "/rotate_absolute",
          "name"
        )

      on_exit(fn ->
        capture_log(fn ->
          Rclex.stop_action_client(action_type, "/rotate_absolute", "name")
          Rclex.stop_action_server(action_type, "/rotate_absolute", "name")
          Rclex.stop_node("name")
        end)
      end)

      %{
        action_type: action_type
      }
    end

    test "send_goal_async/3, execute_callback gets canceled", %{action_type: action_type} do
      me = self()
      result_callback = fn status, result -> send(me, {:got_result, status, result.delta}) end

      cancel_callback = fn return_code, goals_canceling ->
        send(me, {:canceled, return_code, goals_canceling})
      end

      capture_log(fn ->
        for _i <- 0..3 do
          assert {:ok, uuid} =
                   Rclex.send_goal_async(
                     %Action.RotateAbsolute.Goal{theta: 2.0},
                     "/rotate_absolute",
                     "name"
                   )

          assert :ok =
                   Rclex.get_result_async(
                     uuid,
                     result_callback,
                     action_type,
                     "/rotate_absolute",
                     "name"
                   )

          Process.sleep(60)

          assert :ok =
                   Rclex.cancel_goal_async(
                     uuid,
                     cancel_callback,
                     action_type,
                     "/rotate_absolute",
                     "name"
                   )

          assert_receive :goal_callback
          assert_receive :started_execute_callback
          assert_receive :feedback
          assert_receive {:canceled, 0, _}
          refute_receive :finished_execute_callback
          assert_receive {:got_result, 5, _}
        end
      end)
    end

    test "send_goal_async/3, execute_callback receives result", %{action_type: action_type} do
      me = self()
      result_callback = fn status, result -> send(me, {:got_result, status, result.delta}) end

      capture_log(fn ->
        for _i <- 0..3 do
          assert {:ok, uuid} =
                   Rclex.send_goal_async(
                     %Action.RotateAbsolute.Goal{theta: 2.0},
                     "/rotate_absolute",
                     "name"
                   )

          assert :ok =
                   Rclex.get_result_async(
                     uuid,
                     result_callback,
                     action_type,
                     "/rotate_absolute",
                     "name"
                   )

          assert_receive :goal_callback
          assert_receive :started_execute_callback
          assert_receive :feedback
          assert_receive :feedback
          assert_receive :feedback
          assert_receive :finished_execute_callback
          assert_receive {:got_result, 4, 1.0}
        end
      end)
    end
  end

  describe "raising action goal execution" do
    setup do
      me = self()

      raising_execute_callback = fn %Action.RotateAbsolute.Goal{theta: val}, _fb_cb ->
        send(me, :execute_callback)
        Process.sleep(50)
        raise("test raise")
        send(me, :finished_execute_callback)
        %Action.RotateAbsolute.Result{delta: 2.0 * val}
      end

      goal_callback = fn _req ->
        send(me, :goal_callback)
        :accept
      end

      handle_accepted_callback = fn goal_info_struct, action_type, action_name, name, namespace ->
        Rclex.execute_goal(goal_info_struct, action_type, action_name, name, namespace: namespace)
      end

      action_type = Action.RotateAbsolute

      :ok = Rclex.start_node("name")

      :ok =
        Rclex.start_action_server(
          raising_execute_callback,
          action_type,
          "/rotate_absolute",
          "name",
          goal_callback: goal_callback,
          handle_accepted_callback: handle_accepted_callback
        )

      :ok =
        Rclex.start_action_client(
          action_type,
          "/rotate_absolute",
          "name"
        )

      on_exit(fn ->
        capture_log(fn ->
          Rclex.stop_action_server(action_type, "/rotate_absolute", "name")
          Rclex.stop_action_client(action_type, "/rotate_absolute", "name")
          Rclex.stop_node("name")
        end)
      end)

      %{
        action_type: action_type
      }
    end

    test "send_goal_async/3, execute_callback raises", %{action_type: action_type} do
      me = self()
      result_callback = fn status, result -> send(me, {:got_result, status, result.delta}) end

      capture_log(fn ->
        assert {:ok, uuid} =
                 Rclex.send_goal_async(
                   %Action.RotateAbsolute.Goal{theta: 0.123},
                   "/rotate_absolute",
                   "name"
                 )

        assert :ok =
                 Rclex.get_result_async(
                   uuid,
                   result_callback,
                   action_type,
                   "/rotate_absolute",
                   "name"
                 )

        assert_receive :goal_callback
        assert_receive :execute_callback
        assert_receive {:got_result, 6, _}
        refute_receive :finished_execute_callback, 100
      end) =~ "execution failed because of {%RuntimeError{message: \"test raise\"}"
    end

    test "get_result_async/5 for unknown goal", %{action_type: action_type} do
      me = self()
      result_callback = fn status, result -> send(me, {:got_result, status, result.delta}) end

      capture_log(fn ->
        uuid = <<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16>>

        assert :ok =
                 Rclex.get_result_async(
                   uuid,
                   result_callback,
                   action_type,
                   "/rotate_absolute",
                   "name"
                 )

        assert_receive {:got_result, 0, _}
      end)
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
      action_name = "/rotate_absolute"
      action_type = Turtlesim.Action.RotateAbsolute

      :ok = Rclex.start_node("name")
      :ok = Rclex.start_publisher(StdMsgs.Msg.String, topic_name, name)
      :ok = Rclex.start_subscription(fn _msg -> nil end, StdMsgs.Msg.String, topic_name, name)

      service_callback = fn %RclInterfaces.Srv.GetParameterTypes.Request{names: names} ->
        %RclInterfaces.Srv.GetParameterTypes.Response{
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

      execute_callback = fn _goal, _feedback_callback ->
        %Turtlesim.Action.RotateAbsolute.Result{}
      end

      :ok = Rclex.start_action_server(execute_callback, action_type, action_name, name)
      :ok = Rclex.start_action_client(action_type, action_name, name)

      on_exit(fn -> capture_log(fn -> Rclex.stop_node("name") end) end)
      :timer.sleep(50)

      %{
        name: name,
        topic_name: topic_name,
        service_type: service_type,
        service_name: service_name,
        action_type: action_type,
        action_name: action_name
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

    test "action_get_names_and_types/1", %{} do
      assert [{"/rotate_absolute", ["turtlesim/action/RotateAbsolute"]}] =
               Rclex.action_get_names_and_types("name")
    end

    test "action_get_client_names_and_types_by_node/3", %{} do
      assert [{"/rotate_absolute", ["turtlesim/action/RotateAbsolute"]}] =
               Rclex.action_get_client_names_and_types_by_node("name", "name", "/")
    end

    test "action_get_server_names_and_types_by_node/3", %{} do
      assert [{"/rotate_absolute", ["turtlesim/action/RotateAbsolute"]}] =
               Rclex.action_get_server_names_and_types_by_node("name", "name", "/")
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
