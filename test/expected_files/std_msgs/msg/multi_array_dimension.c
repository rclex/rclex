// clang-format off
#include "multi_array_dimension.h"
#include "../../../macros.h"
#include "../../../resource_types.h"
#include "../../../terms.h"

#include <erl_nif.h>

#include <rosidl_runtime_c/message_type_support_struct.h>
#include <rosidl_runtime_c/primitives_sequence.h>
#include <rosidl_runtime_c/primitives_sequence_functions.h>
#include <rosidl_runtime_c/string.h>
#include <rosidl_runtime_c/string_functions.h>

#include <std_msgs/msg/detail/multi_array_dimension__functions.h>
#include <std_msgs/msg/detail/multi_array_dimension__struct.h>
#include <std_msgs/msg/detail/multi_array_dimension__type_support.h>

#include <stddef.h>
#include <stdint.h>
#include <string.h>

ERL_NIF_TERM nif_std_msgs_msg_multi_array_dimension_type_support(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p = ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, MultiArrayDimension);
  rosidl_message_type_support_t *obj = enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_dimension_create(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  std_msgs__msg__MultiArrayDimension *message_p = std_msgs__msg__MultiArrayDimension__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_dimension_destroy(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__MultiArrayDimension *message_p = (std_msgs__msg__MultiArrayDimension *)*ros_message_pp;
  std_msgs__msg__MultiArrayDimension__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_dimension_set(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__MultiArrayDimension *message_p = (std_msgs__msg__MultiArrayDimension *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  ErlNifBinary label_binary;
  if (!enif_inspect_binary(env, tuple[0], &label_binary))
    return enif_make_badarg(env);

  if (!rosidl_runtime_c__String__assignn(&(message_p->label), (const char *)label_binary.data, label_binary.size))
    return raise(env, __FILE__, __LINE__);

  unsigned int size;
  if (!enif_get_uint(env, tuple[1], &size))
    return enif_make_badarg(env);
  message_p->size = size;

  unsigned int stride;
  if (!enif_get_uint(env, tuple[2], &stride))
    return enif_make_badarg(env);
  message_p->stride = stride;

  return atom_ok;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_dimension_get(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__MultiArrayDimension *message_p = (std_msgs__msg__MultiArrayDimension *)*ros_message_pp;

  return enif_make_tuple(env, 3,
    enif_make_binary_wrapper(env, message_p->label.data, message_p->label.size),
    enif_make_uint(env, message_p->size),
    enif_make_uint(env, message_p->stride)
  );
}
// clang-format on
