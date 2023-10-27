#include "resource_types.h"
#include <erl_nif.h>
#include <stddef.h>

ErlNifResourceType *rt_rcl_context_t;
ErlNifResourceType *rt_rcl_node_t;
ErlNifResourceType *rt_rcl_publisher_t;
ErlNifResourceType *rt_rcl_subscription_t;
ErlNifResourceType *rt_rcl_clock_t;
ErlNifResourceType *rt_rcl_timer_t;
ErlNifResourceType *rt_rcl_wait_set_t;
ErlNifResourceType *rt_rosidl_message_type_support_t;
ErlNifResourceType *rt_ros_message;

int open_resource_types(ErlNifEnv *env, const char *module) {
  ErlNifResourceFlags flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;

  rt_rcl_context_t = enif_open_resource_type(env, module, "rcl_context_t", NULL, flags, NULL);
  if (rt_rcl_context_t == NULL) return 1;

  rt_rcl_node_t = enif_open_resource_type(env, module, "rcl_node_t", NULL, flags, NULL);
  if (rt_rcl_node_t == NULL) return 1;

  rt_rcl_publisher_t = enif_open_resource_type(env, module, "rcl_publisher_t", NULL, flags, NULL);
  if (rt_rcl_publisher_t == NULL) return 1;

  rt_rcl_subscription_t =
      enif_open_resource_type(env, module, "rcl_subscription_t", NULL, flags, NULL);
  if (rt_rcl_subscription_t == NULL) return 1;

  rt_rcl_clock_t = enif_open_resource_type(env, module, "rcl_clock_t", NULL, flags, NULL);
  if (rt_rcl_clock_t == NULL) return 1;

  rt_rcl_timer_t = enif_open_resource_type(env, module, "rcl_timer_t", NULL, flags, NULL);
  if (rt_rcl_timer_t == NULL) return 1;

  rt_rcl_wait_set_t = enif_open_resource_type(env, module, "rcl_wait_set_t", NULL, flags, NULL);
  if (rt_rcl_wait_set_t == NULL) return 1;

  rt_rosidl_message_type_support_t =
      enif_open_resource_type(env, module, "rosidl_message_type_support_t", NULL, flags, NULL);
  if (rt_rosidl_message_type_support_t == NULL) return 1;

  rt_ros_message = enif_open_resource_type(env, module, "ros_message", NULL, flags, NULL);
  if (rt_ros_message == NULL) return 1;

  return 0;
}
