#include "rcl_service.h"
#include "allocator.h"
#include "qos.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/node.h>
#include <rcl/service.h>
#include <rcl/types.h>
#include <rmw/ret_types.h>
#include <rmw/types.h>
#include <rmw/validate_full_topic_name.h>
#include <rosidl_runtime_c/message_type_support_struct.h>
#include <stddef.h>

ERL_NIF_TERM atom_new_request;
ERL_NIF_TERM atom_service_take_failed;

void make_service_atoms(ErlNifEnv *env) {
  atom_new_request         = enif_make_atom(env, "new_request");
  atom_service_take_failed = enif_make_atom(env, "service_take_failed");
}

ERL_NIF_TERM nif_rcl_service_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
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
  rcl_service_t service                 = rcl_get_zero_initialized_service();
  rcl_service_options_t service_options = rcl_service_get_default_options();
  service_options.allocator             = get_nif_allocator();
  service_options.qos                   = qos;

  rc = rcl_service_init(&service, node_p, ts_p, service_name, &service_options);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rcl_service_t *obj = enif_alloc_resource(rt_rcl_service_t, sizeof(rcl_service_t));
  *obj               = service;
  ERL_NIF_TERM term  = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_service_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_service_t *service_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_service_t, (void **)&service_p))
    return enif_make_badarg(env);
  if (!rcl_service_is_valid(service_p)) return raise(env, __FILE__, __LINE__);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[1], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rc = rcl_service_fini(service_p, node_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_take_request_with_info(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_service_t *service_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_service_t, (void **)&service_p))
    return enif_make_badarg(env);
  if (!rcl_service_is_valid(service_p)) return raise(env, __FILE__, __LINE__);

  void **ros_request_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&ros_request_message_pp))
    return enif_make_badarg(env);

  rmw_service_info_t request_header;

  rc = rcl_take_request_with_info(service_p, &request_header, *ros_request_message_pp);
  if (rc == RCL_RET_OK) {
    rmw_service_info_t *obj =
        enif_alloc_resource(rt_rmw_service_info_t, sizeof(rmw_service_info_t));
    *obj              = request_header;
    ERL_NIF_TERM term = enif_make_resource(env, obj);
    enif_release_resource(obj);
    return enif_make_tuple2(env, atom_ok, term);
  } else if (rc == RCL_RET_SERVICE_TAKE_FAILED) {
    return atom_service_take_failed;
  } else {
    return raise(env, __FILE__, __LINE__);
  }
}

ERL_NIF_TERM nif_rcl_send_response(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_service_t *service_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_service_t, (void **)&service_p))
    return enif_make_badarg(env);
  if (!rcl_service_is_valid(service_p)) return raise(env, __FILE__, __LINE__);

  rmw_service_info_t *response_header_p;
  if (!enif_get_resource(env, argv[1], rt_rmw_service_info_t, (void **)&response_header_p))
    return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[2], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  rc = rcl_send_response(service_p, &(response_header_p->request_id), *ros_message_pp);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

#ifndef ROS_DISTRO_foxy
static void new_request_callback(const void *user_data, size_t number_of_events) {
  ErlNifPid *pid_p = (ErlNifPid *)user_data;

  ErlNifEnv *env = enif_alloc_env();
  enif_send(env, pid_p, env,
            enif_make_tuple(env, 2, atom_new_request, enif_make_int(env, number_of_events)));
  enif_free_env(env);
}

ERL_NIF_TERM nif_rcl_service_set_on_new_request_callback(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_service_t *service_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_service_t, (void **)&service_p))
    return enif_make_badarg(env);
  if (!rcl_service_is_valid(service_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p =
      (ErlNifPid *)enif_alloc_resource(rt_service_callback_resource, sizeof(ErlNifPid));
  if (enif_self(env, pid_p) == NULL) return raise(env, __FILE__, __LINE__);
  enif_keep_resource(pid_p);

  rcl_ret_t rc;
  rc =
      rcl_service_set_on_new_request_callback(service_p, new_request_callback, (const void *)pid_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return enif_make_resource(env, pid_p);
}

ERL_NIF_TERM nif_rcl_service_clear_request_callback(ErlNifEnv *env, int argc,
                                                    const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_service_t *service_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_service_t, (void **)&service_p))
    return enif_make_badarg(env);
  if (!rcl_service_is_valid(service_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p = NULL;
  if (!enif_get_resource(env, argv[1], rt_service_callback_resource, (void **)&pid_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_service_set_on_new_request_callback(service_p, NULL, NULL);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  enif_release_resource(pid_p);

  return atom_ok;
}
#endif
