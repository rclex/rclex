// clang-format off
#include "twist.h"
#include "../../../macros.h"
#include "../../../resource_types.h"
#include "../../../terms.h"

#include <erl_nif.h>

#include <rosidl_runtime_c/message_type_support_struct.h>
#include <rosidl_runtime_c/primitives_sequence.h>
#include <rosidl_runtime_c/primitives_sequence_functions.h>
#include <rosidl_runtime_c/string.h>
#include <rosidl_runtime_c/string_functions.h>

#include <geometry_msgs/msg/detail/vector3__functions.h>
#include <geometry_msgs/msg/detail/vector3__struct.h>

#include <geometry_msgs/msg/detail/twist__functions.h>
#include <geometry_msgs/msg/detail/twist__struct.h>
#include <geometry_msgs/msg/detail/twist__type_support.h>

#include <stddef.h>
#include <stdint.h>
#include <string.h>

ERL_NIF_TERM nif_geometry_msgs_msg_twist_type_support(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p = ROSIDL_GET_MSG_TYPE_SUPPORT(geometry_msgs, msg, Twist);
  rosidl_message_type_support_t *obj = enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_geometry_msgs_msg_twist_create(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  geometry_msgs__msg__Twist *message_p = geometry_msgs__msg__Twist__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_geometry_msgs_msg_twist_destroy(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  geometry_msgs__msg__Twist *message_p = (geometry_msgs__msg__Twist *)*ros_message_pp;
  geometry_msgs__msg__Twist__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_geometry_msgs_msg_twist_set(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  geometry_msgs__msg__Twist *message_p = (geometry_msgs__msg__Twist *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  int linear_arity;
  const ERL_NIF_TERM *linear_tuple;
  if (!enif_get_tuple(env, tuple[0], &linear_arity, &linear_tuple))
    return enif_make_badarg(env);

  double linear_x;
  if (!enif_get_double(env, linear_tuple[0], &linear_x))
    return enif_make_badarg(env);
  message_p->linear.x = linear_x;

  double linear_y;
  if (!enif_get_double(env, linear_tuple[1], &linear_y))
    return enif_make_badarg(env);
  message_p->linear.y = linear_y;

  double linear_z;
  if (!enif_get_double(env, linear_tuple[2], &linear_z))
    return enif_make_badarg(env);
  message_p->linear.z = linear_z;

  int angular_arity;
  const ERL_NIF_TERM *angular_tuple;
  if (!enif_get_tuple(env, tuple[1], &angular_arity, &angular_tuple))
    return enif_make_badarg(env);

  double angular_x;
  if (!enif_get_double(env, angular_tuple[0], &angular_x))
    return enif_make_badarg(env);
  message_p->angular.x = angular_x;

  double angular_y;
  if (!enif_get_double(env, angular_tuple[1], &angular_y))
    return enif_make_badarg(env);
  message_p->angular.y = angular_y;

  double angular_z;
  if (!enif_get_double(env, angular_tuple[2], &angular_z))
    return enif_make_badarg(env);
  message_p->angular.z = angular_z;

  return atom_ok;
}

ERL_NIF_TERM nif_geometry_msgs_msg_twist_get(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  geometry_msgs__msg__Twist *message_p = (geometry_msgs__msg__Twist *)*ros_message_pp;

  ERL_NIF_TERM term;
  term = enif_make_tuple(env, 2,
    enif_make_tuple(env, 3,
      enif_make_double(env, message_p->linear.x),
      enif_make_double(env, message_p->linear.y),
      enif_make_double(env, message_p->linear.z)
    ),
    enif_make_tuple(env, 3,
      enif_make_double(env, message_p->angular.x),
      enif_make_double(env, message_p->angular.y),
      enif_make_double(env, message_p->angular.z)
    )
  );

  return term;
}
// clang-format on
