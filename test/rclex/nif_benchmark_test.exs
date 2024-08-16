defmodule Rclex.NifBenchmarkTest do
  use ExUnit.Case

  require Logger

  import ExUnit.CaptureLog

  alias Rclex.Nif
  alias Rclex.QoS

  @moduletag :skip
  @nif_limit_time_us 1000
  @nif_tenth_limit_time_us 100

  setup_all do
    capture_log(fn -> Application.stop(:rclex) end)
    :ok
  end

  describe "context" do
    test "rcl_init!/0" do
      {time_us, context} = :timer.tc(&Nif.rcl_init!/0, [])
      :ok = Nif.rcl_fini!(context)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_fini!/1" do
      context = Nif.rcl_init!()
      {time_us, :ok} = :timer.tc(&Nif.rcl_fini!/1, [context])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "node" do
    setup do
      context = Nif.rcl_init!()
      on_exit(fn -> :ok = Nif.rcl_fini!(context) end)
      %{context: context}
    end

    test "rcl_node_init!/3", %{context: context} do
      {time_us, node} = :timer.tc(&Nif.rcl_node_init!/3, [context, ~c"name", ~c"/namespace"])
      :ok = Nif.rcl_node_fini!(node)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_node_fini!/1", %{context: context} do
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      {time_us, :ok} = :timer.tc(&Nif.rcl_node_fini!/1, [node])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "publisher" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.std_msgs_msg_string_type_support!()
      qos = QoS.profile_default()

      on_exit(fn ->
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{node: node, type_support: type_support, qos: qos}
    end

    test "rcl_publisher_init!/4", %{node: node, type_support: type_support, qos: qos} do
      {time_us, publisher} =
        :timer.tc(&Nif.rcl_publisher_init!/4, [node, type_support, ~c"/topic", qos])

      :ok = Nif.rcl_publisher_fini!(publisher, node)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_publisher_fini!/2", %{node: node, type_support: type_support, qos: qos} do
      publisher = Nif.rcl_publisher_init!(node, type_support, ~c"/topic", qos)
      {time_us, :ok} = :timer.tc(&Nif.rcl_publisher_fini!/2, [publisher, node])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "subscription" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.std_msgs_msg_string_type_support!()
      qos = QoS.profile_default()

      on_exit(fn ->
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{node: node, type_support: type_support, qos: qos}
    end

    test "rcl_subscription_init!/4", %{node: node, type_support: type_support, qos: qos} do
      {time_us, subscription} =
        :timer.tc(&Nif.rcl_subscription_init!/4, [node, type_support, ~c"/topic", qos])

      :ok = Nif.rcl_subscription_fini!(subscription, node)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_subscription_fini!/2", %{node: node, type_support: type_support, qos: qos} do
      subscription = Nif.rcl_subscription_init!(node, type_support, ~c"/topic", qos)
      {time_us, :ok} = :timer.tc(&Nif.rcl_subscription_fini!/2, [subscription, node])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "service" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.std_srvs_srv_set_bool_type_support!()
      qos = QoS.profile_services_default()

      on_exit(fn ->
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{node: node, type_support: type_support, qos: qos}
    end

    test "rcl_service_init!/4", %{node: node, type_support: type_support, qos: qos} do
      {time_us, service} =
        :timer.tc(&Nif.rcl_service_init!/4, [node, type_support, ~c"/set_test_bool", qos])

      :ok = Nif.rcl_service_fini!(service, node)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_service_fini!/2", %{node: node, type_support: type_support, qos: qos} do
      service = Nif.rcl_service_init!(node, type_support, ~c"/set_test_bool", qos)
      {time_us, :ok} = :timer.tc(&Nif.rcl_service_fini!/2, [service, node])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "client" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.std_srvs_srv_set_bool_type_support!()
      qos = QoS.profile_services_default()

      on_exit(fn ->
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{node: node, type_support: type_support, qos: qos}
    end

    test "rcl_client_init!/4", %{node: node, type_support: type_support, qos: qos} do
      {time_us, client} =
        :timer.tc(&Nif.rcl_client_init!/4, [node, type_support, ~c"/set_test_bool", qos])

      :ok = Nif.rcl_client_fini!(client, node)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_client_fini!/2", %{node: node, type_support: type_support, qos: qos} do
      client = Nif.rcl_client_init!(node, type_support, ~c"/set_test_bool", qos)
      {time_us, :ok} = :timer.tc(&Nif.rcl_client_fini!/2, [client, node])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "service calls" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.std_srvs_srv_set_bool_type_support!()
      qos = QoS.profile_services_default()

      service = Nif.rcl_service_init!(node, type_support, ~c"/set_test_bool", qos)
      client = Nif.rcl_client_init!(node, type_support, ~c"/set_test_bool", qos)

      request_struct = %Rclex.Pkgs.StdSrvs.Srv.SetBool.Request{data: true}
      request_message = Rclex.Pkgs.StdSrvs.Srv.SetBool.Request.create!()
      :ok = Rclex.Pkgs.StdSrvs.Srv.SetBool.Request.set!(request_message, request_struct)

      response_struct = %Rclex.Pkgs.StdSrvs.Srv.SetBool.Response{success: true}
      response_message = Rclex.Pkgs.StdSrvs.Srv.SetBool.Response.create!()
      :ok = Rclex.Pkgs.StdSrvs.Srv.SetBool.Response.set!(response_message, response_struct)

      on_exit(fn ->
        :ok = Rclex.Pkgs.StdSrvs.Srv.SetBool.Request.destroy!(request_message)
        :ok = Rclex.Pkgs.StdSrvs.Srv.SetBool.Response.destroy!(response_message)
        :ok = Nif.rcl_client_fini!(client, node)
        :ok = Nif.rcl_service_fini!(service, node)
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{
        node: node,
        type_support: type_support,
        response_message: response_message,
        request_message: request_message,
        client: client,
        service: service,
        qos: qos
      }
    end

    test "rcl_send_request!/2", %{client: client, request_message: request_message} do
      {time_us, {:ok, _sequence_number}} =
        :timer.tc(&Nif.rcl_send_request!/2, [client, request_message])

      assert time_us <= @nif_tenth_limit_time_us
    end

    test "rcl_take_response_with_info!/2", %{
      client: client,
      service: service,
      request_message: request_message,
      response_message: response_message
    } do
      {:ok, request_sequence_number} = Nif.rcl_send_request!(client, request_message)
      {:ok, request_header} = Nif.rcl_take_request_with_info!(service, request_message)
      Nif.rcl_send_response!(service, request_header, response_message)

      {time_us, {:ok, response_sequence_number}} =
        :timer.tc(&Nif.rcl_take_response_with_info!/2, [client, response_message])

      assert request_sequence_number == response_sequence_number
      assert time_us <= @nif_tenth_limit_time_us
    end

    test "rcl_take_request_with_info!/2", %{
      client: client,
      service: service,
      request_message: request_message,
      response_message: response_message
    } do
      {:ok, request_sequence_number} = Nif.rcl_send_request!(client, request_message)

      {time_us, {:ok, request_header}} =
        :timer.tc(&Nif.rcl_take_request_with_info!/2, [service, request_message])

      Nif.rcl_send_response!(service, request_header, response_message)
      {:ok, response_sequence_number} = Nif.rcl_take_response_with_info!(client, response_message)
      assert request_sequence_number == response_sequence_number
      assert time_us <= @nif_tenth_limit_time_us
    end

    test "rcl_send_response!/3", %{
      client: client,
      service: service,
      request_message: request_message,
      response_message: response_message
    } do
      {:ok, request_sequence_number} = Nif.rcl_send_request!(client, request_message)
      {:ok, request_header} = Nif.rcl_take_request_with_info!(service, request_message)

      {time_us, :ok} =
        :timer.tc(&Nif.rcl_send_response!/3, [service, request_header, response_message])

      {:ok, response_sequence_number} = Nif.rcl_take_response_with_info!(client, response_message)
      assert request_sequence_number == response_sequence_number
      assert time_us <= @nif_tenth_limit_time_us
    end
  end

  describe "action_server & action_client" do
    setup do
      context = Nif.rcl_init!()
      name = ~c"name"
      namespace = ~c"/namespace"
      action_name = ~c"/rotate_absolute"
      node = Nif.rcl_node_init!(context, name, namespace)
      clock_type = :system_time
      clock = Nif.rcl_clock_init!(clock_type)
      type_support = Nif.turtlesim_action_rotate_absolute_type_support!()
      goal_service_qos = Rclex.QoS.profile_services_default()
      result_service_qos = Rclex.QoS.profile_services_default()
      cancel_service_qos = Rclex.QoS.profile_services_default()
      feedback_topic_qos = Rclex.QoS.profile_default()
      status_topic_qos = Rclex.QoS.profile_status_default()
      result_timeout = 10.0

      action_server =
        Nif.rcl_action_server_init!(
          node,
          type_support,
          ~c"#{action_name}",
          clock,
          {goal_service_qos, result_service_qos, cancel_service_qos, feedback_topic_qos,
           status_topic_qos},
          result_timeout
        )

      action_client =
        Nif.rcl_action_client_init!(
          node,
          type_support,
          ~c"#{action_name}",
          {goal_service_qos, result_service_qos, cancel_service_qos, feedback_topic_qos,
           status_topic_qos}
        )

      :timer.sleep(50)

      on_exit(fn ->
        :ok = Nif.rcl_action_client_fini!(action_client, node)
        :ok = Nif.rcl_action_server_fini!(action_server, node)
        :ok = Nif.rcl_clock_fini!(clock)
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{
        node: node,
        action_client: action_client,
        action_server: action_server,
        name: name,
        namespace: namespace,
        action_name: action_name
      }
    end

    test "rcl_action_server_is_available!/2", %{node: node, action_client: action_client} do
      {time_us, true} = :timer.tc(&Nif.rcl_action_server_is_available!/2, [node, action_client])
      assert time_us <= @nif_tenth_limit_time_us
    end

    test "rcl_action_accept_new_goal!/2", %{action_server: action_server} do
      uuid = <<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16>>
      sec = 123_456
      nanosec = 789

      goal_info_message = Nif.action_msgs_msg_goal_info_create!()
      Nif.action_msgs_msg_goal_info_set!(goal_info_message, {{uuid}, {sec, nanosec}})

      {time_us, {:ok, _seq}} =
        :timer.tc(&Nif.rcl_action_accept_new_goal!/2, [action_server, goal_info_message])

      assert time_us <= @nif_tenth_limit_time_us

      Nif.action_msgs_msg_goal_info_destroy!(goal_info_message)
    end

    test "rcl_action_notify_goal_done!/1", %{action_server: action_server} do
      {time_us, :ok} = :timer.tc(&Nif.rcl_action_notify_goal_done!/1, [action_server])
      assert time_us <= @nif_tenth_limit_time_us
    end

    test "rcl_action_publish_feedback!/2 and rcl_action_take_feedback!/2", %{
      action_server: action_server,
      action_client: action_client
    } do
      uuid = <<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16>>

      feedback_message = Nif.turtlesim_action_rotate_absolute__feedback_message_create!()

      Nif.turtlesim_action_rotate_absolute__feedback_message_set!(
        feedback_message,
        {{uuid}, {1.234}}
      )

      {time_us, :ok} =
        :timer.tc(&Nif.rcl_action_publish_feedback!/2, [action_server, feedback_message])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, :ok} =
        :timer.tc(&Nif.rcl_action_take_feedback!/2, [action_client, feedback_message])

      assert time_us <= @nif_tenth_limit_time_us

      Nif.turtlesim_action_rotate_absolute__feedback_message_destroy!(feedback_message)
    end

    test "rcl_action_publish_status!/2 and rcl_action_take_status!/2", %{
      action_server: action_server,
      action_client: action_client
    } do
      status_message = Nif.action_msgs_msg_goal_status_array_create!()
      Nif.action_msgs_msg_goal_status_array_set!(status_message, {[]})

      {time_us, :ok} =
        :timer.tc(&Nif.rcl_action_publish_status!/2, [action_server, status_message])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, :ok} =
        :timer.tc(&Nif.rcl_action_take_status!/2, [action_client, status_message])

      assert time_us <= @nif_tenth_limit_time_us

      Nif.action_msgs_msg_goal_status_array_destroy!(status_message)
    end

    test "rcl_action_send/take_cancel_request! & rcl_action_send/take_cancel_response!", %{
      action_server: action_server,
      action_client: action_client
    } do
      uuid = <<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16>>
      sec = 123_456
      nanosec = 789

      cancel_request_message = Nif.action_msgs_srv_cancel_goal__request_create!()
      cancel_response_message = Nif.action_msgs_srv_cancel_goal__response_create!()

      Nif.action_msgs_srv_cancel_goal__request_set!(
        cancel_request_message,
        {{{uuid}, {sec, nanosec}}}
      )

      Nif.action_msgs_srv_cancel_goal__response_set!(cancel_response_message, {0, []})

      {time_us, {:ok, request_id_send}} =
        :timer.tc(&Nif.rcl_action_send_cancel_request!/2, [action_client, cancel_request_message])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, {:ok, req_ref}} =
        :timer.tc(&Nif.rcl_action_take_cancel_request!/2, [action_server, cancel_request_message])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, :ok} =
        :timer.tc(&Nif.rcl_action_send_cancel_response!/3, [
          action_server,
          req_ref,
          cancel_response_message
        ])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, {:ok, request_id_recv}} =
        :timer.tc(&Nif.rcl_action_take_cancel_response!/2, [
          action_client,
          cancel_response_message
        ])

      assert time_us <= @nif_tenth_limit_time_us

      assert request_id_send == request_id_recv

      Nif.action_msgs_srv_cancel_goal__request_destroy!(cancel_request_message)
      Nif.action_msgs_srv_cancel_goal__response_destroy!(cancel_response_message)
    end

    test "rcl_action_send/take_goal_request! & rcl_action_send/take_goal_response!", %{
      action_server: action_server,
      action_client: action_client
    } do
      uuid = <<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16>>
      sec = 123_456
      nanosec = 789

      request_message = Nif.turtlesim_action_rotate_absolute__send_goal__request_create!()
      response_message = Nif.turtlesim_action_rotate_absolute__send_goal__response_create!()

      Nif.turtlesim_action_rotate_absolute__send_goal__request_set!(
        request_message,
        {{uuid}, {1.234}}
      )

      Nif.turtlesim_action_rotate_absolute__send_goal__response_set!(
        response_message,
        {false, {sec, nanosec}}
      )

      {time_us, {:ok, request_id_send}} =
        :timer.tc(&Nif.rcl_action_send_goal_request!/2, [action_client, request_message])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, {:ok, req_ref}} =
        :timer.tc(&Nif.rcl_action_take_goal_request!/2, [action_server, request_message])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, :ok} =
        :timer.tc(&Nif.rcl_action_send_goal_response!/3, [
          action_server,
          req_ref,
          response_message
        ])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, {:ok, request_id_recv}} =
        :timer.tc(&Nif.rcl_action_take_goal_response!/2, [action_client, response_message])

      assert time_us <= @nif_tenth_limit_time_us

      assert request_id_send == request_id_recv

      Nif.turtlesim_action_rotate_absolute__send_goal__request_destroy!(request_message)
      Nif.turtlesim_action_rotate_absolute__send_goal__response_destroy!(response_message)
    end

    test "rcl_action_send/take_result_request! & rcl_action_send/take_result_response!", %{
      action_server: action_server,
      action_client: action_client
    } do
      uuid = <<1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16>>

      request_message = Nif.turtlesim_action_rotate_absolute__get_result__request_create!()
      response_message = Nif.turtlesim_action_rotate_absolute__get_result__response_create!()

      Nif.turtlesim_action_rotate_absolute__get_result__request_set!(request_message, {{uuid}})

      Nif.turtlesim_action_rotate_absolute__get_result__response_set!(
        response_message,
        {0, {1.234}}
      )

      {time_us, {:ok, request_id_send}} =
        :timer.tc(&Nif.rcl_action_send_result_request!/2, [action_client, request_message])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, {:ok, req_ref}} =
        :timer.tc(&Nif.rcl_action_take_result_request!/2, [action_server, request_message])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, :ok} =
        :timer.tc(&Nif.rcl_action_send_result_response!/3, [
          action_server,
          req_ref,
          response_message
        ])

      assert time_us <= @nif_tenth_limit_time_us

      {time_us, {:ok, request_id_recv}} =
        :timer.tc(&Nif.rcl_action_take_result_response!/2, [action_client, response_message])

      assert time_us <= @nif_tenth_limit_time_us

      assert request_id_send == request_id_recv

      Nif.turtlesim_action_rotate_absolute__get_result__request_destroy!(request_message)
      Nif.turtlesim_action_rotate_absolute__get_result__response_destroy!(response_message)
    end
  end

  describe "wait_set" do
    setup do
      context = Nif.rcl_init!()
      node = Nif.rcl_node_init!(context, ~c"name", ~c"/namespace")
      type_support = Nif.std_msgs_msg_string_type_support!()

      subscription =
        Nif.rcl_subscription_init!(node, type_support, ~c"/topic", QoS.profile_default())

      on_exit(fn ->
        :ok = Nif.rcl_subscription_fini!(subscription, node)
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{context: context, subscription: subscription}
    end

    test "rcl_wait_set_init_subscription!/1", %{context: context} do
      {time_us, wait_set} = :timer.tc(&Nif.rcl_wait_set_init_subscription!/1, [context])
      :ok = Nif.rcl_wait_set_fini!(wait_set)
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_wait_set_fini!/1", %{context: context} do
      wait_set = Nif.rcl_wait_set_init_subscription!(context)
      {time_us, :ok} = :timer.tc(&Nif.rcl_wait_set_fini!/1, [wait_set])
      assert time_us <= @nif_limit_time_us
    end
  end

  describe "graph" do
    setup do
      context = Nif.rcl_init!()
      name = ~c"name"
      namespace = ~c"/namespace"
      topic_name = ~c"/topic"
      service_name = ~c"/set_test_bool"
      node = Nif.rcl_node_init!(context, name, namespace)
      msg_type_support = Nif.std_msgs_msg_string_type_support!()
      srv_type_support = Nif.std_srvs_srv_set_bool_type_support!()

      subscription =
        Nif.rcl_subscription_init!(node, msg_type_support, topic_name, QoS.profile_default())

      publisher =
        Nif.rcl_publisher_init!(node, msg_type_support, topic_name, QoS.profile_default())

      service =
        Nif.rcl_service_init!(
          node,
          srv_type_support,
          service_name,
          QoS.profile_services_default()
        )

      client =
        Nif.rcl_client_init!(node, srv_type_support, service_name, QoS.profile_services_default())

      :timer.sleep(50)

      on_exit(fn ->
        :ok = Nif.rcl_client_fini!(client, node)
        :ok = Nif.rcl_service_fini!(service, node)
        :ok = Nif.rcl_publisher_fini!(publisher, node)
        :ok = Nif.rcl_subscription_fini!(subscription, node)
        :ok = Nif.rcl_node_fini!(node)
        :ok = Nif.rcl_fini!(context)
      end)

      %{node: node, client: client, name: name, namespace: namespace, topic_name: topic_name}
    end

    test "rcl_count_publishers!/2", %{node: node, topic_name: topic_name} do
      {time_us, 1} = :timer.tc(&Nif.rcl_count_publishers!/2, [node, topic_name])
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_count_subscribers!/2", %{node: node, topic_name: topic_name} do
      {time_us, 1} = :timer.tc(&Nif.rcl_count_subscribers!/2, [node, topic_name])
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_get_client_names_and_types_by_node!/3", %{
      node: node,
      name: name,
      namespace: namespace
    } do
      {time_us, [{~c"/set_test_bool", [~c"std_srvs/srv/SetBool"]}]} =
        :timer.tc(&Nif.rcl_get_client_names_and_types_by_node!/3, [node, name, namespace])

      assert time_us <= @nif_limit_time_us
    end

    test "rcl_get_node_names!/1", %{node: node, name: name, namespace: namespace} do
      {time_us, [{^name, ^namespace}]} = :timer.tc(&Nif.rcl_get_node_names!/1, [node])
      assert time_us <= @nif_limit_time_us
    end

    test "rcl_get_node_names_with_enclaves!/1", %{node: node, name: name, namespace: namespace} do
      {time_us, [{^name, ^namespace, ~c"/"}]} =
        :timer.tc(&Nif.rcl_get_node_names_with_enclaves!/1, [node])

      assert time_us <= @nif_limit_time_us
    end

    test "rcl_get_publisher_names_and_types_by_node!/4", %{
      node: node,
      name: name,
      namespace: namespace,
      topic_name: topic_name
    } do
      {time_us, [{^topic_name, [~c"std_msgs/msg/String"]}]} =
        :timer.tc(&Nif.rcl_get_publisher_names_and_types_by_node!/4, [
          node,
          name,
          namespace,
          false
        ])

      assert time_us <= @nif_limit_time_us
    end

    test "rcl_get_publishers_info_by_topic!/3", %{
      node: node,
      topic_name: topic_name
    } do
      {time_us, [_info]} =
        :timer.tc(&Nif.rcl_get_publishers_info_by_topic!/3, [node, topic_name, false])

      assert time_us <= @nif_limit_time_us
    end

    test "rcl_get_service_names_and_types!/1", %{node: node} do
      {time_us, [{~c"/set_test_bool", [~c"std_srvs/srv/SetBool"]}]} =
        :timer.tc(&Nif.rcl_get_service_names_and_types!/1, [node])

      assert time_us <= @nif_limit_time_us
    end

    test "rcl_get_service_names_and_types_by_node!/3", %{
      node: node,
      name: name,
      namespace: namespace
    } do
      {time_us, [{~c"/set_test_bool", [~c"std_srvs/srv/SetBool"]}]} =
        :timer.tc(&Nif.rcl_get_service_names_and_types_by_node!/3, [node, name, namespace])

      assert time_us <= @nif_limit_time_us
    end

    test "rcl_get_subscriber_names_and_types_by_node!/4", %{
      node: node,
      name: name,
      namespace: namespace,
      topic_name: topic_name
    } do
      {time_us, [{^topic_name, [~c"std_msgs/msg/String"]}]} =
        :timer.tc(&Nif.rcl_get_subscriber_names_and_types_by_node!/4, [
          node,
          name,
          namespace,
          false
        ])

      assert time_us <= @nif_limit_time_us
    end

    test "rcl_get_subscribers_info_by_topic!/3", %{
      node: node,
      topic_name: topic_name
    } do
      {time_us, [_info]} =
        :timer.tc(&Nif.rcl_get_subscribers_info_by_topic!/3, [node, topic_name, false])

      assert time_us <= @nif_limit_time_us
    end

    test "rcl_get_topic_names_and_types!/2", %{topic_name: topic_name, node: node} do
      {time_us, [{^topic_name, [~c"std_msgs/msg/String"]}]} =
        :timer.tc(&Nif.rcl_get_topic_names_and_types!/2, [node, false])

      assert time_us <= @nif_limit_time_us
    end

    test "rcl_service_server_is_available!/2", %{node: node, client: client} do
      {time_us, true} = :timer.tc(&Nif.rcl_service_server_is_available!/2, [node, client])

      assert time_us <= @nif_limit_time_us
    end
  end

  describe "pkgs" do
    test "set binary" do
      random_length = 1_000_000
      bin_in = :crypto.strong_rand_bytes(random_length)
      msg = Nif.rcl_interfaces_srv_get_parameter_types__response_create!()

      {time_us, :ok} =
        :timer.tc(&Nif.rcl_interfaces_srv_get_parameter_types__response_set!/2, [msg, {bin_in}])

      assert time_us <= @nif_limit_time_us

      {time_us, {bin_out}} =
        :timer.tc(&Nif.rcl_interfaces_srv_get_parameter_types__response_get!/1, [msg])

      assert time_us <= @nif_limit_time_us
      Nif.rcl_interfaces_srv_get_parameter_types__response_destroy!(msg)
      assert bin_in == bin_out
    end
  end
end
