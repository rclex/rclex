#include "channel_float32.h"
#include "../../../macros.h"
#include "../../../resource_types.h"
#include "../../../terms.h"
#include <erl_nif.h>
#include <rosidl_runtime_c/message_type_support_struct.h>
#include <rosidl_runtime_c/primitives_sequence.h>
#include <rosidl_runtime_c/primitives_sequence_functions.h>
#include <rosidl_runtime_c/string.h>
#include <rosidl_runtime_c/string_functions.h>
#include <sensor_msgs/msg/detail/channel_float32__functions.h>
#include <sensor_msgs/msg/detail/channel_float32__struct.h>
#include <sensor_msgs/msg/detail/channel_float32__type_support.h>
#include <stddef.h>

ERL_NIF_TERM nif_sensor_msgs_msg_channel_float32_type_support(ErlNifEnv *env, int argc,
                                                              const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p =
      ROSIDL_GET_MSG_TYPE_SUPPORT(sensor_msgs, msg, ChannelFloat32);
  rosidl_message_type_support_t *obj =
      enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj              = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_sensor_msgs_msg_channel_float32_create(ErlNifEnv *env, int argc,
                                                        const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  sensor_msgs__msg__ChannelFloat32 *message_p = sensor_msgs__msg__ChannelFloat32__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj        = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj              = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_sensor_msgs_msg_channel_float32_destroy(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  sensor_msgs__msg__ChannelFloat32 *message_p = (sensor_msgs__msg__ChannelFloat32 *)*ros_message_pp;
  sensor_msgs__msg__ChannelFloat32__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_sensor_msgs_msg_channel_float32_set(ErlNifEnv *env, int argc,
                                                     const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  sensor_msgs__msg__ChannelFloat32 *message_p = (sensor_msgs__msg__ChannelFloat32 *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  unsigned int name_length;
#if (ERL_NIF_MAJOR_VERSION == 2 && ERL_NIF_MINOR_VERSION >= 17) // OTP-26 and later
  if (!enif_get_string_length(env, tuple[0], &name_length, ERL_NIF_LATIN1))
    return enif_make_badarg(env);
#else
  if (!enif_get_list_length(env, tuple[0], &name_length)) return enif_make_badarg(env);
#endif

  char name[name_length + 1];
  if (enif_get_string(env, tuple[0], name, name_length + 1, ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  if (!rosidl_runtime_c__String__assign(&message_p->name, name))
    return raise(env, __FILE__, __LINE__);

  unsigned int values_length;
  if (!enif_get_list_length(env, tuple[1], &values_length)) return enif_make_badarg(env);

  rosidl_runtime_c__float32__Sequence values;
  if (!rosidl_runtime_c__float32__Sequence__init(&values, values_length))
    return enif_make_badarg(env);

  unsigned int values_i;
  ERL_NIF_TERM values_left, values_head, values_tail;
  for (values_i = 0, values_left = tuple[1]; values_i < values_length;
       ++values_i, values_left   = values_tail) {
    if (!enif_get_list_cell(env, values_left, &values_head, &values_tail))
      return enif_make_badarg(env);
    if (!enif_get_double(env, values_head, (double *)&(values.data[values_i])))
      return enif_make_badarg(env);
  }

  message_p->values = values;

  return atom_ok;
}

ERL_NIF_TERM nif_sensor_msgs_msg_channel_float32_get(ErlNifEnv *env, int argc,
                                                     const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  sensor_msgs__msg__ChannelFloat32 *message_p = (sensor_msgs__msg__ChannelFloat32 *)*ros_message_pp;

  ERL_NIF_TERM values[message_p->values.size];
  for (size_t i = 0; i < message_p->values.size; ++i) {
    values[i] = enif_make_uint(env, message_p->values.data[i]);
  }

  return enif_make_tuple(env, 2, enif_make_string(env, message_p->name.data, ERL_NIF_LATIN1),
                         enif_make_list_from_array(env, values, message_p->values.size));
}
