#include "time.h"
#include "../../../macros.h"
#include "../../../resource_types.h"
#include "../../../terms.h"
#include <builtin_interfaces/msg/detail/time__functions.h>
#include <builtin_interfaces/msg/detail/time__struct.h>
#include <builtin_interfaces/msg/detail/time__type_support.h>
#include <erl_nif.h>
#include <rosidl_runtime_c/message_type_support_struct.h>
#include <stddef.h>

ERL_NIF_TERM nif_builtin_interfaces_msg_time_type_support(ErlNifEnv *env, int argc,
                                                          const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p =
      ROSIDL_GET_MSG_TYPE_SUPPORT(builtin_interfaces, msg, Time);
  rosidl_message_type_support_t *obj =
      enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj              = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_builtin_interfaces_msg_time_create(ErlNifEnv *env, int argc,
                                                    const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  builtin_interfaces__msg__Time *message_p = builtin_interfaces__msg__Time__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj        = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj              = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_builtin_interfaces_msg_time_destroy(ErlNifEnv *env, int argc,
                                                     const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  builtin_interfaces__msg__Time *message_p = (builtin_interfaces__msg__Time *)*ros_message_pp;
  builtin_interfaces__msg__Time__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_builtin_interfaces_msg_time_set(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  builtin_interfaces__msg__Time *message_p = (builtin_interfaces__msg__Time *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  if (!enif_get_int(env, tuple[0], &(message_p->sec))) return enif_make_badarg(env);

  if (!enif_get_uint(env, tuple[1], &(message_p->nanosec))) return enif_make_badarg(env);

  return atom_ok;
}

ERL_NIF_TERM nif_builtin_interfaces_msg_time_get(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  builtin_interfaces__msg__Time *message_p = (builtin_interfaces__msg__Time *)*ros_message_pp;

  return enif_make_tuple(env, 2, enif_make_int(env, message_p->sec),
                         enif_make_uint(env, message_p->nanosec));
}
