#include "macros.h"
#include "pkgs/geometry_msgs/msg/twist.h"
#include "pkgs/geometry_msgs/msg/vector3.h"
#include "pkgs/std_msgs/msg/string.h"
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
    {"std_msgs_msg_string_type_support!", 0, nif_std_msgs_msg_string_type_support, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_string_create!", 0, nif_std_msgs_msg_string_create, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_string_destroy!", 1, nif_std_msgs_msg_string_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_string_set!", 2, nif_std_msgs_msg_string_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
    {"std_msgs_msg_string_get!", 1, nif_std_msgs_msg_string_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
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
