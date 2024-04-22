#include "rcl_subscription.h"
#include "allocator.h"
#include "qos.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/node.h>
#include <rcl/subscription.h>
#include <rcl/types.h>
#include <rmw/ret_types.h>
#include <rmw/types.h>
#include <rmw/validate_full_topic_name.h>
#include <rosidl_runtime_c/message_type_support_struct.h>
#include <stddef.h>

ERL_NIF_TERM new_message;

void make_subscription_atom(ErlNifEnv *env) { new_message = enif_make_atom(env, "new_message"); }

ERL_NIF_TERM nif_rcl_subscription_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 4) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rosidl_message_type_support_t *ts_p;
  if (!enif_get_resource(env, argv[1], rt_rosidl_message_type_support_t, (void **)&ts_p))
    return enif_make_badarg(env);

  rmw_ret_t rm;
  int validation_result;

  char topic_name[256];
  if (enif_get_string(env, argv[2], topic_name, sizeof(topic_name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);
  rm = rmw_validate_full_topic_name(topic_name, &validation_result, NULL);
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
  rcl_subscription_t subscription                 = rcl_get_zero_initialized_subscription();
  rcl_subscription_options_t subscription_options = rcl_subscription_get_default_options();
  subscription_options.allocator                  = get_nif_allocator();
  subscription_options.qos                        = qos;

  rc = rcl_subscription_init(&subscription, node_p, ts_p, topic_name, &subscription_options);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rcl_subscription_t *obj = enif_alloc_resource(rt_rcl_subscription_t, sizeof(rcl_subscription_t));
  *obj                    = subscription;
  ERL_NIF_TERM term       = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_subscription_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_subscription_t *subscription_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_subscription_t, (void **)&subscription_p))
    return enif_make_badarg(env);
  if (!rcl_subscription_is_valid(subscription_p)) return raise(env, __FILE__, __LINE__);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[1], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rc = rcl_subscription_fini(subscription_p, node_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_take(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_subscription_t *subscription_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_subscription_t, (void **)&subscription_p))
    return enif_make_badarg(env);
  if (!rcl_subscription_is_valid(subscription_p)) return raise(env, __FILE__, __LINE__);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  rc = rcl_take(subscription_p, *ros_message_pp, NULL, NULL);
  if (rc == RCL_RET_OK) return atom_ok;
  if (rc == RCL_RET_SUBSCRIPTION_TAKE_FAILED) return atom_error;
  return raise(env, __FILE__, __LINE__);
}

#ifndef ROS_DISTRO_foxy
static void new_message_callback(const void *user_data, size_t number_of_events) {
  ErlNifPid *pid_p = (ErlNifPid *)user_data;

  ErlNifEnv *env = enif_alloc_env();
  enif_send(env, pid_p, env,
            enif_make_tuple(env, 2, new_message, enif_make_int(env, number_of_events)));
  enif_free_env(env);
}

ERL_NIF_TERM nif_rcl_subscription_set_on_new_message_callback(ErlNifEnv *env, int argc,
                                                              const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_subscription_t *subscription_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_subscription_t, (void **)&subscription_p))
    return enif_make_badarg(env);
  if (!rcl_subscription_is_valid(subscription_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p =
      (ErlNifPid *)enif_alloc_resource(rt_subscription_callback_resource, sizeof(ErlNifPid));
  if (enif_self(env, pid_p) == NULL) return raise(env, __FILE__, __LINE__);
  enif_keep_resource(pid_p);

  rcl_ret_t rc;
  rc = rcl_subscription_set_on_new_message_callback(subscription_p, new_message_callback,
                                                    (const void *)pid_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return enif_make_resource(env, pid_p);
}

ERL_NIF_TERM nif_rcl_subscription_clear_message_callback(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_subscription_t *subscription_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_subscription_t, (void **)&subscription_p))
    return enif_make_badarg(env);
  if (!rcl_subscription_is_valid(subscription_p)) return raise(env, __FILE__, __LINE__);

  ErlNifPid *pid_p = NULL;
  if (!enif_get_resource(env, argv[1], rt_subscription_callback_resource, (void **)&pid_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_subscription_set_on_new_message_callback(subscription_p, NULL, NULL);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  enif_release_resource(pid_p);

  return atom_ok;
}
#endif
