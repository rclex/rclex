#include "resource_types.h"
#include <erl_nif.h>
#include <stddef.h>

ErlNifResourceType *rt_rcl_context_t;
ErlNifResourceType *rt_rcl_node_t;
ErlNifResourceType *rt_rcl_publisher_t;
ErlNifResourceType *rt_rcl_subscription_t;
ErlNifResourceType *rt_rcl_client_t;
ErlNifResourceType *rt_rcl_service_t;
ErlNifResourceType *rt_rcl_clock_t;
ErlNifResourceType *rt_rcl_timer_t;
ErlNifResourceType *rt_rcl_wait_set_t;
ErlNifResourceType *rt_rosidl_message_type_support_t;
ErlNifResourceType *rt_rosidl_service_type_support_t;
ErlNifResourceType *rt_rmw_service_info_t;
ErlNifResourceType *rt_ros_message;
ErlNifResourceType *rt_subscription_callback_resource;
ErlNifResourceType *rt_service_callback_resource;
ErlNifResourceType *rt_client_callback_resource;

#define open_rt_return_if_error(env, module, name, flags)                                          \
  rt_##name = enif_open_resource_type(env, module, #name, NULL, flags, NULL);                      \
  if (rt_##name == NULL) return 1;

int open_resource_types(ErlNifEnv *env, const char *module) {
  ErlNifResourceFlags flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;

  open_rt_return_if_error(env, module, rcl_context_t, flags);
  open_rt_return_if_error(env, module, rcl_node_t, flags);
  open_rt_return_if_error(env, module, rcl_publisher_t, flags);
  open_rt_return_if_error(env, module, rcl_subscription_t, flags);
  open_rt_return_if_error(env, module, rcl_client_t, flags);
  open_rt_return_if_error(env, module, rcl_service_t, flags);
  open_rt_return_if_error(env, module, rcl_clock_t, flags);
  open_rt_return_if_error(env, module, rcl_timer_t, flags);
  open_rt_return_if_error(env, module, rcl_wait_set_t, flags);
  open_rt_return_if_error(env, module, rosidl_message_type_support_t, flags);
  open_rt_return_if_error(env, module, rosidl_service_type_support_t, flags);
  open_rt_return_if_error(env, module, rmw_service_info_t, flags);
  open_rt_return_if_error(env, module, ros_message, flags);
  open_rt_return_if_error(env, module, subscription_callback_resource, flags);
  open_rt_return_if_error(env, module, service_callback_resource, flags);
  open_rt_return_if_error(env, module, client_callback_resource, flags);

  return 0;
}
