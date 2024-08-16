#include "macros.h"
#include "terms.h"
#include <erl_nif.h>
#include <math.h>
// IWYU pragma: no_include "rmw/time.h" for foxy
#include <rcl_action/default_qos.h>
#include <rmw/qos_profiles.h>
#include <rmw/types.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

ERL_NIF_TERM atom_history;
ERL_NIF_TERM atom_system_default;
ERL_NIF_TERM atom_keep_last;
ERL_NIF_TERM atom_keep_all;
ERL_NIF_TERM atom_depth;
ERL_NIF_TERM atom_reliability;
ERL_NIF_TERM atom_reliable;
ERL_NIF_TERM atom_best_effort;
ERL_NIF_TERM atom_durability;
ERL_NIF_TERM atom_transient_local;
ERL_NIF_TERM atom_volatile;
ERL_NIF_TERM atom_deadline;
ERL_NIF_TERM atom_lifespan;
ERL_NIF_TERM atom_liveliness;
ERL_NIF_TERM atom_automatic;
ERL_NIF_TERM atom_deprecated;
ERL_NIF_TERM atom_manual_by_topic;
ERL_NIF_TERM atom_liveliness_lease_duration;
ERL_NIF_TERM atom_avoid_ros_namespace_conventions;
ERL_NIF_TERM atom_unknown;
ERL_NIF_TERM atom_qos_struct_k;
ERL_NIF_TERM atom_qos_struct_v;

void make_qos_atoms(ErlNifEnv *env) {
  atom_history                         = enif_make_atom(env, "history");
  atom_system_default                  = enif_make_atom(env, "system_default");
  atom_keep_last                       = enif_make_atom(env, "keep_last");
  atom_keep_all                        = enif_make_atom(env, "keep_all");
  atom_depth                           = enif_make_atom(env, "depth");
  atom_reliability                     = enif_make_atom(env, "reliability");
  atom_reliable                        = enif_make_atom(env, "reliable");
  atom_best_effort                     = enif_make_atom(env, "best_effort");
  atom_durability                      = enif_make_atom(env, "durability");
  atom_transient_local                 = enif_make_atom(env, "transient_local");
  atom_volatile                        = enif_make_atom(env, "volatile");
  atom_deadline                        = enif_make_atom(env, "deadline");
  atom_lifespan                        = enif_make_atom(env, "lifespan");
  atom_liveliness                      = enif_make_atom(env, "liveliness");
  atom_automatic                       = enif_make_atom(env, "automatic");
  atom_deprecated                      = enif_make_atom(env, "deprecated");
  atom_manual_by_topic                 = enif_make_atom(env, "manual_by_topic");
  atom_liveliness_lease_duration       = enif_make_atom(env, "liveliness_lease_duration");
  atom_avoid_ros_namespace_conventions = enif_make_atom(env, "avoid_ros_namespace_conventions");
  atom_unknown                         = enif_make_atom(env, "unknown");
  atom_qos_struct_k                    = enif_make_atom(env, "__struct__");
  atom_qos_struct_v                    = enif_make_atom(env, "Elixir.Rclex.QoS");
}

ERL_NIF_TERM get_c_qos_profile(ErlNifEnv *env, ERL_NIF_TERM map, rmw_qos_profile_t *qos_p) {
  const size_t kv_pair_counts = 10; // 9 + __struct__
  size_t size;
  if (!enif_get_map_size(env, map, &size)) return enif_make_badarg(env);
  if (size != kv_pair_counts) return enif_make_badarg(env);

  ERL_NIF_TERM k, v;

  k = atom_history;
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  if (enif_is_identical(v, atom_system_default)) {
    qos_p->history = RMW_QOS_POLICY_HISTORY_SYSTEM_DEFAULT;
  } else if (enif_is_identical(v, atom_keep_last)) {
    qos_p->history = RMW_QOS_POLICY_HISTORY_KEEP_LAST;
  } else if (enif_is_identical(v, atom_keep_all)) {
    qos_p->history = RMW_QOS_POLICY_HISTORY_KEEP_ALL;
  } else if (enif_is_identical(v, atom_unknown)) {
    qos_p->history = RMW_QOS_POLICY_HISTORY_UNKNOWN;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  k = atom_depth;
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);
  unsigned int depth;
  if (!enif_get_uint(env, v, &depth)) return raise(env, __FILE__, __LINE__);
  qos_p->depth = (size_t)depth;

  k = atom_reliability;
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  if (enif_is_identical(v, atom_system_default)) {
    qos_p->reliability = RMW_QOS_POLICY_RELIABILITY_SYSTEM_DEFAULT;
  } else if (enif_is_identical(v, atom_reliable)) {
    qos_p->reliability = RMW_QOS_POLICY_RELIABILITY_RELIABLE;
  } else if (enif_is_identical(v, atom_best_effort)) {
    qos_p->reliability = RMW_QOS_POLICY_RELIABILITY_BEST_EFFORT;
  } else if (enif_is_identical(v, atom_unknown)) {
    qos_p->reliability = RMW_QOS_POLICY_RELIABILITY_UNKNOWN;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  k = atom_durability;
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  if (enif_is_identical(v, atom_system_default)) {
    qos_p->durability = RMW_QOS_POLICY_DURABILITY_SYSTEM_DEFAULT;
  } else if (enif_is_identical(v, atom_transient_local)) {
    qos_p->durability = RMW_QOS_POLICY_DURABILITY_TRANSIENT_LOCAL;
  } else if (enif_is_identical(v, atom_volatile)) {
    qos_p->durability = RMW_QOS_POLICY_DURABILITY_VOLATILE;
  } else if (enif_is_identical(v, atom_unknown)) {
    qos_p->durability = RMW_QOS_POLICY_DURABILITY_UNKNOWN;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  k = atom_deadline;
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  double deadline, deadline_sec_part, deadline_nsec_part;
  if (!enif_get_double(env, v, &deadline)) return raise(env, __FILE__, __LINE__);
  deadline_nsec_part   = modf(deadline, &deadline_sec_part);
  qos_p->deadline.sec  = (uint64_t)(deadline_sec_part);
  qos_p->deadline.nsec = (uint64_t)(deadline_nsec_part * 1000000000);

  k = atom_lifespan;
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  double lifespan, lifespan_sec_part, lifespan_nsec_part;
  if (!enif_get_double(env, v, &lifespan)) return raise(env, __FILE__, __LINE__);
  lifespan_nsec_part   = modf(lifespan, &lifespan_sec_part);
  qos_p->lifespan.sec  = (uint64_t)(lifespan_sec_part);
  qos_p->lifespan.nsec = (uint64_t)(lifespan_nsec_part * 1000000000);

  k = atom_liveliness;
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  if (enif_is_identical(v, atom_system_default)) {
    qos_p->liveliness = RMW_QOS_POLICY_LIVELINESS_SYSTEM_DEFAULT;
  } else if (enif_is_identical(v, atom_automatic)) {
    qos_p->liveliness = RMW_QOS_POLICY_LIVELINESS_AUTOMATIC;
  } else if (enif_is_identical(v, atom_deprecated)) {
    return raise_with_message(env, __FILE__, __LINE__, "this option is deprecated");
  } else if (enif_is_identical(v, atom_manual_by_topic)) {
    qos_p->liveliness = RMW_QOS_POLICY_LIVELINESS_MANUAL_BY_TOPIC;
  } else if (enif_is_identical(v, atom_unknown)) {
    qos_p->liveliness = RMW_QOS_POLICY_LIVELINESS_UNKNOWN;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  k = atom_liveliness_lease_duration;
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  double liveliness_lease_duration, liveliness_lease_duration_sec_part,
      liveliness_lease_duration_nsec_part;
  if (!enif_get_double(env, v, &liveliness_lease_duration)) return raise(env, __FILE__, __LINE__);
  liveliness_lease_duration_nsec_part =
      modf(liveliness_lease_duration, &liveliness_lease_duration_sec_part);
  qos_p->liveliness_lease_duration.sec = (uint64_t)(liveliness_lease_duration_sec_part);
  qos_p->liveliness_lease_duration.nsec =
      (uint64_t)(liveliness_lease_duration_nsec_part * 1000000000);

  k = atom_avoid_ros_namespace_conventions;
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  if (enif_is_identical(v, atom_true)) {
    qos_p->avoid_ros_namespace_conventions = true;
  } else if (enif_is_identical(v, atom_false)) {
    qos_p->avoid_ros_namespace_conventions = false;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  return atom_ok;
}

ERL_NIF_TERM get_ex_qos_profile(ErlNifEnv *env, rmw_qos_profile_t qos) {
  ERL_NIF_TERM map = enif_make_new_map(env);
  ERL_NIF_TERM k, v;

  k = atom_history;
  if (qos.history == RMW_QOS_POLICY_HISTORY_SYSTEM_DEFAULT) {
    v = atom_system_default;
  } else if (qos.history == RMW_QOS_POLICY_HISTORY_KEEP_LAST) {
    v = atom_keep_last;
  } else if (qos.history == RMW_QOS_POLICY_HISTORY_KEEP_ALL) {
    v = atom_keep_all;
  } else if (qos.history == RMW_QOS_POLICY_HISTORY_UNKNOWN) {
    v = atom_unknown;
  } else {
    return raise(env, __FILE__, __LINE__);
  }
  enif_make_map_put(env, map, k, v, &map);

  k = atom_depth;
  v = enif_make_uint(env, qos.depth);
  enif_make_map_put(env, map, k, v, &map);

  k = atom_reliability;
  if (qos.reliability == RMW_QOS_POLICY_RELIABILITY_SYSTEM_DEFAULT) {
    v = atom_system_default;
  } else if (qos.reliability == RMW_QOS_POLICY_RELIABILITY_RELIABLE) {
    v = atom_reliable;
  } else if (qos.reliability == RMW_QOS_POLICY_RELIABILITY_BEST_EFFORT) {
    v = atom_best_effort;
  } else if (qos.reliability == RMW_QOS_POLICY_RELIABILITY_UNKNOWN) {
    v = atom_unknown;
  } else {
    return raise(env, __FILE__, __LINE__);
  }
  enif_make_map_put(env, map, k, v, &map);

  k = atom_durability;
  if (qos.durability == RMW_QOS_POLICY_DURABILITY_SYSTEM_DEFAULT) {
    v = atom_system_default;
  } else if (qos.durability == RMW_QOS_POLICY_DURABILITY_TRANSIENT_LOCAL) {
    v = atom_transient_local;
  } else if (qos.durability == RMW_QOS_POLICY_DURABILITY_VOLATILE) {
    v = atom_volatile;
  } else if (qos.durability == RMW_QOS_POLICY_DURABILITY_UNKNOWN) {
    v = atom_unknown;
  } else {
    return raise(env, __FILE__, __LINE__);
  }
  enif_make_map_put(env, map, k, v, &map);

  k               = atom_deadline;
  double deadline = (double)qos.deadline.sec + (double)qos.deadline.nsec / (double)1000000000;
  v               = enif_make_double(env, deadline);
  enif_make_map_put(env, map, k, v, &map);

  k               = atom_lifespan;
  double lifespan = (double)qos.lifespan.sec + (double)qos.lifespan.nsec / (double)1000000000;
  v               = enif_make_double(env, lifespan);
  enif_make_map_put(env, map, k, v, &map);

  k = atom_liveliness;
  if (qos.liveliness == RMW_QOS_POLICY_LIVELINESS_SYSTEM_DEFAULT) {
    v = atom_system_default;
  } else if (qos.liveliness == RMW_QOS_POLICY_LIVELINESS_AUTOMATIC) {
    v = atom_automatic;
  } else if (qos.liveliness == RMW_QOS_POLICY_LIVELINESS_MANUAL_BY_TOPIC) {
    v = atom_manual_by_topic;
  } else if (qos.liveliness == RMW_QOS_POLICY_LIVELINESS_UNKNOWN) {
    v = atom_unknown;
  } else {
    return raise(env, __FILE__, __LINE__);
  }
  enif_make_map_put(env, map, k, v, &map);

  k = atom_liveliness_lease_duration;
  double liveliness_lease_duration =
      (double)qos.liveliness_lease_duration.sec +
      (double)qos.liveliness_lease_duration.nsec / (double)1000000000;
  v = enif_make_double(env, liveliness_lease_duration);
  enif_make_map_put(env, map, k, v, &map);

  k = atom_avoid_ros_namespace_conventions;
  if (qos.avoid_ros_namespace_conventions == true) {
    v = atom_true;
  } else if (qos.avoid_ros_namespace_conventions == false) {
    v = atom_false;
  } else {
    return raise(env, __FILE__, __LINE__);
  }
  enif_make_map_put(env, map, k, v, &map);

  enif_make_map_put(env, map, atom_qos_struct_k, atom_qos_struct_v, &map);

  return map;
}

ERL_NIF_TERM nif_rmw_qos_profile_sensor_data(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 0) return enif_make_badarg(env);
  ignore_unused(argv);

  return get_ex_qos_profile(env, rmw_qos_profile_sensor_data);
}

ERL_NIF_TERM nif_rmw_qos_profile_parameters(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 0) return enif_make_badarg(env);
  ignore_unused(argv);

  return get_ex_qos_profile(env, rmw_qos_profile_parameters);
}

ERL_NIF_TERM nif_rmw_qos_profile_default(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 0) return enif_make_badarg(env);
  ignore_unused(argv);

  return get_ex_qos_profile(env, rmw_qos_profile_default);
}

ERL_NIF_TERM nif_rmw_qos_profile_services_default(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]) {
  if (argc != 0) return enif_make_badarg(env);
  ignore_unused(argv);

  return get_ex_qos_profile(env, rmw_qos_profile_services_default);
}

ERL_NIF_TERM nif_rmw_qos_profile_parameter_events(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]) {
  if (argc != 0) return enif_make_badarg(env);
  ignore_unused(argv);

  return get_ex_qos_profile(env, rmw_qos_profile_parameter_events);
}

ERL_NIF_TERM nif_rmw_qos_profile_system_default(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]) {
  if (argc != 0) return enif_make_badarg(env);
  ignore_unused(argv);

  return get_ex_qos_profile(env, rmw_qos_profile_system_default);
}

ERL_NIF_TERM nif_rcl_action_qos_profile_status_default(ErlNifEnv *env, int argc,
                                                       const ERL_NIF_TERM argv[]) {
  if (argc != 0) return enif_make_badarg(env);
  ignore_unused(argv);

  return get_ex_qos_profile(env, rcl_action_qos_profile_status_default);
}

ERL_NIF_TERM nif_test_qos_profile(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rmw_qos_profile_t qos;
  ERL_NIF_TERM ret = get_c_qos_profile(env, argv[0], &qos);
  if (enif_is_exception(env, ret)) return ret;
  return get_ex_qos_profile(env, qos);
}
