#include <erl_nif.h>

extern ErlNifResourceType *rt_rcl_context_t;
extern ErlNifResourceType *rt_rcl_node_t;
extern ErlNifResourceType *rt_rcl_publisher_t;
extern ErlNifResourceType *rt_rcl_subscription_t;
extern ErlNifResourceType *rt_rcl_client_t;
extern ErlNifResourceType *rt_rcl_service_t;
extern ErlNifResourceType *rt_rcl_clock_t;
extern ErlNifResourceType *rt_rcl_timer_t;
extern ErlNifResourceType *rt_rcl_wait_set_t;
extern ErlNifResourceType *rt_rosidl_message_type_support_t;
extern ErlNifResourceType *rt_rosidl_service_type_support_t;
extern ErlNifResourceType *rt_rmw_service_info_t;
extern ErlNifResourceType *rt_ros_message;
extern ErlNifResourceType *rt_subscription_callback_resource;
extern ErlNifResourceType *rt_service_callback_resource;
extern ErlNifResourceType *rt_client_callback_resource;

extern int open_resource_types(ErlNifEnv *env, const char *module);
