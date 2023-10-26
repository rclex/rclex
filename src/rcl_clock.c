#include "rcl_clock.h"
#include "macros.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/allocator.h>
#include <rcl/time.h>
#include <rcl/types.h>

ERL_NIF_TERM nif_rcl_clock_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argc);
  ignore_unused(argv);

  rcl_ret_t rc;
  rcl_clock_t clock;
  rcl_allocator_t allocator = rcl_get_default_allocator();

  rc = rcl_clock_init(RCL_STEADY_TIME, &clock, &allocator);
  if (rc != RCL_RET_OK) return enif_make_badarg(env);

  if (!rcl_clock_time_started(&clock)) return raise(env, __FILE__, __LINE__);

  rcl_clock_t *obj  = enif_alloc_resource(rt_rcl_clock_t, sizeof(rcl_clock_t));
  *obj              = clock;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_clock_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_clock_t *clock_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_clock_t, (void **)&clock_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_clock_fini(clock_p);
  if (rc != RCL_RET_OK) return enif_make_badarg(env);

  return atom_ok;
}
