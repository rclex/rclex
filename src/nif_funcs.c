#include "macros.h"
#include "pkgs/builtin_interfaces/msg/time.h"
#include "pkgs/geometry_msgs/msg/point32.h"
#include "pkgs/geometry_msgs/msg/twist.h"
#include "pkgs/geometry_msgs/msg/vector3.h"
#include "pkgs/sensor_msgs/msg/channel_float32.h"
#include "pkgs/sensor_msgs/msg/point_cloud.h"
#include "pkgs/std_msgs/msg/header.h"
#include "pkgs/std_msgs/msg/multi_array_dimension.h"
#include "pkgs/std_msgs/msg/multi_array_layout.h"
#include "pkgs/std_msgs/msg/string.h"
#include "pkgs/std_msgs/msg/u_int32_multi_array.h"
#include "rcl_init.h"
#include "rcl_node.h"
#include "rcl_publisher.h"
#include "rcl_subscription.h"
#include "rcl_wait.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <stddef.h>

#define REGULAR_NIF 0
/*
 if not regular nif, use ERL_NIF_DIRTY_JOB_CPU_BOUND or
 ERL_NIF_DIRTY_JOB_IO_BOUND ref.
 https://www.erlang.org/doc/man/erl_nif.html#ErlNifFunc
*/
static ErlNifFunc nif_funcs[] = {
    // clang-format off
    {"raise!", 0, nif_raise_for_test, REGULAR_NIF},
    {"raise_with_message!", 0, nif_raise_with_message_for_test, REGULAR_NIF},
    {"rcl_init!", 0, nif_rcl_init, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_fini!", 1, nif_rcl_fini, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_node_init!", 3, nif_rcl_node_init, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_node_fini!", 1, nif_rcl_node_fini, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_publisher_init!", 3, nif_rcl_publisher_init, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_publisher_fini!", 2, nif_rcl_publisher_fini, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_publish!", 2, nif_rcl_publish, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_subscription_init!", 3, nif_rcl_subscription_init, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_subscription_fini!", 2, nif_rcl_subscription_fini, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_take!", 2, nif_rcl_take, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_wait_set_init_subscription!", 1, nif_rcl_wait_set_init_subscription, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_wait_set_fini!", 1, nif_rcl_wait_set_fini, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"rcl_wait_subscription!", 3, nif_rcl_wait_subscription, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"builtin_interfaces_msg_time_type_support!", 0, nif_builtin_interfaces_msg_time_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"builtin_interfaces_msg_time_create!", 0, nif_builtin_interfaces_msg_time_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"builtin_interfaces_msg_time_destroy!", 1, nif_builtin_interfaces_msg_time_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"builtin_interfaces_msg_time_set!", 2, nif_builtin_interfaces_msg_time_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"builtin_interfaces_msg_time_get!", 1, nif_builtin_interfaces_msg_time_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_header_type_support!", 0, nif_std_msgs_msg_header_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_header_create!", 0, nif_std_msgs_msg_header_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_header_destroy!", 1, nif_std_msgs_msg_header_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_header_set!", 2, nif_std_msgs_msg_header_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_header_get!", 1, nif_std_msgs_msg_header_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_string_type_support!", 0, nif_std_msgs_msg_string_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_string_create!", 0, nif_std_msgs_msg_string_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_string_destroy!", 1, nif_std_msgs_msg_string_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_string_set!", 2, nif_std_msgs_msg_string_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_string_get!", 1, nif_std_msgs_msg_string_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_multi_array_dimension_type_support!", 0, nif_std_msgs_msg_multi_array_dimension_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_multi_array_dimension_create!", 0, nif_std_msgs_msg_multi_array_dimension_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_multi_array_dimension_destroy!", 1, nif_std_msgs_msg_multi_array_dimension_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_multi_array_dimension_set!", 2, nif_std_msgs_msg_multi_array_dimension_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_multi_array_dimension_get!", 1, nif_std_msgs_msg_multi_array_dimension_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_multi_array_layout_type_support!", 0, nif_std_msgs_msg_multi_array_layout_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_multi_array_layout_create!", 0, nif_std_msgs_msg_multi_array_layout_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_multi_array_layout_destroy!", 1, nif_std_msgs_msg_multi_array_layout_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_multi_array_layout_set!", 2, nif_std_msgs_msg_multi_array_layout_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_multi_array_layout_get!", 1, nif_std_msgs_msg_multi_array_layout_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_u_int32_multi_array_type_support!", 0, nif_std_msgs_msg_u_int32_multi_array_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_u_int32_multi_array_create!", 0, nif_std_msgs_msg_u_int32_multi_array_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_u_int32_multi_array_destroy!", 1, nif_std_msgs_msg_u_int32_multi_array_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_u_int32_multi_array_set!", 2, nif_std_msgs_msg_u_int32_multi_array_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_u_int32_multi_array_get!", 1, nif_std_msgs_msg_u_int32_multi_array_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_point32_type_support!", 0, nif_geometry_msgs_msg_point32_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_point32_create!", 0, nif_geometry_msgs_msg_point32_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_point32_destroy!", 1, nif_geometry_msgs_msg_point32_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_point32_set!", 2, nif_geometry_msgs_msg_point32_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_point32_get!", 1, nif_geometry_msgs_msg_point32_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_vector3_type_support!", 0, nif_geometry_msgs_msg_vector3_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_vector3_create!", 0, nif_geometry_msgs_msg_vector3_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_vector3_destroy!", 1, nif_geometry_msgs_msg_vector3_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_vector3_set!", 2, nif_geometry_msgs_msg_vector3_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_vector3_get!", 1, nif_geometry_msgs_msg_vector3_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_twist_type_support!", 0, nif_geometry_msgs_msg_twist_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_twist_create!", 0, nif_geometry_msgs_msg_twist_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_twist_destroy!", 1, nif_geometry_msgs_msg_twist_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_twist_set!", 2, nif_geometry_msgs_msg_twist_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"geometry_msgs_msg_twist_get!", 1, nif_geometry_msgs_msg_twist_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"sensor_msgs_msg_channel_float32_type_support!", 0, nif_sensor_msgs_msg_channel_float32_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"sensor_msgs_msg_channel_float32_create!", 0, nif_sensor_msgs_msg_channel_float32_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"sensor_msgs_msg_channel_float32_destroy!", 1, nif_sensor_msgs_msg_channel_float32_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"sensor_msgs_msg_channel_float32_set!", 2, nif_sensor_msgs_msg_channel_float32_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"sensor_msgs_msg_channel_float32_get!", 1, nif_sensor_msgs_msg_channel_float32_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"sensor_msgs_msg_point_cloud_type_support!", 0, nif_sensor_msgs_msg_point_cloud_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"sensor_msgs_msg_point_cloud_create!", 0, nif_sensor_msgs_msg_point_cloud_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"sensor_msgs_msg_point_cloud_destroy!", 1, nif_sensor_msgs_msg_point_cloud_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"sensor_msgs_msg_point_cloud_set!", 2, nif_sensor_msgs_msg_point_cloud_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"sensor_msgs_msg_point_cloud_get!", 1, nif_sensor_msgs_msg_point_cloud_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
    // clang-format on
};

static int load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info) {
  ignore_unused(priv_data);
  ignore_unused(load_info);

  make_atoms(env);
  if (open_resource_types(env, "Elixir.Rclex.Nif") != 0) return 1;

  return 0;
}

ERL_NIF_INIT(Elixir.Rclex.Nif, nif_funcs, load, NULL, NULL, NULL)
