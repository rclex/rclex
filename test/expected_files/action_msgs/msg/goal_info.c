// clang-format off
#include "goal_info.h"
#include "../../../macros.h"
#include "../../../resource_types.h"
#include "../../../terms.h"

#include <erl_nif.h>

#include <rosidl_runtime_c/message_type_support_struct.h>
#include <rosidl_runtime_c/primitives_sequence.h>
#include <rosidl_runtime_c/primitives_sequence_functions.h>
#include <rosidl_runtime_c/string.h>
#include <rosidl_runtime_c/string_functions.h>

#include <builtin_interfaces/msg/detail/time__functions.h>
#include <builtin_interfaces/msg/detail/time__struct.h>

#include <unique_identifier_msgs/msg/detail/uuid__functions.h>
#include <unique_identifier_msgs/msg/detail/uuid__struct.h>

#include <action_msgs/msg/detail/goal_info__functions.h>
#include <action_msgs/msg/detail/goal_info__struct.h>
#include <action_msgs/msg/detail/goal_info__type_support.h>

#include <stddef.h>
#include <stdint.h>
#include <string.h>

ERL_NIF_TERM nif_action_msgs_msg_goal_info_type_support(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p = ROSIDL_GET_MSG_TYPE_SUPPORT(action_msgs, msg, GoalInfo);
  rosidl_message_type_support_t *obj = enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_action_msgs_msg_goal_info_create(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  action_msgs__msg__GoalInfo *message_p = action_msgs__msg__GoalInfo__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_action_msgs_msg_goal_info_destroy(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  action_msgs__msg__GoalInfo *message_p = (action_msgs__msg__GoalInfo *)*ros_message_pp;
  action_msgs__msg__GoalInfo__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_action_msgs_msg_goal_info_set(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  action_msgs__msg__GoalInfo *message_p = (action_msgs__msg__GoalInfo *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  int goal_id_arity;
  const ERL_NIF_TERM *goal_id_tuple;
  if (!enif_get_tuple(env, tuple[0], &goal_id_arity, &goal_id_tuple))
    return enif_make_badarg(env);

  ErlNifBinary goal_id_uuid_bin;
  if(!enif_inspect_binary(env, goal_id_tuple[0], &goal_id_uuid_bin))
    return enif_make_badarg(env);

  unsigned int goal_id_uuid_length = goal_id_uuid_bin.size;
  if(goal_id_uuid_length > 16)
    return enif_make_badarg(env);

  memcpy(message_p->goal_id.uuid, goal_id_uuid_bin.data, goal_id_uuid_length);

  int stamp_arity;
  const ERL_NIF_TERM *stamp_tuple;
  if (!enif_get_tuple(env, tuple[1], &stamp_arity, &stamp_tuple))
    return enif_make_badarg(env);

  int stamp_sec;
  if (!enif_get_int(env, stamp_tuple[0], &stamp_sec))
    return enif_make_badarg(env);
  message_p->stamp.sec = stamp_sec;

  unsigned int stamp_nanosec;
  if (!enif_get_uint(env, stamp_tuple[1], &stamp_nanosec))
    return enif_make_badarg(env);
  message_p->stamp.nanosec = stamp_nanosec;

  return atom_ok;
}

ERL_NIF_TERM nif_action_msgs_msg_goal_info_get(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  action_msgs__msg__GoalInfo *message_p = (action_msgs__msg__GoalInfo *)*ros_message_pp;

  ErlNifBinary goal_id_uuid_bin;
  if(!enif_alloc_binary(16, &goal_id_uuid_bin))
    return raise(env, __FILE__, __LINE__);

  memcpy(goal_id_uuid_bin.data, message_p->goal_id.uuid, 16);
  ERL_NIF_TERM goal_id_uuid = enif_make_binary(env, &goal_id_uuid_bin);

  return enif_make_tuple(env, 2,
    enif_make_tuple(env, 1,
      goal_id_uuid
    ),
    enif_make_tuple(env, 2,
      enif_make_int(env, message_p->stamp.sec),
      enif_make_uint(env, message_p->stamp.nanosec)
    )
  );
}
// clang-format on
