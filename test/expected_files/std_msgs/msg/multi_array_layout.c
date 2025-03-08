// clang-format off
#include "multi_array_layout.h"
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
#include <std_msgs/msg/detail/multi_array_layout__type_support.h>

#include <stddef.h>
#include <stdint.h>
#include <string.h>

ERL_NIF_TERM nif_std_msgs_msg_multi_array_layout_type_support(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p = ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, MultiArrayLayout);
  rosidl_message_type_support_t *obj = enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_layout_create(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  std_msgs__msg__MultiArrayLayout *message_p = std_msgs__msg__MultiArrayLayout__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_layout_destroy(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__MultiArrayLayout *message_p = (std_msgs__msg__MultiArrayLayout *)*ros_message_pp;
  std_msgs__msg__MultiArrayLayout__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_layout_set(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__MultiArrayLayout *message_p = (std_msgs__msg__MultiArrayLayout *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  unsigned int dim_length;
  if (!enif_get_list_length(env, tuple[0], &dim_length))
    return enif_make_badarg(env);

  std_msgs__msg__MultiArrayDimension__Sequence *dim = std_msgs__msg__MultiArrayDimension__Sequence__create(dim_length);
  if (dim == NULL) return raise(env, __FILE__, __LINE__);
  message_p->dim = *dim;

  unsigned int dim_i;
  ERL_NIF_TERM dim_left, dim_head, dim_tail;
  for (dim_i = 0, dim_left = tuple[0]; dim_i < dim_length; ++dim_i, dim_left = dim_tail)
  {
    if (!enif_get_list_cell(env, dim_left, &dim_head, &dim_tail))
      return enif_make_badarg(env);

    int dim_i_arity;
    const ERL_NIF_TERM *dim_i_tuple;
    if (!enif_get_tuple(env, dim_head, &dim_i_arity, &dim_i_tuple))
      return enif_make_badarg(env);

    ErlNifBinary dim_i_label_binary;
    if (!enif_inspect_binary(env, dim_i_tuple[0], &dim_i_label_binary))
      return enif_make_badarg(env);

    if (!rosidl_runtime_c__String__assignn(&(message_p->dim.data[dim_i].label), (const char *)dim_i_label_binary.data, dim_i_label_binary.size))
      return raise(env, __FILE__, __LINE__);

    unsigned int dim_i_size;
    if (!enif_get_uint(env, dim_i_tuple[1], &dim_i_size))
      return enif_make_badarg(env);
    message_p->dim.data[dim_i].size = dim_i_size;

    unsigned int dim_i_stride;
    if (!enif_get_uint(env, dim_i_tuple[2], &dim_i_stride))
      return enif_make_badarg(env);
    message_p->dim.data[dim_i].stride = dim_i_stride;
  }

  unsigned int data_offset;
  if (!enif_get_uint(env, tuple[1], &data_offset))
    return enif_make_badarg(env);
  message_p->data_offset = data_offset;

  return atom_ok;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_layout_get(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__MultiArrayLayout *message_p = (std_msgs__msg__MultiArrayLayout *)*ros_message_pp;

  ERL_NIF_TERM dim[message_p->dim.size];

  for (size_t dim_i = 0; dim_i < message_p->dim.size; ++dim_i)
  {
    dim[dim_i] = enif_make_tuple(env, 3,
      enif_make_binary_wrapper(env, message_p->dim.data[dim_i].label.data, message_p->dim.data[dim_i].label.size),
      enif_make_uint(env, message_p->dim.data[dim_i].size),
      enif_make_uint(env, message_p->dim.data[dim_i].stride)
    );
  }

  return enif_make_tuple(env, 2,
    enif_make_list_from_array(env, dim, message_p->dim.size),
    enif_make_uint(env, message_p->data_offset)
  );
}
// clang-format on
