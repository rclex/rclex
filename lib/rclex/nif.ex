defmodule Rclex.Nif do
  @moduledoc false

  @on_load :load
  @compile {:autoload, false}

  def load() do
    Application.app_dir(:rclex)
    |> Path.join("priv/rclex.so")
    |> String.replace_suffix(".so", "")
    |> to_charlist()
    |> :erlang.load_nif(_load_info = :any_term)
  end

  def test_raise!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def test_raise_with_message!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def test_qos_profile!(_qos) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_init!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_fini!(_context) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_node_init!(_context, _name, _namespace) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_node_get_graph_guard_condition!(_node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def node_start_waitset_thread!(_context, _guard_condition) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def node_stop_waitset_thread!(_thread_context) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_node_fini!(_node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_publisher_init!(_node, _type_support, _topic_name, _qos) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_publisher_fini!(_publisher, _node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_publish!(_publisher, _ros_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_subscription_init!(_node, _type_support, _topic_name, _qos) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_subscription_fini!(_subscription, _node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_subscription_set_on_new_message_callback!(_subscription) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_subscription_clear_message_callback!(_subscription, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_clock_init!(_opts) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_clock_fini!(_clock) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_clock_get_now!(_opts) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_clock_time_started!(_clock) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_clock_valid!(_clock) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_enable_ros_time_override!(_clock) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_disable_ros_time_override!(_clock) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_set_ros_time_override!(_clock, _time_value) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_timer_init!(_context, _clock, _period_ms) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_timer_fini!(_timer) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_timer_is_ready!(_timer) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_timer_call!(_timer) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_take!(_subscription, _message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_set_init_subscription!(_context) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_set_init_client!(_context) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_set_init_service!(_context) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_set_init_timer!(_context) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_set_fini!(_wait_set) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_subscription!(_wait_set, _timeout_us, _subscription) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_client!(_wait_set, _timeout_us, _client) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_service!(_wait_set, _timeout_us, _service) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_wait_timer!(_wait_set, _timeout_us, _timer) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_service_init!(_node, _type_support, _service_name, _qos) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_service_fini!(_service, _node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_service_set_on_new_request_callback!(_service) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_service_clear_request_callback!(_service, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_take_request_with_info!(_service, _ros_request_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_send_response!(_service, _response_header, _ros_response_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_client_init!(_node, _type_support, _service_name, _qos) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_client_fini!(_client, _node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_client_set_on_new_response_callback!(_client) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_client_clear_response_callback!(_client, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_send_request!(_client, _ros_request_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_take_response_with_info!(_client, _ros_respone_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_init!(
        _node,
        _type_support,
        _action_name,
        {_goal_service_qos, _result_service_qos, _cancel_service_qos, _feedback_topic_qos,
         _status_topic_qos}
      ) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_fini!(_action_client, _node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_set_cancel_client_callback!(_action_client) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_set_feedback_subscription_callback!(_action_client) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_set_goal_client_callback!(_action_client) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_set_result_client_callback!(_action_client) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_set_status_subscription_callback!(_action_client) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_clear_cancel_client_callback!(_action_client, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_clear_feedback_subscription_callback!(_action_client, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_clear_goal_client_callback!(_action_client, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_clear_result_client_callback!(_action_client, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_client_clear_status_subscription_callback!(_action_client, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_send_cancel_request!(_action_client, _cancel_request_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_send_goal_request!(_action_client, _goal_request_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_send_result_request!(_action_client, _result_request_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_take_cancel_response!(_action_client, _cancel_response_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_take_feedback!(_action_client, _feedback_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_take_goal_response!(_action_client, _goal_response_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_take_result_response!(_action_client, _result_response_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_take_status!(_action_client, _status_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_is_available!(_node, _action_client) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_init!(
        _node,
        _type_support,
        _action_name,
        _clock,
        {_goal_service_qos, _result_service_qos, _cancel_service_qos, _feedback_topic_qos,
         _status_topic_qos},
        _result_timeout
      ) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_fini!(_action_server, _node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_accept_new_goal!(_action_server, _goal_info_msg) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_expire_goals!(_action_server, _capacity \\ 100) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_notify_goal_done!(_action_server) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_publish_feedback!(_action_server, _feedback_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_publish_status!(_action_server, _status_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_send_cancel_response!(_action_server, _request_id, _response_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_send_goal_response!(_action_server, _request_id, _response_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_send_result_response!(_action_server, _request_id, _response_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_get_goal_handles!(_action_server) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_goal_exists!(_action_server, _goal_info_msg) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_set_cancel_service_callback!(_action_server) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_set_goal_service_callback!(_action_server) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_set_result_service_callback!(_action_server) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_clear_cancel_service_callback!(_action_server, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_clear_goal_service_callback!(_action_server, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_server_clear_result_service_callback!(_action_server, _callback_resource) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_take_cancel_request!(_action_server, _request_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_take_goal_request!(_action_server, _request_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_take_result_request!(_action_server, _request_message) do
    :erlang.nif_error(:nif_not_loaded)
  end

  # def rcl_action_goal_handle_fini!(_goal_handle) do
  #  :erlang.nif_error(:nif_not_loaded)
  # end

  def rcl_action_goal_handle_get_status!(_goal_handle) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_update_goal_state!(_goal_handle, _status) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_goal_handle_is_active!(_goal_handle) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_goal_handle_is_cancelable!(_goal_handle) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_goal_handle_is_valid!(_goal_handle) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_process_cancel_request!(
        _action_server,
        _cancel_request_msg,
        _cancel_response_msg
      ) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_count_publishers!(_node, _topic_name) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_count_subscribers!(_node, _topic_name) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_get_client_names_and_types_by_node!(_node, _node_name, _namespace) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_get_node_names!(_node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_get_node_names_with_enclaves!(_node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_get_publisher_names_and_types_by_node!(_node, _node_name, _namespace, _no_demangle) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_get_publishers_info_by_topic!(_node, _topic_name, _no_mangle) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_get_service_names_and_types!(_node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_get_service_names_and_types_by_node!(_node, _node_name, _namespace) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_get_subscriber_names_and_types_by_node!(_node, _node_name, _namespace, _no_demangle) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_get_subscribers_info_by_topic!(_node, _topic_name, _no_mangle) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_get_topic_names_and_types!(_node, _no_demangle) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_service_server_is_available!(_node, _client) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_get_client_names_and_types_by_node!(_node, _node_name, _namespace) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_get_server_names_and_types_by_node!(_node, _node_name, _namespace) do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_get_names_and_types!(_node) do
    :erlang.nif_error(:nif_not_loaded)
  end

  #  def rcl_wait_for_publishers!(_node, _topic_name, _count, _timeout) do
  #    :erlang.nif_error(:nif_not_loaded)
  #  end

  #  def rcl_wait_for_subscribers!(_node, _topic_name, _count, _timeout) do
  #    :erlang.nif_error(:nif_not_loaded)
  #  end

  def rmw_qos_profile_sensor_data!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_parameters!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_default!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_services_default!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_parameter_events!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rmw_qos_profile_system_default!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  def rcl_action_qos_profile_status_default!() do
    :erlang.nif_error(:nif_not_loaded)
  end

  @before_compile Rclex.MsgFuncs
  @before_compile Rclex.SrvFuncs
  @before_compile Rclex.ActionFuncs
end
