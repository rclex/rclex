#include "rcl_client.h"
#include "allocator.h"
#include "qos.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/client.h>
#include <rcl/node.h>
#include <rcl/types.h>
#include <rmw/ret_types.h>
#include <rmw/types.h>
#include <rmw/validate_full_topic_name.h>
#include <rosidl_runtime_c/message_type_support_struct.h>
#include <stddef.h>

ERL_NIF_TERM new_response;

void make_client_atoms(ErlNifEnv *env) { new_response = enif_make_atom(env, "new_response"); }

ERL_NIF_TERM nif_rcl_client_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 4) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rosidl_service_type_support_t *ts_p;
  if (!enif_get_resource(env, argv[1], rt_rosidl_service_type_support_t, (void **)&ts_p))
    return enif_make_badarg(env);

  rmw_ret_t rm;
  int validation_result;

  char service_name[256];
  if (enif_get_string(env, argv[2], service_name, sizeof(service_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);
  rm = rmw_validate_full_topic_name(service_name, &validation_result, NULL);
  if (rm != RMW_RET_OK) return raise(env, __FILE__, __LINE__);
  if (validation_result != RMW_TOPIC_VALID) {
    const char *message = rmw_full_topic_name_validation_result_string(validation_result);
    return raise_with_message(env, __FILE__, __LINE__, message);
  }

  ERL_NIF_TERM qos_map = argv[3];
  rmw_qos_profile_t qos;
  ERL_NIF_TERM ret = get_c_qos_profile(env, qos_map, &qos);
  if (enif_is_exception(env, ret)) return ret;

  rcl_ret_t rc;
  rcl_client_t client                 = rcl_get_zero_initialized_client();
  rcl_client_options_t client_options = rcl_client_get_default_options();
  client_options.allocator            = get_nif_allocator();
  client_options.qos                  = qos;

  rc = rcl_client_init(&client, node_p, ts_p, service_name, &client_options);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rcl_client_t *obj = enif_alloc_resource(rt_rcl_client_t, sizeof(rcl_client_t));
  *obj              = client;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_client_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_client_t *client_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_client_t, (void **)&client_p))
    return enif_make_badarg(env);
  if (!rcl_client_is_valid(client_p)) return raise(env, __FILE__, __LINE__);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[1], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rc = rcl_client_fini(client_p, node_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_take_response_with_info(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_ret_t rc;
  rmw_service_info_t request_header;

  rcl_client_t *client_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_client_t, (void **)&client_p))
    return enif_make_badarg(env);
  if (!rcl_client_is_valid(client_p)) return raise(env, __FILE__, __LINE__);

  void **ros_response_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&ros_response_message_pp))
    return enif_make_badarg(env);

  rc = rcl_take_response_with_info(client_p, &request_header, *ros_response_message_pp);
  int64_t sequence_number = request_header.request_id.sequence_number;

  if (rc == RCL_RET_OK)
    return enif_make_tuple2(env, atom_ok, enif_make_int64(env, sequence_number));
  if (rc == RCL_RET_CLIENT_TAKE_FAILED) return atom_error;
  return raise(env, __FILE__, __LINE__);
}

ERL_NIF_TERM nif_rcl_send_request(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_ret_t rc;
  int64_t sequence_number;

  rcl_client_t *client_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_client_t, (void **)&client_p))
    return enif_make_badarg(env);
  if (!rcl_client_is_valid(client_p)) return raise(env, __FILE__, __LINE__);

  void **ros_request_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&ros_request_message_pp))
    return enif_make_badarg(env);

  rc = rcl_send_request(client_p, *ros_request_message_pp, &sequence_number);

  if (rc == RCL_RET_OK)
    return enif_make_tuple2(env, atom_ok, enif_make_int64(env, sequence_number));
  else
    return raise(env, __FILE__, __LINE__);
}

#ifndef ROS_DISTRO_foxy
static void new_response_callback(const void *user_data, size_t number_of_events) {
  ErlNifPid *pid_p = (ErlNifPid *)user_data;

  ErlNifEnv *env = enif_alloc_env();
  enif_send(env, pid_p, env,
            enif_make_tuple(env, 2, new_response, enif_make_int(env, number_of_events)));
  enif_free_env(env);
}

ERL_NIF_TERM nif_rcl_client_set_on_new_response_callback(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_client_t *client_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_client_t, (void **)&client_p))
    return enif_make_badarg(env);
  if (!rcl_client_is_valid(client_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p =
      (ErlNifPid *)enif_alloc_resource(rt_client_callback_resource, sizeof(ErlNifPid));
  if (enif_self(env, pid_p) == NULL) return raise(env, __FILE__, __LINE__);
  enif_keep_resource(pid_p);

  rcl_ret_t rc;
  rc =
      rcl_client_set_on_new_response_callback(client_p, new_response_callback, (const void *)pid_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return enif_make_resource(env, pid_p);
}

ERL_NIF_TERM nif_rcl_client_clear_response_callback(ErlNifEnv *env, int argc,
                                                    const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_client_t *client_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_client_t, (void **)&client_p))
    return enif_make_badarg(env);
  if (!rcl_client_is_valid(client_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p = NULL;
  if (!enif_get_resource(env, argv[1], rt_client_callback_resource, (void **)&pid_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_client_set_on_new_response_callback(client_p, NULL, NULL);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  enif_release_resource(pid_p);

  return atom_ok;
}
#endif
