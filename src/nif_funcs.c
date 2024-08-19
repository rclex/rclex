#include "action_funcs.h" // IWYU pragma: keep
#include "macros.h"
#include "msg_funcs.h" // IWYU pragma: keep
#include "qos.h"
#include "rcl_action_client.h"
#include "rcl_action_server.h"
#include "rcl_client.h"
#include "rcl_clock.h"
#include "rcl_graph.h"
#include "rcl_init.h"
#include "rcl_node.h"
#include "rcl_publisher.h"
#include "rcl_service.h"
#include "rcl_subscription.h"
#include "rcl_timer.h"
#include "rcl_wait.h"
#include "resource_types.h"
#include "srv_funcs.h" // IWYU pragma: keep
#include "terms.h"
#include <erl_nif.h>
#include <stddef.h>

#define REGULAR_NIF 0
/*
 if not regular nif, use ERL_NIF_DIRTY_JOB_CPU_BOUND or
 ERL_NIF_DIRTY_JOB_IO_BOUND ref.
 https://www.erlang.org/doc/man/erl_nif.html#ErlNifFunc
*/
#define nif_io_bound_func(name, arity)                                                             \
  { #name "!", arity, nif_##name, ERL_NIF_DIRTY_JOB_IO_BOUND }

#define nif_regular_func(name, arity)                                                              \
  { #name "!", arity, nif_##name, REGULAR_NIF }

static ErlNifFunc nif_funcs[] = {
    // clang-format off
    nif_regular_func(test_raise, 0),
    nif_regular_func(test_raise_with_message, 0),
    nif_regular_func(test_qos_profile, 1),
    nif_io_bound_func(rcl_init, 0),
    nif_io_bound_func(rcl_fini, 1),
    nif_io_bound_func(rcl_node_init, 3),
    nif_regular_func(rcl_node_get_graph_guard_condition, 1),
    nif_regular_func(node_start_waitset_thread, 2),
    nif_regular_func(node_stop_waitset_thread, 1),
    nif_io_bound_func(rcl_node_fini, 1),
    nif_io_bound_func(rcl_publisher_init, 4),
    nif_io_bound_func(rcl_publisher_fini, 2),
    nif_regular_func(rcl_publish, 2),
    nif_io_bound_func(rcl_subscription_init, 4),
    nif_io_bound_func(rcl_subscription_fini, 2),
#ifndef ROS_DISTRO_foxy
    nif_regular_func(rcl_subscription_set_on_new_message_callback, 1),
    nif_regular_func(rcl_subscription_clear_message_callback, 2),
#endif
    nif_regular_func(rcl_take, 2),
    nif_io_bound_func(rcl_clock_init, 1),
    nif_io_bound_func(rcl_clock_fini, 1),
    nif_regular_func(rcl_clock_get_now, 1),
    nif_regular_func(rcl_clock_time_started, 1),
    nif_regular_func(rcl_clock_valid, 1),
    nif_regular_func(rcl_enable_ros_time_override, 1),
    nif_regular_func(rcl_disable_ros_time_override, 1),
    nif_regular_func(rcl_set_ros_time_override, 2),
    nif_io_bound_func(rcl_timer_init, 3),
    nif_io_bound_func(rcl_timer_fini, 1),
    nif_io_bound_func(rcl_timer_is_ready, 1),
    nif_io_bound_func(rcl_timer_call, 1),
    nif_io_bound_func(rcl_wait_set_init_subscription, 1),
    nif_io_bound_func(rcl_wait_set_init_client, 1),
    nif_io_bound_func(rcl_wait_set_init_service, 1),
    nif_io_bound_func(rcl_wait_set_init_timer, 1),
    nif_io_bound_func(rcl_wait_set_fini, 1),
    nif_io_bound_func(rcl_wait_subscription, 3),
    nif_io_bound_func(rcl_wait_client, 3),
    nif_io_bound_func(rcl_wait_service, 3),
    nif_io_bound_func(rcl_wait_timer, 3),
    nif_io_bound_func(rcl_service_init, 4),
    nif_io_bound_func(rcl_service_fini, 2),
#ifndef ROS_DISTRO_foxy
    nif_regular_func(rcl_service_set_on_new_request_callback, 1),
    nif_regular_func(rcl_service_clear_request_callback, 2),
#endif
    nif_regular_func(rcl_take_request_with_info, 2),
    nif_regular_func(rcl_send_response, 3),
    nif_io_bound_func(rcl_client_init, 4),
    nif_io_bound_func(rcl_client_fini, 2),
    nif_regular_func(rcl_send_request, 2),
    nif_regular_func(rcl_take_response_with_info, 2),
#ifndef ROS_DISTRO_foxy
    nif_regular_func(rcl_client_set_on_new_response_callback, 1),
    nif_regular_func(rcl_client_clear_response_callback, 2),
#endif
    nif_io_bound_func(rcl_action_client_init, 4),
    nif_io_bound_func(rcl_action_client_fini, 2),
#ifndef ROS_DISTRO_foxy
    nif_regular_func(rcl_action_client_set_cancel_client_callback, 1),
    nif_regular_func(rcl_action_client_set_feedback_subscription_callback, 1),
    nif_regular_func(rcl_action_client_set_goal_client_callback, 1),
    nif_regular_func(rcl_action_client_set_result_client_callback, 1),
    nif_regular_func(rcl_action_client_set_status_subscription_callback, 1),
    nif_regular_func(rcl_action_client_clear_cancel_client_callback, 2),
    nif_regular_func(rcl_action_client_clear_feedback_subscription_callback, 2),
    nif_regular_func(rcl_action_client_clear_goal_client_callback, 2),
    nif_regular_func(rcl_action_client_clear_result_client_callback, 2),
    nif_regular_func(rcl_action_client_clear_status_subscription_callback, 2),
#endif
    nif_regular_func(rcl_action_send_cancel_request, 2),
    nif_regular_func(rcl_action_send_goal_request, 2),
    nif_regular_func(rcl_action_send_result_request, 2),                                          
    nif_regular_func(rcl_action_take_cancel_response, 2),
    nif_regular_func(rcl_action_take_feedback, 2),
    nif_regular_func(rcl_action_take_goal_response, 2),
    nif_regular_func(rcl_action_take_result_response, 2),
    nif_regular_func(rcl_action_take_status, 2),
    nif_regular_func(rcl_action_server_is_available, 2),

    nif_regular_func(rcl_count_publishers, 2),
    nif_regular_func(rcl_count_subscribers, 2),
    nif_regular_func(rcl_get_client_names_and_types_by_node, 3),
    nif_regular_func(rcl_get_node_names, 1),
    nif_regular_func(rcl_get_node_names_with_enclaves, 1),
    nif_regular_func(rcl_get_publisher_names_and_types_by_node, 4),
    nif_regular_func(rcl_get_publishers_info_by_topic, 3),
    nif_regular_func(rcl_get_service_names_and_types, 1),
    nif_regular_func(rcl_get_service_names_and_types_by_node, 3),
    nif_regular_func(rcl_get_subscriber_names_and_types_by_node, 4),
    nif_regular_func(rcl_get_subscribers_info_by_topic, 3),
    nif_regular_func(rcl_get_topic_names_and_types, 2),
    nif_regular_func(rcl_action_get_client_names_and_types_by_node, 3),
    nif_regular_func(rcl_action_get_names_and_types, 1),
    nif_regular_func(rcl_action_get_server_names_and_types_by_node, 3),
    nif_regular_func(rcl_service_server_is_available, 2),
    nif_io_bound_func(rcl_action_server_init, 6),
    nif_io_bound_func(rcl_action_server_fini, 2),
    nif_regular_func(rcl_action_accept_new_goal, 2),
    nif_regular_func(rcl_action_expire_goals, 2),
    nif_regular_func(rcl_action_publish_feedback, 2),
    nif_regular_func(rcl_action_publish_status, 2),
    nif_regular_func(rcl_action_send_cancel_response, 3),
    nif_regular_func(rcl_action_send_goal_response, 3),
    nif_regular_func(rcl_action_send_result_response, 3),
    nif_regular_func(rcl_action_server_get_goal_handles, 1),
    nif_regular_func(rcl_action_server_goal_exists, 2),
    nif_regular_func(rcl_action_notify_goal_done, 1),
#ifndef ROS_DISTRO_foxy
    nif_regular_func(rcl_action_server_set_cancel_service_callback, 1),
    nif_regular_func(rcl_action_server_set_goal_service_callback, 1),
    nif_regular_func(rcl_action_server_set_result_service_callback, 1),
    nif_regular_func(rcl_action_server_clear_cancel_service_callback, 2),
    nif_regular_func(rcl_action_server_clear_goal_service_callback, 2),
    nif_regular_func(rcl_action_server_clear_result_service_callback, 2),
#endif
    nif_regular_func(rcl_action_take_cancel_request, 2),
    nif_regular_func(rcl_action_take_goal_request, 2),
    nif_regular_func(rcl_action_take_result_request, 2),
// nif_regular_func(rcl_action_goal_handle_fini, 1),
    nif_regular_func(rcl_action_update_goal_state, 2),
    nif_regular_func(rcl_action_goal_handle_get_status, 1),
    nif_regular_func(rcl_action_goal_handle_is_active, 1),
    nif_regular_func(rcl_action_goal_handle_is_cancelable, 1),
    nif_regular_func(rcl_action_goal_handle_is_valid, 1),
    nif_regular_func(rcl_action_process_cancel_request, 3),
   // nif_io_bound_func(rcl_wait_for_publishers, 4),
   // nif_io_bound_func(rcl_wait_for_subscribers, 4),
    nif_regular_func(rmw_qos_profile_sensor_data, 0),
    nif_regular_func(rmw_qos_profile_parameters, 0),
    nif_regular_func(rmw_qos_profile_default, 0),
    nif_regular_func(rmw_qos_profile_services_default, 0),
    nif_regular_func(rmw_qos_profile_parameter_events, 0),
    nif_regular_func(rmw_qos_profile_system_default, 0),
    nif_regular_func(rcl_action_qos_profile_status_default, 0),
#include "msg_funcs.ec" // IWYU pragma: keep
#include "srv_funcs.ec" // IWYU pragma: keep
#include "action_funcs.ec" // IWYU pragma: keep
    // clang-format on
};

static int load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info) {
  ignore_unused(priv_data);
  ignore_unused(load_info);

  make_common_atoms(env);
  make_node_atoms(env);
  make_qos_atoms(env);
  make_subscription_atoms(env);
  make_service_atoms(env);
  make_client_atoms(env);
  make_action_client_atoms(env);
  make_action_server_atoms(env);
  make_clock_atoms(env);

  // open_resource_types/2 the 2nd argument is module_str, but document says following.
  // > Argument module_str is not (yet) used and must be NULL
  if (open_resource_types(env, NULL) != 0) return 1;

  return 0;
}

static int upgrade(ErlNifEnv *env, void **priv_data, void **old_priv_data, ERL_NIF_TERM load_info) {
  ignore_unused(old_priv_data);

  return load(env, priv_data, load_info);
}

ERL_NIF_INIT(Elixir.Rclex.Nif, nif_funcs, load, NULL, upgrade, NULL)
