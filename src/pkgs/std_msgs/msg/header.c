#include "header.h"
#include "../../../macros.h"
#include "../../../resource_types.h"
#include "../../../terms.h"
#include <builtin_interfaces/msg/detail/time__struct.h>
#include <erl_nif.h>
#include <rosidl_runtime_c/message_type_support_struct.h>
#include <rosidl_runtime_c/string.h>
#include <rosidl_runtime_c/string_functions.h>
#include <std_msgs/msg/detail/header__functions.h>
#include <std_msgs/msg/detail/header__struct.h>
#include <std_msgs/msg/detail/header__type_support.h>
#include <stddef.h>

ERL_NIF_TERM nif_std_msgs_msg_header_type_support(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p = ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs, msg, Header);
  rosidl_message_type_support_t *obj =
      enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj              = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_msgs_msg_header_create(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  std_msgs__msg__Header *message_p = std_msgs__msg__Header__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj        = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj              = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_std_msgs_msg_header_destroy(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__Header *message_p = (std_msgs__msg__Header *)*ros_message_pp;
  std_msgs__msg__Header__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_std_msgs_msg_header_set(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__Header *message_p = (std_msgs__msg__Header *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  int stamp_arity;
  const ERL_NIF_TERM *stamp_tuple;
  if (!enif_get_tuple(env, tuple[0], &stamp_arity, &stamp_tuple)) return enif_make_badarg(env);

  if (!enif_get_int(env, stamp_tuple[0], &(message_p->stamp.sec))) return enif_make_badarg(env);

  if (!enif_get_uint(env, stamp_tuple[1], &(message_p->stamp.nanosec)))
    return enif_make_badarg(env);

  unsigned int frame_id_length;
#if (ERL_NIF_MAJOR_VERSION == 2 && ERL_NIF_MINOR_VERSION >= 17) // OTP-26 and later
  if (!enif_get_string_length(env, tuple[1], &frame_id_length, ERL_NIF_LATIN1))
    return enif_make_badarg(env);
#else
  if (!enif_get_list_length(env, tuple[1], &length)) return enif_make_badarg(env);
#endif

  char frame_id[frame_id_length + 1];
  if (enif_get_string(env, tuple[1], frame_id, frame_id_length + 1, ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  if (!rosidl_runtime_c__String__assign(&message_p->frame_id, frame_id))
    return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

ERL_NIF_TERM nif_std_msgs_msg_header_get(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  std_msgs__msg__Header *message_p = (std_msgs__msg__Header *)*ros_message_pp;

  return enif_make_tuple(env, 2,
                         enif_make_tuple(env, 2, enif_make_int(env, message_p->stamp.sec),
                                         enif_make_uint(env, message_p->stamp.nanosec)),
                         enif_make_string(env, message_p->frame_id.data, ERL_NIF_LATIN1));
}
