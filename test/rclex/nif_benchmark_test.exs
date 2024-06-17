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

      request_struct = %Rclex.Pkgs.StdSrvs.Srv.SetBoolRequest{data: true}
      request_message = Rclex.Pkgs.StdSrvs.Srv.SetBoolRequest.create!()
      :ok = Rclex.Pkgs.StdSrvs.Srv.SetBoolRequest.set!(request_message, request_struct)

      response_struct = %Rclex.Pkgs.StdSrvs.Srv.SetBoolResponse{success: true}
      response_message = Rclex.Pkgs.StdSrvs.Srv.SetBoolResponse.create!()
      :ok = Rclex.Pkgs.StdSrvs.Srv.SetBoolResponse.set!(response_message, response_struct)

      on_exit(fn ->
        :ok = Rclex.Pkgs.StdSrvs.Srv.SetBoolRequest.destroy!(request_message)
        :ok = Rclex.Pkgs.StdSrvs.Srv.SetBoolResponse.destroy!(response_message)
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
end
