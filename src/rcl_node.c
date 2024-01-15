#include "rcl_node.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/context.h>
#include <rcl/node.h>
#include <rcl/node_options.h>
#include <rcl/types.h>
#include <rmw/ret_types.h>
#include <rmw/validate_namespace.h>
#include <rmw/validate_node_name.h>
#include <stddef.h>

ERL_NIF_TERM nif_rcl_node_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 3) return enif_make_badarg(env);

  rcl_context_t *context_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_context_t, (void **)&context_p))
    return enif_make_badarg(env);
  if (!rcl_context_is_valid(context_p)) return raise(env, __FILE__, __LINE__);

  rmw_ret_t rm;
  int validation_result;

  char name[256];
  if (enif_get_string(env, argv[1], name, sizeof(name), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);
  rm = rmw_validate_node_name(name, &validation_result, NULL);
  if (rm != RMW_RET_OK) return raise(env, __FILE__, __LINE__);
  if (validation_result != RMW_NODE_NAME_VALID) {
    const char *message = rmw_node_name_validation_result_string(validation_result);
    return raise_with_message(env, __FILE__, __LINE__, message);
  }

  char namespace[256];
  if (enif_get_string(env, argv[2], namespace, sizeof(namespace), ERL_NIF_LATIN1) <= 0)
    return enif_make_badarg(env);
  rm = rmw_validate_namespace(namespace, &validation_result, NULL);
  if (rm != RMW_RET_OK) return raise(env, __FILE__, __LINE__);
  if (validation_result != RMW_NAMESPACE_VALID) {
    const char *message = rmw_namespace_validation_result_string(validation_result);
    return raise_with_message(env, __FILE__, __LINE__, message);
  }

  rcl_ret_t rc;
  rcl_node_t node                 = rcl_get_zero_initialized_node();
  rcl_node_options_t node_options = rcl_node_get_default_options();
  node_options.allocator          = get_nif_allocator();

  rc = rcl_node_init(&node, name, namespace, context_p, &node_options);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rc = rcl_node_options_fini(&node_options);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  rcl_node_t *obj   = enif_alloc_resource(rt_rcl_node_t, sizeof(rcl_node_t));
  *obj              = node;
  ERL_NIF_TERM term = enif_make_resource(env, obj);
  enif_release_resource(obj);

  return term;
}

ERL_NIF_TERM nif_rcl_node_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_node_t *node_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_node_t, (void **)&node_p))
    return enif_make_badarg(env);
  if (!rcl_node_is_valid(node_p)) return raise(env, __FILE__, __LINE__);

  rcl_ret_t rc;

  rc = rcl_node_fini(node_p);
  if (rc != RCL_RET_OK) return raise(env, __FILE__, __LINE__);

  return atom_ok;
}
