// clang-format off
#include "point_cloud.h"
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

#include <geometry_msgs/msg/detail/point32__functions.h>
#include <geometry_msgs/msg/detail/point32__struct.h>

#include <sensor_msgs/msg/detail/channel_float32__functions.h>
#include <sensor_msgs/msg/detail/channel_float32__struct.h>

#include <std_msgs/msg/detail/header__functions.h>
#include <std_msgs/msg/detail/header__struct.h>

#include <sensor_msgs/msg/detail/point_cloud__functions.h>
#include <sensor_msgs/msg/detail/point_cloud__struct.h>
#include <sensor_msgs/msg/detail/point_cloud__type_support.h>

#include <stddef.h>
#include <stdint.h>
#include <string.h>

ERL_NIF_TERM nif_sensor_msgs_msg_point_cloud_type_support(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  const rosidl_message_type_support_t *ts_p = ROSIDL_GET_MSG_TYPE_SUPPORT(sensor_msgs, msg, PointCloud);
  rosidl_message_type_support_t *obj = enif_alloc_resource(rt_rosidl_message_type_support_t, sizeof(rosidl_message_type_support_t));
  *obj = *ts_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_sensor_msgs_msg_point_cloud_create(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  sensor_msgs__msg__PointCloud *message_p = sensor_msgs__msg__PointCloud__create();
  if (message_p == NULL) return raise(env, __FILE__, __LINE__);

  void **obj = enif_alloc_resource(rt_ros_message, sizeof(void *));
  *obj = (void *)message_p;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_sensor_msgs_msg_point_cloud_destroy(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  sensor_msgs__msg__PointCloud *message_p = (sensor_msgs__msg__PointCloud *)*ros_message_pp;
  sensor_msgs__msg__PointCloud__destroy(message_p);

  return atom_ok;
}

ERL_NIF_TERM nif_sensor_msgs_msg_point_cloud_set(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  sensor_msgs__msg__PointCloud *message_p = (sensor_msgs__msg__PointCloud *)*ros_message_pp;

  int arity;
  const ERL_NIF_TERM *tuple;
  if (!enif_get_tuple(env, argv[1], &arity, &tuple)) return enif_make_badarg(env);

  int header_arity;
  const ERL_NIF_TERM *header_tuple;
  if (!enif_get_tuple(env, tuple[0], &header_arity, &header_tuple))
    return enif_make_badarg(env);

  int header_stamp_arity;
  const ERL_NIF_TERM *header_stamp_tuple;
  if (!enif_get_tuple(env, header_tuple[0], &header_stamp_arity, &header_stamp_tuple))
    return enif_make_badarg(env);

  int header_stamp_sec;
  if (!enif_get_int(env, header_stamp_tuple[0], &header_stamp_sec))
    return enif_make_badarg(env);
  message_p->header.stamp.sec = header_stamp_sec;

  unsigned int header_stamp_nanosec;
  if (!enif_get_uint(env, header_stamp_tuple[1], &header_stamp_nanosec))
    return enif_make_badarg(env);
  message_p->header.stamp.nanosec = header_stamp_nanosec;

  unsigned int header_frame_id_length;
#if (ERL_NIF_MAJOR_VERSION == 2 && ERL_NIF_MINOR_VERSION >= 17) // OTP-26 and later
  if (!enif_get_string_length(env, header_tuple[1], &header_frame_id_length, ERL_NIF_LATIN1))
    return enif_make_badarg(env);
#else
  if (!enif_get_list_length(env, header_tuple[1], &header_frame_id_length))
    return enif_make_badarg(env);
#endif

  char header_frame_id[header_frame_id_length + 1];
  if (enif_get_string(env, header_tuple[1], header_frame_id, header_frame_id_length + 1, ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);

  if (!rosidl_runtime_c__String__assign(&(message_p->header.frame_id), header_frame_id))
    return raise(env, __FILE__, __LINE__);

  unsigned int points_length;
  if (!enif_get_list_length(env, tuple[1], &points_length))
    return enif_make_badarg(env);

  geometry_msgs__msg__Point32__Sequence *points = geometry_msgs__msg__Point32__Sequence__create(points_length);
  if (points == NULL) return raise(env, __FILE__, __LINE__);
  message_p->points = *points;

  unsigned int points_i;
  ERL_NIF_TERM points_left, points_head, points_tail;
  for (points_i = 0, points_left = tuple[1]; points_i < points_length; ++points_i, points_left = points_tail)
  {
    if (!enif_get_list_cell(env, points_left, &points_head, &points_tail))
      return enif_make_badarg(env);

    int points_i_arity;
    const ERL_NIF_TERM *points_i_tuple;
    if (!enif_get_tuple(env, points_head, &points_i_arity, &points_i_tuple))
      return enif_make_badarg(env);

    double points_i_x;
    if (!enif_get_double(env, points_i_tuple[0], &points_i_x))
      return enif_make_badarg(env);
    message_p->points.data[points_i].x = (float)points_i_x;

    double points_i_y;
    if (!enif_get_double(env, points_i_tuple[1], &points_i_y))
      return enif_make_badarg(env);
    message_p->points.data[points_i].y = (float)points_i_y;

    double points_i_z;
    if (!enif_get_double(env, points_i_tuple[2], &points_i_z))
      return enif_make_badarg(env);
    message_p->points.data[points_i].z = (float)points_i_z;
  }

  unsigned int channels_length;
  if (!enif_get_list_length(env, tuple[2], &channels_length))
    return enif_make_badarg(env);

  sensor_msgs__msg__ChannelFloat32__Sequence *channels = sensor_msgs__msg__ChannelFloat32__Sequence__create(channels_length);
  if (channels == NULL) return raise(env, __FILE__, __LINE__);
  message_p->channels = *channels;

  unsigned int channels_i;
  ERL_NIF_TERM channels_left, channels_head, channels_tail;
  for (channels_i = 0, channels_left = tuple[2]; channels_i < channels_length; ++channels_i, channels_left = channels_tail)
  {
    if (!enif_get_list_cell(env, channels_left, &channels_head, &channels_tail))
      return enif_make_badarg(env);

    int channels_i_arity;
    const ERL_NIF_TERM *channels_i_tuple;
    if (!enif_get_tuple(env, channels_head, &channels_i_arity, &channels_i_tuple))
      return enif_make_badarg(env);

    unsigned int channels_i_name_length;
#if (ERL_NIF_MAJOR_VERSION == 2 && ERL_NIF_MINOR_VERSION >= 17) // OTP-26 and later
    if (!enif_get_string_length(env, channels_i_tuple[0], &channels_i_name_length, ERL_NIF_LATIN1))
      return enif_make_badarg(env);
#else
    if (!enif_get_list_length(env, channels_i_tuple[0], &channels_i_name_length))
      return enif_make_badarg(env);
#endif

    char channels_i_name[channels_i_name_length + 1];
    if (enif_get_string(env, channels_i_tuple[0], channels_i_name, channels_i_name_length + 1, ERL_NIF_LATIN1) <= 0)
      return enif_make_badarg(env);

    if (!rosidl_runtime_c__String__assign(&(message_p->channels.data[channels_i].name), channels_i_name))
      return raise(env, __FILE__, __LINE__);

    unsigned int channels_i_values_length;
    if (!enif_get_list_length(env, channels_i_tuple[1], &channels_i_values_length))
      return enif_make_badarg(env);

    rosidl_runtime_c__float32__Sequence channels_i_values;
    if(!rosidl_runtime_c__float32__Sequence__init(&channels_i_values, channels_i_values_length))
      return enif_make_badarg(env);
    message_p->channels.data[channels_i].values = channels_i_values;

    unsigned int channels_i_values_i;
    ERL_NIF_TERM channels_i_values_left, channels_i_values_head, channels_i_values_tail;
    for (channels_i_values_i = 0, channels_i_values_left = channels_i_tuple[1]; channels_i_values_i < channels_i_values_length; ++channels_i_values_i, channels_i_values_left = channels_i_values_tail)
    {
      if (!enif_get_list_cell(env, channels_i_values_left, &channels_i_values_head, &channels_i_values_tail))
        return enif_make_badarg(env);

      double channels_i_values_float32;
      if (!enif_get_double(env, channels_i_values_head, &channels_i_values_float32))
        return enif_make_badarg(env);
      message_p->channels.data[channels_i].values.data[channels_i_values_i] = (float)channels_i_values_float32;
    }
  }

  return atom_ok;
}

ERL_NIF_TERM nif_sensor_msgs_msg_point_cloud_get(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  void **ros_message_pp;
  if (!enif_get_resource(env, argv[0], rt_ros_message, (void **)&ros_message_pp))
    return enif_make_badarg(env);

  sensor_msgs__msg__PointCloud *message_p = (sensor_msgs__msg__PointCloud *)*ros_message_pp;

  ERL_NIF_TERM points[message_p->points.size];

  for (size_t points_i = 0; points_i < message_p->points.size; ++points_i)
  {
    points[points_i] = enif_make_tuple(env, 3,
      enif_make_double(env, message_p->points.data[points_i].x),
      enif_make_double(env, message_p->points.data[points_i].y),
      enif_make_double(env, message_p->points.data[points_i].z)
    );
  }

  ERL_NIF_TERM channels[message_p->channels.size];

  for (size_t channels_i = 0; channels_i < message_p->channels.size; ++channels_i)
  {
    ERL_NIF_TERM channels_values[message_p->channels.data[channels_i].values.size];

    for (size_t channels_values_i = 0; channels_values_i < message_p->channels.data[channels_i].values.size; ++channels_values_i)
    {
      channels_values[channels_values_i] = enif_make_double(env, message_p->channels.data[channels_i].values.data[channels_values_i]);
    }

    channels[channels_i] = enif_make_tuple(env, 2,
      enif_make_string(env, message_p->channels.data[channels_i].name.data, ERL_NIF_LATIN1),
      enif_make_list_from_array(env, channels_values, message_p->channels.data[channels_i].values.size)
    );
  }

  return enif_make_tuple(env, 3,
    enif_make_tuple(env, 2,
      enif_make_tuple(env, 2,
        enif_make_int(env, message_p->header.stamp.sec),
        enif_make_uint(env, message_p->header.stamp.nanosec)
      ),
      enif_make_string(env, message_p->header.frame_id.data, ERL_NIF_LATIN1)
    ),
    enif_make_list_from_array(env, points, message_p->points.size),
    enif_make_list_from_array(env, channels, message_p->channels.size)
  );
}
// clang-format on
