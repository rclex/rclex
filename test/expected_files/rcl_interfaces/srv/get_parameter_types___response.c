// clang-format off
#include "get_parameter_types___response.h"
#include "../../../macros.h"
#include "../../../resource_types.h"
#include "../../../terms.h"

#include <erl_nif.h>

#include <rosidl_runtime_c/message_type_support_struct.h>
#include <rosidl_runtime_c/primitives_sequence.h>
#include <rosidl_runtime_c/primitives_sequence_functions.h>
#include <rosidl_runtime_c/string.h>
#include <rosidl_runtime_c/string_functions.h>

#include <rcl_interfaces/srv/detail/get_parameter_types__functions.h>
#include <rcl_interfaces/srv/detail/get_parameter_types__struct.h>
#include <rcl_interfaces/srv/detail/get_parameter_types__type_support.h>

#include <stddef.h>
#include <stdint.h>
#include <string.h>

ERL_NIF_TERM nif_rcl_interfaces_srv_get_parameter_types___response_type_support(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p = ROSIDL_GET_MSG_TYPE_SUPPORT(rcl_interfaces, srv, GetParameterTypes_Response);
  rosidl_message_type_support_t *obj = enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_interfaces_srv_get_parameter_types___response_create(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  rcl_interfaces__srv__GetParameterTypes_Response *message_p = rcl_interfaces__srv__GetParameterTypes_Response__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_interfaces_srv_get_parameter_types___response_destroy(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  rcl_interfaces__srv__GetParameterTypes_Response *message_p = (rcl_interfaces__srv__GetParameterTypes_Response *)*ros_message_pp;
  rcl_interfaces__srv__GetParameterTypes_Response__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_interfaces_srv_get_parameter_types___response_set(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  rcl_interfaces__srv__GetParameterTypes_Response *message_p = (rcl_interfaces__srv__GetParameterTypes_Response *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  ErlNifBinary types_bin;
  if(!enif_inspect_binary(env, tuple[0], &types_bin))
    return enif_make_badarg(env);

  unsigned int types_length = types_bin.size;
  rosidl_runtime_c__uint8__Sequence types;
  if(!rosidl_runtime_c__uint8__Sequence__init(&types, types_length))
    return enif_make_badarg(env);
  message_p->types = types;
  memcpy(message_p->types.data, types_bin.data, types_length);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_interfaces_srv_get_parameter_types___response_get(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  rcl_interfaces__srv__GetParameterTypes_Response *message_p = (rcl_interfaces__srv__GetParameterTypes_Response *)*ros_message_pp;

  ErlNifBinary types_bin;
  if(!enif_alloc_binary(message_p->types.size, &types_bin))
    return raise(env, __FILE__, __LINE__);

  memcpy(types_bin.data, message_p->types.data, types_bin.size);
  ERL_NIF_TERM types = enif_make_binary(env, &types_bin);

  return enif_make_tuple(env, 1,
    types
  );
}
// clang-format on
