#include "macros.h"
#include "msg_funcs.h" // IWYU pragma: keep
#include "qos.h"
#include "rcl_clock.h"
#include "rcl_init.h"
#include "rcl_node.h"
#include "rcl_publisher.h"
#include "rcl_subscription.h"
#include "rcl_timer.h"
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
#define nif_io_bound_func(name, arity)                                                             \
  { #name "!", arity, nif_##name, ERL_NIF_DIRTY_JOB_IO_BOUND }

#define nif_regular_func(name, arity)                                                              \
  { #name "!", arity, nif_##name, REGULAR_NIF }

static ErlNifFunc nif_funcs[] = {
    // clang-format off
    {"raise!", 0, nif_raise_for_test, REGULAR_NIF},
    {"raise_with_message!", 0, nif_raise_with_message_for_test, REGULAR_NIF},
    {"test_qos_profile!", 1, nif_test_qos_profile, REGULAR_NIF},
    nif_io_bound_func(rcl_init, 0),
    nif_io_bound_func(rcl_fini, 1),
    nif_io_bound_func(rcl_node_init, 3),
    nif_io_bound_func(rcl_node_fini, 1),
    nif_io_bound_func(rcl_publisher_init, 4),
    nif_io_bound_func(rcl_publisher_fini, 2),
    nif_io_bound_func(rcl_publish, 2),
    nif_io_bound_func(rcl_subscription_init, 4),
    nif_io_bound_func(rcl_subscription_fini, 2),
    nif_io_bound_func(rcl_take, 2),
    nif_io_bound_func(rcl_clock_init, 0),
    nif_io_bound_func(rcl_clock_fini, 1),
    nif_io_bound_func(rcl_timer_init, 3),
    nif_io_bound_func(rcl_timer_fini, 1),
    nif_io_bound_func(rcl_timer_is_ready, 1),
    nif_io_bound_func(rcl_timer_call, 1),
    nif_io_bound_func(rcl_wait_set_init_subscription, 1),
    nif_io_bound_func(rcl_wait_set_init_timer, 1),
    nif_io_bound_func(rcl_wait_set_fini, 1),
    nif_io_bound_func(rcl_wait_subscription, 3),
    nif_io_bound_func(rcl_wait_timer, 3),
    nif_regular_func(rmw_qos_profile_sensor_data, 0),
    nif_regular_func(rmw_qos_profile_parameters, 0),
    nif_regular_func(rmw_qos_profile_default, 0),
    nif_regular_func(rmw_qos_profile_services_default, 0),
    nif_regular_func(rmw_qos_profile_parameter_events, 0),
    nif_regular_func(rmw_qos_profile_system_default, 0),
#include "msg_funcs.ec" // IWYU pragma: keep
    // clang-format on
};

static int load(ErlNifEnv *env, void **priv_data, ERL_NIF_TERM load_info) {
  ignore_unused(priv_data);
  ignore_unused(load_info);

  make_common_atoms(env);
  make_qos_atoms(env);
  if (open_resource_types(env, "Elixir.Rclex.Nif") != 0) return 1;

  return 0;
}

static int upgrade(ErlNifEnv *env, void **priv_data, void **old_priv_data, ERL_NIF_TERM load_info) {
  ignore_unused(old_priv_data);

  return load(env, priv_data, load_info);
}

ERL_NIF_INIT(Elixir.Rclex.Nif, nif_funcs, load, NULL, upgrade, NULL)
