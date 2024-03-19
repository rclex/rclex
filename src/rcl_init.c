#include "rcl_init.h"
#include "allocator.h"
#include "macros.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/allocator.h>
#include <rcl/context.h>
#include <rcl/init.h>
#include <rcl/init_options.h>
#include <rcl/types.h>
#include <stddef.h>

ERL_NIF_TERM nif_rcl_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argv);

  if (argc != 0) return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_init_options_t init_options = rcl_get_zero_initialized_init_options();
  rcl_allocator_t allocator       = get_nif_allocator();
  rcl_context_t context           = rcl_get_zero_initialized_context();

  rc = rcl_init_options_init(&init_options, allocator);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rc = rcl_init(0, NULL, &init_options, &context);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rc = rcl_init_options_fini(&init_options);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rcl_context_t *obj = enif_alloc_resource(rt_rcl_context_t, sizeof(rcl_context_t));
  *obj               = context;
  ERL_NIF_TERM term  = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_context_t *context_p;

  if (!enif_get_resource(env, argv[0], rt_rcl_context_t, (void **)&context_p))
    return enif_make_badarg(env);
  if (!rcl_context_is_valid(context_p)) return raise(env, __FILE__, __LINE__);

  rc = rcl_shutdown(context_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rc = rcl_context_fini(context_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}
