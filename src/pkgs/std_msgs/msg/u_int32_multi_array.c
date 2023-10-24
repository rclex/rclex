#include "u_int32_multi_array.h"
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
#include <std_msgs/msg/detail/multi_array_layout__functions.h>
#include <std_msgs/msg/detail/multi_array_layout__struct.h>
#include <std_msgs/msg/detail/u_int32_multi_array__functions.h>
#include <std_msgs/msg/detail/u_int32_multi_array__struct.h>
#include <std_msgs/msg/detail/u_int32_multi_array__type_support.h>
#include <stddef.h>
#include <stdint.h>

ERL_NIF_TERM nif_std_msgs_msg_u_int32_multi_array_type_support(ErlNifEnv *env, int argc,
                                                               const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p =
      ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, UInt32MultiArray);
  rosidl_message_type_support_t *obj =
      enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj              = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_msgs_msg_u_int32_multi_array_create(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  std_msgs__msg__UInt32MultiArray *message_p = std_msgs__msg__UInt32MultiArray__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj        = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj              = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_msgs_msg_u_int32_multi_array_destroy(ErlNifEnv *env, int argc,
                                                          const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__UInt32MultiArray *message_p = (std_msgs__msg__UInt32MultiArray *)*ros_message_pp;
  std_msgs__msg__UInt32MultiArray__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_std_msgs_msg_u_int32_multi_array_set(ErlNifEnv *env, int argc,
                                                      const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__UInt32MultiArray *message_p = (std_msgs__msg__UInt32MultiArray *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  int layout_arity;
  const ERL_NIF_TERM *layout_tuple;
  if (!enif_get_tuple(env, tuple[0], &layout_arity, &layout_tuple)) return enif_make_badarg(env);

  unsigned int layout_dim_length;
  if (!enif_get_list_length(env, layout_tuple[0], &layout_dim_length)) return enif_make_badarg(env);

  std_msgs__msg__MultiArrayDimension__Sequence *layout_dim =
      std_msgs__msg__MultiArrayDimension__Sequence__create(layout_dim_length);
  if (layout_dim == NULL) return raise(env, __FILE__, __LINE__);
  message_p->layout.dim = *layout_dim;

  unsigned int layout_dim_i;
  ERL_NIF_TERM layout_dim_left, layout_dim_head, layout_dim_tail;
  for (layout_dim_i = 0, layout_dim_left = layout_tuple[0]; layout_dim_i < layout_dim_length;
       ++layout_dim_i, layout_dim_left   = layout_dim_tail) {
    if (!enif_get_list_cell(env, layout_dim_left, &layout_dim_head, &layout_dim_tail))
      return enif_make_badarg(env);

    int layout_dim_i_arity;
    const ERL_NIF_TERM *layout_dim_i_tuple;
    if (!enif_get_tuple(env, layout_dim_head, &layout_dim_i_arity, &layout_dim_i_tuple))
      return enif_make_badarg(env);

    unsigned int layout_dim_i_label_length;
#if (ERL_NIF_MAJOR_VERSION == 2 && ERL_NIF_MINOR_VERSION >= 17) // OTP-26 and later
    if (!enif_get_string_length(env, layout_dim_i_tuple[0], &layout_dim_i_label_length,
                                ERL_NIF_LATIN1))
      return enif_make_badarg(env);
#else
    if (!enif_get_list_length(env, layout_dim_i_tuple[0], &layout_dim_i_label_length))
      return enif_make_badarg(env);
#endif

    char layout_dim_i_label[layout_dim_i_label_length + 1];
    if (enif_get_string(env, layout_dim_i_tuple[0], layout_dim_i_label,
                        layout_dim_i_label_length + 1, ERL_NIF_LATIN1) <= 0)
      return enif_make_badarg(env);

    if (!rosidl_runtime_c__String__assign(&(message_p->layout.dim.data[layout_dim_i].label),
                                          layout_dim_i_label))
      return raise(env, __FILE__, __LINE__);

    unsigned int layout_dim_i_size;
    if (!enif_get_uint(env, layout_dim_i_tuple[1], &layout_dim_i_size))
      return enif_make_badarg(env);
    message_p->layout.dim.data[layout_dim_i].size = layout_dim_i_size;

    unsigned int layout_dim_i_stride;
    if (!enif_get_uint(env, layout_dim_i_tuple[2], &layout_dim_i_stride))
      return enif_make_badarg(env);
    message_p->layout.dim.data[layout_dim_i].stride = layout_dim_i_stride;
  }

  unsigned int layout_data_offset;
  if (!enif_get_uint(env, layout_tuple[1], &layout_data_offset)) return enif_make_badarg(env);
  message_p->layout.data_offset = layout_data_offset;

  unsigned int data_length;
  if (!enif_get_list_length(env, tuple[1], &data_length)) return enif_make_badarg(env);

  rosidl_runtime_c__uint32__Sequence data;
  if (!rosidl_runtime_c__uint32__Sequence__init(&data, data_length)) return enif_make_badarg(env);
  message_p->data = data;

  unsigned int data_i;
  ERL_NIF_TERM data_left, data_head, data_tail;
  for (data_i = 0, data_left = tuple[1]; data_i < data_length; ++data_i, data_left = data_tail) {
    if (!enif_get_list_cell(env, data_left, &data_head, &data_tail)) return enif_make_badarg(env);

    unsigned int data_uint32;
    if (!enif_get_uint(env, data_head, &data_uint32)) return enif_make_badarg(env);
    message_p->data.data[data_i] = data_uint32;
  }

  return atom_ok;
}

ERL_NIF_TERM nif_std_msgs_msg_u_int32_multi_array_get(ErlNifEnv *env, int argc,
                                                      const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__UInt32MultiArray *message_p = (std_msgs__msg__UInt32MultiArray *)*ros_message_pp;

  ERL_NIF_TERM layout_dim[message_p->layout.dim.size];
  for (size_t layout_dim_i = 0; layout_dim_i < message_p->layout.dim.size; ++layout_dim_i) {
    layout_dim[layout_dim_i] = enif_make_tuple(
        env, 3,
        enif_make_string(env, message_p->layout.dim.data[layout_dim_i].label.data, ERL_NIF_LATIN1),
        enif_make_uint(env, message_p->layout.dim.data[layout_dim_i].size),
        enif_make_uint(env, message_p->layout.dim.data[layout_dim_i].stride));
  }

  ERL_NIF_TERM data[message_p->data.size];
  for (size_t data_i = 0; data_i < message_p->data.size; ++data_i) {
    data[data_i] = enif_make_uint(env, message_p->data.data[data_i]);
  }

  return enif_make_tuple(
      env, 2,
      enif_make_tuple(env, 2,
                      enif_make_list_from_array(env, layout_dim, message_p->layout.dim.size),
                      enif_make_uint(env, message_p->layout.data_offset)),
      enif_make_list_from_array(env, data, message_p->data.size));
}
