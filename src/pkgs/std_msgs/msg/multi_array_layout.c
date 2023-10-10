#include "multi_array_layout.h"
#include "../../../macros.h"
#include "../../../resource_types.h"
#include "../../../terms.h"
#include <erl_nif.h>
#include <rosidl_runtime_c/message_type_support_struct.h>
#include <rosidl_runtime_c/string.h>
#include <rosidl_runtime_c/string_functions.h>
#include <std_msgs/msg/detail/multi_array_dimension__functions.h>
#include <std_msgs/msg/detail/multi_array_dimension__struct.h>
#include <std_msgs/msg/detail/multi_array_layout__functions.h>
#include <std_msgs/msg/detail/multi_array_layout__struct.h>
#include <std_msgs/msg/detail/multi_array_layout__type_support.h>
#include <stddef.h>

ERL_NIF_TERM nif_std_msgs_msg_multi_array_layout_type_support(ErlNifEnv *env, int argc,
                                                              const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p =
      ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, MultiArrayLayout);
  rosidl_message_type_support_t *obj =
      enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj              = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_layout_create(ErlNifEnv *env, int argc,
                                                        const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  std_msgs__msg__MultiArrayLayout *message_p = std_msgs__msg__MultiArrayLayout__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj        = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj              = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_layout_destroy(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__MultiArrayLayout *message_p = (std_msgs__msg__MultiArrayLayout *)*ros_message_pp;
  std_msgs__msg__MultiArrayLayout__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_layout_set(ErlNifEnv *env, int argc,
                                                     const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__MultiArrayLayout *message_p = (std_msgs__msg__MultiArrayLayout *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  unsigned int dim_length;
  if (!enif_get_list_length(env, tuple[0], &dim_length)) return enif_make_badarg(env);

  std_msgs__msg__MultiArrayDimension__Sequence *dim =
      std_msgs__msg__MultiArrayDimension__Sequence__create(dim_length);
  if (dim == NULL) return raise(env, __FILE__, __LINE__);
  message_p->dim = *dim;

  unsigned int dim_i;
  ERL_NIF_TERM dim_left, dim_head, dim_tail;
  for (dim_i = 0, dim_left = tuple[0]; dim_i < dim_length; ++dim_i, dim_left = dim_tail) {
    if (!enif_get_list_cell(env, dim_left, &dim_head, &dim_tail)) return enif_make_badarg(env);

    int dim_arity;
    const ERL_NIF_TERM *dim_tuple;
    if (!enif_get_tuple(env, dim_head, &dim_arity, &dim_tuple)) return enif_make_badarg(env);

    unsigned label_length;
#if (ERL_NIF_MAJOR_VERSION == 2 && ERL_NIF_MINOR_VERSION >= 17) // OTP-26 and later
    if (!enif_get_string_length(env, dim_tuple[0], &label_length, ERL_NIF_LATIN1))
      return enif_make_badarg(env);
#else
    if (!enif_get_list_length(env, dim_tuple[0], &label_length)) return enif_make_badarg(env);
#endif

    char label[label_length + 1];
    if (!enif_get_string(env, dim_tuple[0], label, label_length + 1, ERL_NIF_LATIN1))
      return enif_make_badarg(env);
    if (!rosidl_runtime_c__String__assign(&(message_p->dim.data[dim_i].label), label))
      return raise(env, __FILE__, __LINE__);

    if (!enif_get_uint(env, dim_tuple[1], &(message_p->dim.data[dim_i].size)))
      return enif_make_badarg(env);

    if (!enif_get_uint(env, dim_tuple[2], &(message_p->dim.data[dim_i].stride)))
      return enif_make_badarg(env);
  }

  if (!enif_get_uint(env, tuple[1], &(message_p->data_offset))) return enif_make_badarg(env);

  return atom_ok;
}

ERL_NIF_TERM nif_std_msgs_msg_multi_array_layout_get(ErlNifEnv *env, int argc,
                                                     const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__MultiArrayLayout *message_p = (std_msgs__msg__MultiArrayLayout *)*ros_message_pp;

  ERL_NIF_TERM dim[message_p->dim.size];
  for (size_t i = 0; i < message_p->dim.size; ++i) {
    dim[i] = enif_make_tuple(
        env, 3, enif_make_string(env, message_p->dim.data[i].label.data, ERL_NIF_LATIN1),
        enif_make_uint(env, message_p->dim.data[i].size),
        enif_make_uint(env, message_p->dim.data[i].stride));
  }

  return enif_make_tuple(env, 2, enif_make_list_from_array(env, dim, message_p->dim.size),
                         enif_make_uint(env, message_p->data_offset));
}
