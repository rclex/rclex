// clang-format off
#include "set_bool___request.h"
#include "../../../macros.h"
#include "../../../resource_types.h"
#include "../../../terms.h"

#include <erl_nif.h>

#include <rosidl_runtime_c/message_type_support_struct.h>
#include <rosidl_runtime_c/primitives_sequence.h>
#include <rosidl_runtime_c/primitives_sequence_functions.h>
#include <rosidl_runtime_c/string.h>
#include <rosidl_runtime_c/string_functions.h>

#include <std_srvs/srv/detail/set_bool__functions.h>
#include <std_srvs/srv/detail/set_bool__struct.h>
#include <std_srvs/srv/detail/set_bool__type_support.h>

#include <stddef.h>
#include <stdint.h>
#include <string.h>

ERL_NIF_TERM nif_std_srvs_srv_set_bool___request_type_support(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p = ROSIDL_GET_MSG_TYPE_SUPPORT(std_srvs, srv, SetBool_Request);
  rosidl_message_type_support_t *obj = enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_srvs_srv_set_bool___request_create(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  std_srvs__srv__SetBool_Request *message_p = std_srvs__srv__SetBool_Request__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_srvs_srv_set_bool___request_destroy(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_srvs__srv__SetBool_Request *message_p = (std_srvs__srv__SetBool_Request *)*ros_message_pp;
  std_srvs__srv__SetBool_Request__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_std_srvs_srv_set_bool___request_set(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_srvs__srv__SetBool_Request *message_p = (std_srvs__srv__SetBool_Request *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  unsigned int data_length;
  if (!enif_get_atom_length(env, tuple[0], &data_length, ERL_NIF_LATIN1))
    return enif_make_badarg(env);

  char data[data_length + 1];
  if (enif_get_atom(env, tuple[0], data, data_length + 1, ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  message_p->data = (strncmp(data, "true", 4) == 0);

  return atom_ok;
}

ERL_NIF_TERM nif_std_srvs_srv_set_bool___request_get(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_srvs__srv__SetBool_Request *message_p = (std_srvs__srv__SetBool_Request *)*ros_message_pp;

  return enif_make_tuple(env, 1,
    enif_make_atom(env, message_p->data ? "true" : "false")
  );
}
// clang-format on
