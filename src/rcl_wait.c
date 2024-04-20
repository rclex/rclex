#include "rcl_wait.h"
#include "allocator.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/allocator.h>
#include <rcl/context.h>
#include <rcl/subscription.h>
#include <rcl/time.h>
#include <rcl/timer.h>
#include <rcl/types.h>
#include <rcl/wait.h>
#include <stddef.h>

ERL_NIF_TERM nif_rcl_wait_set_init_subscription(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_context_t *context_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_context_t, (void **)&context_p))
    return enif_make_badarg(env);
  if (!rcl_context_is_valid(context_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rcl_wait_set_t wait_set   = rcl_get_zero_initialized_wait_set();
  rcl_allocator_t allocator = get_nif_allocator();

  rc = rcl_wait_set_init(&wait_set, 1, 0, 0, 0, 0, 0, context_p, allocator);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rcl_wait_set_t *obj = enif_alloc_resource(rt_rcl_wait_set_t, sizeof(rcl_wait_set_t));
  *obj                = wait_set;
  ERL_NIF_TERM term   = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_wait_set_init_timer(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_context_t *context_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_context_t, (void **)&context_p))
    return enif_make_badarg(env);
  if (!rcl_context_is_valid(context_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;
  rcl_wait_set_t wait_set   = rcl_get_zero_initialized_wait_set();
  rcl_allocator_t allocator = get_nif_allocator();

  rc = rcl_wait_set_init(&wait_set, 0, 0, 1, 0, 0, 0, context_p, allocator);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rcl_wait_set_t *obj = enif_alloc_resource(rt_rcl_wait_set_t, sizeof(rcl_wait_set_t));
  *obj                = wait_set;
  ERL_NIF_TERM term   = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_wait_set_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_wait_set_t *wait_set_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_wait_set_t, (void **)&wait_set_p))
    return enif_make_badarg(env);
  if (!rcl_wait_set_is_valid(wait_set_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;

  rc = rcl_wait_set_fini(wait_set_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_wait_subscription(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_wait_set_t *wait_set_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_wait_set_t, (void **)&wait_set_p))
    return enif_make_badarg(env);
  if (!rcl_wait_set_is_valid(wait_set_p)) return raise(env, __FILE__, __LINE__);

  int timeout_us;
  if (!enif_get_int(env, argv[1], &timeout_us)) return enif_make_badarg(env);
  if (timeout_us > 1000)
    return raise_with_message(env, __FILE__, __LINE__, "1000us over is too long for nif.");

  rcl_subscription_t *subscription_p;
  if (!enif_get_resource(env, argv[2], rt_rcl_subscription_t, (void **)&subscription_p))
    return enif_make_badarg(env);
  if (!rcl_subscription_is_valid(subscription_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;

  rc = rcl_wait_set_clear(wait_set_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rc = rcl_wait_set_add_subscription(wait_set_p, subscription_p, NULL);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rc = rcl_wait(wait_set_p, RCL_US_TO_NS(timeout_us));
  if (rc == RCL_RET_OK) return atom_ok;
  if (rc == RCL_RET_TIMEOUT) return enif_make_atom(env, "timeout");
  return raise(env, __FILE__, __LINE__);
}

ERL_NIF_TERM nif_rcl_wait_timer(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_wait_set_t *wait_set_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_wait_set_t, (void **)&wait_set_p))
    return enif_make_badarg(env);
  if (!rcl_wait_set_is_valid(wait_set_p)) return raise(env, __FILE__, __LINE__);

  int timeout_us;
  if (!enif_get_int(env, argv[1], &timeout_us)) return enif_make_badarg(env);
  if (timeout_us > 1000)
    return raise_with_message(env, __FILE__, __LINE__, "1000us over is too long for nif.");

  rcl_timer_t *timer_p;
  if (!enif_get_resource(env, argv[2], rt_rcl_timer_t, (void **)&timer_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;

  rc = rcl_wait_set_clear(wait_set_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rc = rcl_wait_set_add_timer(wait_set_p, timer_p, NULL);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rc = rcl_wait(wait_set_p, RCL_US_TO_NS(timeout_us));
  if (rc == RCL_RET_OK) return atom_ok;
  if (rc == RCL_RET_TIMEOUT) return enif_make_atom(env, "timeout");
  return raise(env, __FILE__, __LINE__);
}
