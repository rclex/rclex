#include "allocator.h"
#include "macros.h"
#include "qos.h"
#include "rcl_service.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/node.h>
#include <rcl/types.h>
#include <rcl_action/rcl_action.h>
#include <rmw/ret_types.h>
#include <rmw/types.h>
#include <rmw/validate_full_topic_name.h>
#include <rosidl_runtime_c/message_type_support_struct.h>
#include <stddef.h>

ERL_NIF_TERM atom_action_server_take_failed;
ERL_NIF_TERM atom_new_cancel_request;
ERL_NIF_TERM atom_new_goal_request;
ERL_NIF_TERM atom_new_result_request;
ERL_NIF_TERM atom_goal_event_execute;
ERL_NIF_TERM atom_goal_event_cancel_goal;
ERL_NIF_TERM atom_goal_event_succeed;
ERL_NIF_TERM atom_goal_event_abort;
ERL_NIF_TERM atom_goal_event_canceled;

void make_action_server_atoms(ErlNifEnv *env) {
  atom_new_cancel_request        = enif_make_atom(env, "new_cancel_request");
  atom_new_goal_request          = enif_make_atom(env, "new_goal_request");
  atom_new_result_request        = enif_make_atom(env, "new_result_request");
  atom_action_server_take_failed = enif_make_atom(env, "action_server_take_failed");
  atom_goal_event_execute        = enif_make_atom(env, "goal_event_execute");
  atom_goal_event_cancel_goal    = enif_make_atom(env, "goal_event_cancel_goal");
  atom_goal_event_succeed        = enif_make_atom(env, "goal_event_succeed");
  atom_goal_event_abort          = enif_make_atom(env, "goal_event_abort");
  atom_goal_event_canceled       = enif_make_atom(env, "goal_event_canceled");
}

ERL_NIF_TERM nif_rcl_action_server_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 6) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rosidl_action_type_support_t *ts_p;
  if (!enif_get_resource(env, argv[1], rt_rosidl_action_type_support_t, (void **)&ts_p))
    return enif_make_badarg(env);

  rmw_ret_t rm;
  int validation_result;

  char action_name[256];
  if (enif_get_string(env, argv[2], action_name, sizeof(action_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);
  rm = rmw_validate_full_topic_name(action_name, &validation_result, NULL);
  if (rm != RMW_RET_OK) return raise(env, __FILE__, __LINE__);
  if (validation_result != RMW_TOPIC_VALID) {
    const char *message = rmw_full_topic_name_validation_result_string(validation_result);
    return raise_with_message(env, __FILE__, __LINE__, message);
  }

  rcl_clock_t *clock_p;
  if (!enif_get_resource(env, argv[3], rt_rcl_clock_t, (void **)&clock_p))
    return enif_make_badarg(env);

  int arity;
  const ERL_NIF_TERM *qos_tuple;
  if (!enif_get_tuple(env, argv[4], &arity, &qos_tuple) || arity != 5) return enif_make_badarg(env);

  ERL_NIF_TERM goal_service_qos_map   = qos_tuple[0];
  ERL_NIF_TERM result_service_qos_map = qos_tuple[1];
  ERL_NIF_TERM cancel_service_qos_map = qos_tuple[2];
  ERL_NIF_TERM feedback_topic_qos_map = qos_tuple[3];
  ERL_NIF_TERM status_topic_qos_map   = qos_tuple[4];

  double result_timeout_seconds;
  if (!enif_get_double(env, argv[5], &result_timeout_seconds)) return enif_make_badarg(env);
  rcl_duration_t result_timeout;
  result_timeout.nanoseconds = RCUTILS_S_TO_NS(result_timeout_seconds);

  ERL_NIF_TERM ret;
  rmw_qos_profile_t goal_service_qos, result_service_qos, cancel_service_qos, feedback_topic_qos,
      status_topic_qos;

  ret = get_c_qos_profile(env, goal_service_qos_map, &goal_service_qos);
  if (enif_is_exception(env, ret)) return ret;

  ret = get_c_qos_profile(env, result_service_qos_map, &result_service_qos);
  if (enif_is_exception(env, ret)) return ret;

  ret = get_c_qos_profile(env, cancel_service_qos_map, &cancel_service_qos);
  if (enif_is_exception(env, ret)) return ret;

  ret = get_c_qos_profile(env, feedback_topic_qos_map, &feedback_topic_qos);
  if (enif_is_exception(env, ret)) return ret;

  ret = get_c_qos_profile(env, status_topic_qos_map, &status_topic_qos);
  if (enif_is_exception(env, ret)) return ret;

  rcl_ret_t rc;
  rcl_action_server_t action_server                 = rcl_action_get_zero_initialized_server();
  rcl_action_server_options_t action_server_options = rcl_action_server_get_default_options();

  action_server_options.allocator          = get_nif_allocator();
  action_server_options.goal_service_qos   = goal_service_qos;   // rmw_qos_profile_services_default
  action_server_options.result_service_qos = result_service_qos; // rmw_qos_profile_services_default
  action_server_options.cancel_service_qos = cancel_service_qos; // rmw_qos_profile_services_default
  action_server_options.feedback_topic_qos = feedback_topic_qos; // rmw_qos_profile_default
  action_server_options.status_topic_qos =
      status_topic_qos; // rcl_action_qos_profile_status_default
  action_server_options.result_timeout = result_timeout;

  rc = rcl_action_server_init(&action_server, node_p, clock_p, ts_p, action_name,
                              &action_server_options);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rcl_action_server_t *obj =
      enif_alloc_resource(rt_rcl_action_server_t, sizeof(rcl_action_server_t));
  *obj              = action_server;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_action_server_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[1], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rc = rcl_action_server_fini(action_server_p, node_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_action_accept_new_goal(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  rcl_action_goal_info_t **goal_info_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&goal_info_message_pp))
    return enif_make_badarg(env);

  rcl_action_goal_handle_t *goal_handle_p =
      rcl_action_accept_new_goal(action_server_p, *goal_info_message_pp);
  if (goal_handle_p == NULL)
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);

  rcl_action_goal_handle_t *obj =
      enif_alloc_resource(rt_rcl_action_goal_handle_t, sizeof(rcl_action_goal_handle_t));
  *obj = *goal_handle_p; // A flat copy is working here, because the goal_handle is just containing
                         // a reference to the actual implementation
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return enif_make_tuple2(env, atom_ok, term);
}

ERL_NIF_TERM nif_rcl_action_expire_goals(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  unsigned int expired_goals_length;
  if (!enif_get_uint(env, argv[1], &expired_goals_length)) return enif_make_badarg(env);

  rcl_action_goal_info_t *expired_goals =
      enif_alloc(expired_goals_length * sizeof(rcl_action_goal_info_t));
  if (!expired_goals) return raise(env, __FILE__, __LINE__);

  size_t num_expired;
  rc = rcl_action_expire_goals(action_server_p, expired_goals, expired_goals_length, &num_expired);
  if (rc == RCL_RET_INVALID_ARGUMENT) {
    enif_free(expired_goals);
    return enif_make_badarg(env);
  } else if (rc == RCL_RET_ACTION_SERVER_INVALID) {
    enif_free(expired_goals);
    return raise(env, __FILE__, __LINE__);
  } else if (rc == RCL_RET_BAD_ALLOC) {
    enif_free(expired_goals);
    return raise(env, __FILE__, __LINE__);
  } else if (rc == RCL_RET_ERROR) {
    enif_free(expired_goals);
    return raise(env, __FILE__, __LINE__);
  }

  ERL_NIF_TERM *expired_goals_terms = enif_alloc(num_expired * sizeof(ERL_NIF_TERM));
  unsigned int i;
  for (i = 0; i < num_expired; i++) {
    rcl_action_goal_info_t *goal_info_p = action_msgs__msg__GoalInfo__create();
    if (goal_info_p == NULL) {
      enif_free(expired_goals);
      enif_free(expired_goals_terms);
      return raise(env, __FILE__, __LINE__);
    }

    // *goal_info_p = expired_goals[i]
    if (!action_msgs__msg__GoalInfo__copy(&expired_goals[i], goal_info_p)) {
      enif_free(expired_goals);
      enif_free(expired_goals_terms);
      return raise(env, __FILE__, __LINE__);
    }

    void **obj             = enif_alloc_resource(rt_ros_message, sizeof(void *));
    *obj                   = (void *)goal_info_p;
    expired_goals_terms[i] = enif_make_resource(env, obj);
    enif_release_resource(obj);
  }

  enif_free(expired_goals);
  ERL_NIF_TERM result = enif_make_list_from_array(env, expired_goals_terms, num_expired);
  enif_free(expired_goals_terms);
  return enif_make_tuple2(env, atom_ok, result);
}

ERL_NIF_TERM nif_rcl_action_notify_goal_done(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rc = rcl_action_notify_goal_done(action_server_p);
  if (rc != RCL_RET_OK) {
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);
  }

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_action_process_cancel_request(ErlNifEnv *env, int argc,
                                                   const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  rcl_action_cancel_request_t **cancel_request_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&cancel_request_message_pp))
    return enif_make_badarg(env);

  action_msgs__srv__CancelGoal_Response **cancel_response_message_pp;
  if (!enif_get_resource(env, argv[2], rt_ros_message, (void **)&cancel_response_message_pp))
    return enif_make_badarg(env);

  rcl_action_cancel_response_t *cancel_response_p =
      enif_alloc(sizeof(rcl_action_cancel_response_t));
  *cancel_response_p = rcl_action_get_zero_initialized_cancel_response();

  rcl_ret_t rc;
  rc = rcl_action_process_cancel_request(action_server_p, *cancel_request_message_pp,
                                         cancel_response_p);
  if (rc != RCL_RET_OK) {
    rcl_ret_t rc_fini;
    rc_fini = rcl_action_cancel_response_fini(cancel_response_p);
    enif_free(cancel_response_p);
    if (rc_fini != RCL_RET_OK)
      return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);
    else
      return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);
  }

  if (!action_msgs__srv__CancelGoal_Response__copy(&(cancel_response_p->msg),
                                                   *cancel_response_message_pp))
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);
  // **cancel_response_message_pp = cancel_response_p->msg;

  rcl_ret_t rc_fini;
  rc_fini = rcl_action_cancel_response_fini(cancel_response_p);
  enif_free(cancel_response_p);
  if (rc_fini != RCL_RET_OK)
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);
  if (rc != RCL_RET_OK) {
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);
  }

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_action_publish_feedback(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  void **ros_feedback_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&ros_feedback_message_pp))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_action_publish_feedback(action_server_p, *ros_feedback_message_pp);
  if (rc != RCL_RET_OK) {
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);
  }

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_action_publish_status(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  void **ros_status_array_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&ros_status_array_pp))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_action_publish_status(action_server_p, *ros_status_array_pp);
  if (rc != RCL_RET_OK) {
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);
  }

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_action_server_get_goal_handles(ErlNifEnv *env, int argc,
                                                    const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  size_t num_goals;
  rcl_action_goal_handle_t **goal_handles;
  rcl_ret_t rc;
  rc = rcl_action_server_get_goal_handles(action_server_p, &goal_handles, &num_goals);
  if (rc != RCL_RET_OK) {
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);
  }

  unsigned int i;
  ERL_NIF_TERM *goal_handles_terms = enif_alloc(num_goals * sizeof(ERL_NIF_TERM));
  for (i = 0; i < num_goals; i++) {
    rcl_action_goal_handle_t *obj =
        enif_alloc_resource(rt_rcl_action_goal_handle_t, sizeof(rcl_action_goal_handle_t));
    *obj                  = *goal_handles[i];
    goal_handles_terms[i] = enif_make_resource(env, obj);
    enif_release_resource(obj);
  }

  ERL_NIF_TERM result = enif_make_list_from_array(env, goal_handles_terms, num_goals);
  enif_free(goal_handles_terms);
  return enif_make_tuple2(env, atom_ok, result);
}

ERL_NIF_TERM nif_rcl_action_server_goal_exists(ErlNifEnv *env, int argc,
                                               const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  rcl_action_goal_info_t **goal_info_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&goal_info_message_pp))
    return enif_make_badarg(env);

  bool goal_exists;
  goal_exists = rcl_action_server_goal_exists(action_server_p, *goal_info_message_pp);

  if (goal_exists)
    return atom_true;
  else
    return atom_false;
}

ERL_NIF_TERM nif_rcl_action_send_cancel_response(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  rmw_request_id_t *response_header_p;
  if (!enif_get_resource(env, argv[1], rt_rmw_request_id_t, (void **)&response_header_p))
    return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[2], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  rc = rcl_action_send_cancel_response(action_server_p, response_header_p, *ros_message_pp);
  if (rc == RCL_RET_OK)
    return atom_ok;
  else if (rc == RCL_RET_INVALID_ARGUMENT)
    return enif_make_badarg(env);
  else if (rc == RCL_RET_ACTION_SERVER_INVALID)
    return raise(env, __FILE__, __LINE__);
  else if (rc == RCL_RET_TIMEOUT)
    return raise(env, __FILE__, __LINE__);
  else
    return raise(env, __FILE__, __LINE__);
}

ERL_NIF_TERM nif_rcl_action_send_goal_response(ErlNifEnv *env, int argc,
                                               const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  rmw_request_id_t *response_header_p;
  if (!enif_get_resource(env, argv[1], rt_rmw_request_id_t, (void **)&response_header_p))
    return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[2], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  rc = rcl_action_send_goal_response(action_server_p, response_header_p, *ros_message_pp);
  if (rc == RCL_RET_OK)
    return atom_ok;
  else if (rc == RCL_RET_INVALID_ARGUMENT)
    return enif_make_badarg(env);
  else if (rc == RCL_RET_ACTION_SERVER_INVALID)
    return raise(env, __FILE__, __LINE__);
  else if (rc == RCL_RET_TIMEOUT)
    return raise(env, __FILE__, __LINE__);
  else
    return raise(env, __FILE__, __LINE__);
}

ERL_NIF_TERM nif_rcl_action_send_result_response(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  rmw_request_id_t *response_header_p;
  if (!enif_get_resource(env, argv[1], rt_rmw_request_id_t, (void **)&response_header_p))
    return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[2], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  rc = rcl_action_send_result_response(action_server_p, response_header_p, *ros_message_pp);
  if (rc == RCL_RET_OK)
    return atom_ok;
  else if (rc == RCL_RET_INVALID_ARGUMENT)
    return enif_make_badarg(env);
  else if (rc == RCL_RET_ACTION_SERVER_INVALID)
    return raise(env, __FILE__, __LINE__);
  else if (rc == RCL_RET_TIMEOUT)
    return raise(env, __FILE__, __LINE__);
  else
    return raise(env, __FILE__, __LINE__);
}

ERL_NIF_TERM nif_rcl_action_take_cancel_request(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  void **ros_request_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&ros_request_message_pp))
    return enif_make_badarg(env);

  rmw_request_id_t request_header;

  rc = rcl_action_take_cancel_request(action_server_p, &request_header, *ros_request_message_pp);
  if (rc == RCL_RET_OK) {
    rmw_request_id_t *obj = enif_alloc_resource(rt_rmw_request_id_t, sizeof(rmw_request_id_t));
    *obj                  = request_header;
    ERL_NIF_TERM term     = enif_make_resource(env, obj);
    enif_release_resource(obj);
    return enif_make_tuple2(env, atom_ok, term);
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return enif_make_badarg(env);
  } else if (rc == RCL_RET_ACTION_SERVER_TAKE_FAILED) {
    return atom_action_server_take_failed;
  } else {
    return raise(env, __FILE__, __LINE__);
  }
}

ERL_NIF_TERM nif_rcl_action_take_goal_request(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  void **ros_request_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&ros_request_message_pp))
    return enif_make_badarg(env);

  rmw_request_id_t request_header;

  rc = rcl_action_take_goal_request(action_server_p, &request_header, *ros_request_message_pp);
  if (rc == RCL_RET_OK) {
    rmw_request_id_t *obj = enif_alloc_resource(rt_rmw_request_id_t, sizeof(rmw_request_id_t));
    *obj                  = request_header;
    ERL_NIF_TERM term     = enif_make_resource(env, obj);
    enif_release_resource(obj);
    return enif_make_tuple2(env, atom_ok, term);
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return enif_make_badarg(env);
  } else if (rc == RCL_RET_ACTION_SERVER_TAKE_FAILED) {
    return atom_action_server_take_failed;
  } else {
    return raise(env, __FILE__, __LINE__);
  }
}

ERL_NIF_TERM nif_rcl_action_take_result_request(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  void **ros_request_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&ros_request_message_pp))
    return enif_make_badarg(env);

  rmw_request_id_t request_header;

  rc = rcl_action_take_result_request(action_server_p, &request_header, *ros_request_message_pp);
  if (rc == RCL_RET_OK) {
    rmw_request_id_t *obj = enif_alloc_resource(rt_rmw_request_id_t, sizeof(rmw_request_id_t));
    *obj                  = request_header;
    ERL_NIF_TERM term     = enif_make_resource(env, obj);
    enif_release_resource(obj);
    return enif_make_tuple2(env, atom_ok, term);
  } else if (rc == RCL_RET_INVALID_ARGUMENT) {
    return enif_make_badarg(env);
  } else if (rc == RCL_RET_ACTION_SERVER_TAKE_FAILED) {
    return atom_action_server_take_failed;
  } else {
    return raise(env, __FILE__, __LINE__);
  }
}

#ifndef ROS_DISTRO_foxy
static void new_cancel_request_callback(const void *user_data, size_t number_of_events) {
  ErlNifPid *pid_p = (ErlNifPid *)user_data;

  ErlNifEnv *env = enif_alloc_env();
  enif_send(
      env, pid_p, env,
      enif_make_tuple(env, 2, atom_new_cancel_request, enif_make_uint(env, number_of_events)));
  enif_free_env(env);
}

static void new_goal_request_callback(const void *user_data, size_t number_of_events) {
  ErlNifPid *pid_p = (ErlNifPid *)user_data;

  ErlNifEnv *env = enif_alloc_env();
  enif_send(env, pid_p, env,
            enif_make_tuple(env, 2, atom_new_goal_request, enif_make_uint(env, number_of_events)));
  enif_free_env(env);
}

static void new_result_request_callback(const void *user_data, size_t number_of_events) {
  ErlNifPid *pid_p = (ErlNifPid *)user_data;

  ErlNifEnv *env = enif_alloc_env();
  enif_send(
      env, pid_p, env,
      enif_make_tuple(env, 2, atom_new_result_request, enif_make_uint(env, number_of_events)));
  enif_free_env(env);
}

ERL_NIF_TERM nif_rcl_action_server_set_cancel_service_callback(ErlNifEnv *env, int argc,
                                                               const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p = (ErlNifPid *)enif_alloc_resource(
      rt_action_server_cancel_service_callback_resource, sizeof(ErlNifPid));
  if (enif_self(env, pid_p) == NULL) return raise(env, __FILE__, __LINE__);
  enif_keep_resource(pid_p);

  rcl_ret_t rc;
  rc = rcl_action_server_set_cancel_service_callback(action_server_p, new_cancel_request_callback,
                                                     (const void *)pid_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return enif_make_resource(env, pid_p);
}

ERL_NIF_TERM nif_rcl_action_server_clear_cancel_service_callback(ErlNifEnv *env, int argc,
                                                                 const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p = NULL;
  if (!enif_get_resource(env, argv[1], rt_action_server_cancel_service_callback_resource,
                         (void **)&pid_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_action_server_set_cancel_service_callback(action_server_p, NULL, NULL);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  enif_release_resource(pid_p);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_action_server_set_goal_service_callback(ErlNifEnv *env, int argc,
                                                             const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p = (ErlNifPid *)enif_alloc_resource(
      rt_action_server_goal_service_callback_resource, sizeof(ErlNifPid));
  if (enif_self(env, pid_p) == NULL) return raise(env, __FILE__, __LINE__);
  enif_keep_resource(pid_p);

  rcl_ret_t rc;
  rc = rcl_action_server_set_goal_service_callback(action_server_p, new_goal_request_callback,
                                                   (const void *)pid_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return enif_make_resource(env, pid_p);
}

ERL_NIF_TERM nif_rcl_action_server_clear_goal_service_callback(ErlNifEnv *env, int argc,
                                                               const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p = NULL;
  if (!enif_get_resource(env, argv[1], rt_action_server_goal_service_callback_resource,
                         (void **)&pid_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_action_server_set_goal_service_callback(action_server_p, NULL, NULL);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  enif_release_resource(pid_p);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_action_server_set_result_service_callback(ErlNifEnv *env, int argc,
                                                               const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p = (ErlNifPid *)enif_alloc_resource(
      rt_action_server_result_service_callback_resource, sizeof(ErlNifPid));
  if (enif_self(env, pid_p) == NULL) return raise(env, __FILE__, __LINE__);
  enif_keep_resource(pid_p);

  rcl_ret_t rc;
  rc = rcl_action_server_set_result_service_callback(action_server_p, new_result_request_callback,
                                                     (const void *)pid_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return enif_make_resource(env, pid_p);
}

ERL_NIF_TERM nif_rcl_action_server_clear_result_service_callback(ErlNifEnv *env, int argc,
                                                                 const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_action_server_t *action_server_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_server_t, (void **)&action_server_p))
    return enif_make_badarg(env);
  if (!rcl_action_server_is_valid(action_server_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p = NULL;
  if (!enif_get_resource(env, argv[1], rt_action_server_result_service_callback_resource,
                         (void **)&pid_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_action_server_set_result_service_callback(action_server_p, NULL, NULL);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  enif_release_resource(pid_p);

  return atom_ok;
}
#endif

ERL_NIF_TERM nif_rcl_action_goal_handle_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_action_goal_handle_t *goal_handle_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_goal_handle_t, (void **)&goal_handle_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_action_goal_handle_fini(goal_handle_p);
  if (rc != RCL_RET_OK)
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_action_update_goal_state(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_action_goal_handle_t *goal_handle_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_goal_handle_t, (void **)&goal_handle_p))
    return enif_make_badarg(env);

  rcl_action_goal_event_t goal_event;
  if (enif_is_identical(argv[1], atom_goal_event_execute)) {
    goal_event = GOAL_EVENT_EXECUTE;
  } else if (enif_is_identical(argv[1], atom_goal_event_cancel_goal)) {
    goal_event = GOAL_EVENT_CANCEL_GOAL;
  } else if (enif_is_identical(argv[1], atom_goal_event_succeed)) {
    goal_event = GOAL_EVENT_SUCCEED;
  } else if (enif_is_identical(argv[1], atom_goal_event_abort)) {
    goal_event = GOAL_EVENT_ABORT;
  } else if (enif_is_identical(argv[1], atom_goal_event_canceled)) {
    goal_event = GOAL_EVENT_CANCELED;
  } else {
    return raise_with_message(env, __FILE__, __LINE__, "unknown goal state atom");
  }

  rcl_ret_t rc;
  rc = rcl_action_update_goal_state(goal_handle_p, goal_event);
  if (rc != RCL_RET_OK)
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_action_goal_handle_get_info(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_action_goal_handle_t *goal_handle_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_goal_handle_t, (void **)&goal_handle_p))
    return enif_make_badarg(env);

  rcl_action_goal_info_t **goal_info_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&goal_info_message_pp))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_action_goal_handle_get_info(goal_handle_p, *goal_info_message_pp);
  if (rc != RCL_RET_OK)
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_action_goal_handle_get_status(ErlNifEnv *env, int argc,
                                                   const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_action_goal_handle_t *goal_handle_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_goal_handle_t, (void **)&goal_handle_p))
    return enif_make_badarg(env);

  rcl_action_goal_state_t status;
  rcl_ret_t rc;
  rc = rcl_action_goal_handle_get_status(goal_handle_p, &status);
  if (rc != RCL_RET_OK)
    return raise_with_message(env, __FILE__, __LINE__, rcutils_get_error_string().str);

  return enif_make_int(env, status);
}

ERL_NIF_TERM nif_rcl_action_goal_handle_is_active(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_action_goal_handle_t *goal_handle_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_goal_handle_t, (void **)&goal_handle_p))
    return enif_make_badarg(env);

  bool active = rcl_action_goal_handle_is_active(goal_handle_p);

  if (active)
    return atom_true;
  else
    return atom_false;
}

ERL_NIF_TERM nif_rcl_action_goal_handle_is_cancelable(ErlNifEnv *env, int argc,
                                                      const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_action_goal_handle_t *goal_handle_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_goal_handle_t, (void **)&goal_handle_p))
    return enif_make_badarg(env);

  bool active = rcl_action_goal_handle_is_cancelable(goal_handle_p);

  if (active)
    return atom_true;
  else
    return atom_false;
}

ERL_NIF_TERM nif_rcl_action_goal_handle_is_valid(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_action_goal_handle_t *goal_handle_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_action_goal_handle_t, (void **)&goal_handle_p))
    return enif_make_badarg(env);

  bool active = rcl_action_goal_handle_is_valid(goal_handle_p);

  if (active)
    return atom_true;
  else
    return atom_false;
}