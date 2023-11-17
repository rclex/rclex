#include "rcl_timer.h"
#include "allocator.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/allocator.h>
#include <rcl/context.h>
#include <rcl/time.h>
#include <rcl/timer.h>
#include <rcl/types.h>
#include <stdbool.h>
#include <stddef.h>

ERL_NIF_TERM nif_rcl_timer_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_context_t *context_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_context_t, (void **)&context_p))
    return enif_make_badarg(env);
  if (!rcl_context_is_valid(context_p)) return raise(env, __FILE__, __LINE__);

  rcl_clock_t *clock_p;
  if (!enif_get_resource(env, argv[1], rt_rcl_clock_t, (void **)&clock_p))
    return enif_make_badarg(env);
  if (!rcl_clock_valid(clock_p)) return raise(env, __FILE__, __LINE__);

  int period_ms;
  if (!enif_get_int(env, argv[2], &period_ms)) return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_timer_t timer = rcl_get_zero_initialized_timer();

  rc = rcl_timer_init(&timer, clock_p, context_p, RCL_MS_TO_NS(period_ms), NULL,
                      get_nif_allocator());
  if (rc != RCL_RET_OK) return enif_make_badarg(env);

  rcl_timer_t *obj  = enif_alloc_resource(rt_rcl_timer_t, sizeof(rcl_timer_t));
  *obj              = timer;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_timer_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_timer_t *timer_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_timer_t, (void **)&timer_p))
    return enif_make_badarg(env);

  rc = rcl_timer_fini(timer_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_timer_is_ready(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_timer_t *timer_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_timer_t, (void **)&timer_p))
    return enif_make_badarg(env);

  bool is_ready;
  rc = rcl_timer_is_ready(timer_p, &is_ready);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return is_ready ? atom_true : atom_false;
}

ERL_NIF_TERM nif_rcl_timer_call(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_ret_t rc;

  rcl_timer_t *timer_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_timer_t, (void **)&timer_p))
    return enif_make_badarg(env);

  rc = rcl_timer_call(timer_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}
