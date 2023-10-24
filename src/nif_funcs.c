#include "macros.h"
#include "msg_funcs.h"
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
#include "msg_funcs.ec"
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
