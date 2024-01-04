#include "rcl_publisher.h"
#include "qos.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/node.h>
#include <rcl/publisher.h>
#include <rcl/types.h>
#include <rmw/ret_types.h>
#include <rmw/types.h>
#include <rmw/validate_full_topic_name.h>
#include <rosidl_runtime_c/message_type_support_struct.h>
#include <stddef.h>

ERL_NIF_TERM nif_rcl_publisher_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
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
  rcl_publisher_t publisher                 = rcl_get_zero_initialized_publisher();
  rcl_publisher_options_t publisher_options = rcl_publisher_get_default_options();
  publisher_options.qos                     = qos;

  rc = rcl_publisher_init(&publisher, node_p, ts_p, topic_name, &publisher_options);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rcl_publisher_t *obj = enif_alloc_resource(rt_rcl_publisher_t, sizeof(rcl_publisher_t));
  *obj                 = publisher;
  ERL_NIF_TERM term    = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_publisher_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_publisher_t *publisher_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_publisher_t, (void **)&publisher_p))
    return enif_make_badarg(env);
  if (!rcl_publisher_is_valid(publisher_p)) return raise(env, __FILE__, __LINE__);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[1], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rc = rcl_publisher_fini(publisher_p, node_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_publish(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_publisher_t *publisher_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_publisher_t, (void **)&publisher_p))
    return enif_make_badarg(env);
  if (!rcl_publisher_is_valid(publisher_p)) return raise(env, __FILE__, __LINE__);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[1], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  rc = rcl_publish(publisher_p, *ros_message_pp, NULL);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}
