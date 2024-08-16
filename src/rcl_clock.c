#include "rcl_clock.h"
#include "allocator.h"
#include "macros.h"
#include "resource_types.h"
#include "terms.h"
#include <erl_nif.h>
#include <rcl/allocator.h>
#include <rcl/time.h>
#include <rcl/types.h>

ERL_NIF_TERM atom_clock_type;
ERL_NIF_TERM atom_system_time;
ERL_NIF_TERM atom_steady_time;
ERL_NIF_TERM atom_ros_time;

void make_clock_atoms(ErlNifEnv *env) {
  atom_clock_type  = enif_make_atom(env, "clock_type");
  atom_system_time = enif_make_atom(env, "system_time");
  atom_steady_time = enif_make_atom(env, "steady_time");
  atom_ros_time    = enif_make_atom(env, "ros_time");
}

ERL_NIF_TERM nif_rcl_clock_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_ret_t rc;
  rcl_clock_t clock;
  rcl_allocator_t allocator = get_nif_allocator();
  rcl_clock_type_t clock_type;

  if (enif_is_identical(argv[0], atom_steady_time)) {
    clock_type = RCL_STEADY_TIME;
  } else if (enif_is_identical(argv[0], atom_system_time)) {
    clock_type = RCL_SYSTEM_TIME;
  } else if (enif_is_identical(argv[0], atom_ros_time)) {
    clock_type = RCL_ROS_TIME;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  rc = rcl_clock_init(clock_type, &clock, &allocator);
  if (rc != RCL_RET_OK) return enif_make_badarg(env);

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

ERL_NIF_TERM nif_rcl_clock_get_now(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_clock_t *clock_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_clock_t, (void **)&clock_p))
    return enif_make_badarg(env);

  rcl_time_point_value_t time_point_value;
  rcl_ret_t rc;

  rc = rcl_clock_get_now(clock_p, &time_point_value);
  if (rc == RCL_RET_INVALID_ARGUMENT)
    return enif_make_badarg(env);
  else if (rc == RCL_RET_ERROR)
    return raise(env, __FILE__, __LINE__);

  return enif_make_int64(env, time_point_value);
}

ERL_NIF_TERM nif_rcl_clock_time_started(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_clock_t *clock_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_clock_t, (void **)&clock_p))
    return enif_make_badarg(env);

  return rcl_clock_time_started(clock_p) ? atom_true : atom_false;
}

ERL_NIF_TERM nif_rcl_clock_valid(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_clock_t *clock_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_clock_t, (void **)&clock_p))
    return enif_make_badarg(env);

  return rcl_clock_valid(clock_p) ? atom_true : atom_false;
}

ERL_NIF_TERM nif_rcl_enable_ros_time_override(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_clock_t *clock_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_clock_t, (void **)&clock_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_enable_ros_time_override(clock_p);
  if (rc == RCL_RET_INVALID_ARGUMENT)
    return enif_make_badarg(env);
  else if (rc == RCL_RET_ERROR)
    return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_disable_ros_time_override(ErlNifEnv *env, int argc,
                                               const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rcl_clock_t *clock_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_clock_t, (void **)&clock_p))
    return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_disable_ros_time_override(clock_p);
  if (rc == RCL_RET_INVALID_ARGUMENT)
    return enif_make_badarg(env);
  else if (rc == RCL_RET_ERROR)
    return raise(env, __FILE__, __LINE__);

  return atom_ok;
}

ERL_NIF_TERM nif_rcl_set_ros_time_override(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 2) return enif_make_badarg(env);

  rcl_clock_t *clock_p;
  if (!enif_get_resource(env, argv[0], rt_rcl_clock_t, (void **)&clock_p))
    return enif_make_badarg(env);

  rcl_time_point_value_t time_value;
  if (!enif_get_int64(env, argv[1], &time_value)) return enif_make_badarg(env);

  rcl_ret_t rc;
  rc = rcl_set_ros_time_override(clock_p, time_value);
  if (rc == RCL_RET_INVALID_ARGUMENT)
    return enif_make_badarg(env);
  else if (rc == RCL_RET_ERROR)
    return raise(env, __FILE__, __LINE__);

  return atom_ok;
}