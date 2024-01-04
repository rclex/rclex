#include "terms.h"
#include <erl_nif.h>
#include <math.h>
#include <rmw/time.h>
#include <rmw/types.h>
#include <stdbool.h>
#include <stddef.h>
#include <stdint.h>

static inline bool eq_enif_compare(ERL_NIF_TERM lhs, ERL_NIF_TERM rhs) {
  if (enif_compare(lhs, rhs) == 0) return true;
  return false;
}

ERL_NIF_TERM get_qos_profile_c(ErlNifEnv *env, ERL_NIF_TERM map, rmw_qos_profile_t *qos_p) {
  const size_t kv_pair_counts = 9;
  size_t size;
  if (!enif_get_map_size(env, map, &size)) return enif_make_badarg(env);
  if (size != kv_pair_counts) return enif_make_badarg(env);

  ERL_NIF_TERM k, v;

  k = enif_make_atom(env, "history");
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  if (eq_enif_compare(v, enif_make_atom(env, "system_default"))) {
    qos_p->history = RMW_QOS_POLICY_HISTORY_SYSTEM_DEFAULT;
  } else if (eq_enif_compare(v, enif_make_atom(env, "keep_last"))) {
    qos_p->history = RMW_QOS_POLICY_HISTORY_KEEP_LAST;
  } else if (eq_enif_compare(v, enif_make_atom(env, "keep_all"))) {
    qos_p->history = RMW_QOS_POLICY_HISTORY_KEEP_ALL;
  } else if (eq_enif_compare(v, enif_make_atom(env, "unknown"))) {
    qos_p->history = RMW_QOS_POLICY_HISTORY_UNKNOWN;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  k = enif_make_atom(env, "depth");
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);
  unsigned int depth;
  if (!enif_get_uint(env, v, &depth)) return raise(env, __FILE__, __LINE__);
  qos_p->depth = (size_t)depth;

  k = enif_make_atom(env, "reliability");
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  if (eq_enif_compare(v, enif_make_atom(env, "system_default"))) {
    qos_p->reliability = RMW_QOS_POLICY_RELIABILITY_SYSTEM_DEFAULT;
  } else if (eq_enif_compare(v, enif_make_atom(env, "reliable"))) {
    qos_p->reliability = RMW_QOS_POLICY_RELIABILITY_RELIABLE;
  } else if (eq_enif_compare(v, enif_make_atom(env, "best_effort"))) {
    qos_p->reliability = RMW_QOS_POLICY_RELIABILITY_BEST_EFFORT;
  } else if (eq_enif_compare(v, enif_make_atom(env, "unknown"))) {
    qos_p->reliability = RMW_QOS_POLICY_RELIABILITY_UNKNOWN;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  k = enif_make_atom(env, "durability");
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  if (eq_enif_compare(v, enif_make_atom(env, "system_default"))) {
    qos_p->durability = RMW_QOS_POLICY_DURABILITY_SYSTEM_DEFAULT;
  } else if (eq_enif_compare(v, enif_make_atom(env, "transient_local"))) {
    qos_p->durability = RMW_QOS_POLICY_DURABILITY_TRANSIENT_LOCAL;
  } else if (eq_enif_compare(v, enif_make_atom(env, "volatile"))) {
    qos_p->durability = RMW_QOS_POLICY_DURABILITY_VOLATILE;
  } else if (eq_enif_compare(v, enif_make_atom(env, "unknown"))) {
    qos_p->durability = RMW_QOS_POLICY_DURABILITY_UNKNOWN;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  k = enif_make_atom(env, "deadline");
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  double deadline, deadline_sec_part, deadline_nsec_part;
  if (!enif_get_double(env, v, &deadline)) return raise(env, __FILE__, __LINE__);
  deadline_nsec_part   = modf(deadline, &deadline_sec_part);
  qos_p->deadline.sec  = (uint64_t)(deadline_sec_part);
  qos_p->deadline.nsec = (uint64_t)(deadline_nsec_part * 1000000000);

  k = enif_make_atom(env, "lifespan");
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  double lifespan, lifespan_sec_part, lifespan_nsec_part;
  if (!enif_get_double(env, v, &lifespan)) return raise(env, __FILE__, __LINE__);
  lifespan_nsec_part   = modf(lifespan, &lifespan_sec_part);
  qos_p->lifespan.sec  = (uint64_t)(lifespan_sec_part);
  qos_p->lifespan.nsec = (uint64_t)(lifespan_nsec_part * 1000000000);

  k = enif_make_atom(env, "liveliness");
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  if (eq_enif_compare(v, enif_make_atom(env, "system_default"))) {
    qos_p->liveliness = RMW_QOS_POLICY_LIVELINESS_SYSTEM_DEFAULT;
  } else if (eq_enif_compare(v, enif_make_atom(env, "automatic"))) {
    qos_p->liveliness = RMW_QOS_POLICY_LIVELINESS_AUTOMATIC;
  } else if (eq_enif_compare(v, enif_make_atom(env, "deprecated"))) {
    return raise_with_message(env, __FILE__, __LINE__, "this option is deprecated");
  } else if (eq_enif_compare(v, enif_make_atom(env, "manual_by_topic"))) {
    qos_p->liveliness = RMW_QOS_POLICY_LIVELINESS_MANUAL_BY_TOPIC;
  } else if (eq_enif_compare(v, enif_make_atom(env, "unknown"))) {
    qos_p->liveliness = RMW_QOS_POLICY_LIVELINESS_UNKNOWN;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  k = enif_make_atom(env, "liveliness_lease_duration");
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  double liveliness_lease_duration, liveliness_lease_duration_sec_part,
      liveliness_lease_duration_nsec_part;
  if (!enif_get_double(env, v, &liveliness_lease_duration)) return raise(env, __FILE__, __LINE__);
  liveliness_lease_duration_nsec_part =
      modf(liveliness_lease_duration, &liveliness_lease_duration_sec_part);
  qos_p->liveliness_lease_duration.sec = (uint64_t)(liveliness_lease_duration_sec_part);
  qos_p->liveliness_lease_duration.nsec =
      (uint64_t)(liveliness_lease_duration_nsec_part * 1000000000);

  k = enif_make_atom(env, "avoid_ros_namespace_conventions");
  if (!enif_get_map_value(env, map, k, &v)) return enif_make_badarg(env);

  if (eq_enif_compare(v, atom_true)) {
    qos_p->avoid_ros_namespace_conventions = true;
  } else if (eq_enif_compare(v, atom_false)) {
    qos_p->avoid_ros_namespace_conventions = false;
  } else {
    return raise(env, __FILE__, __LINE__);
  }

  return atom_ok;
}

ERL_NIF_TERM get_qos_profile_ex(ErlNifEnv *env, rmw_qos_profile_t qos) {
  ERL_NIF_TERM map = enif_make_new_map(env);
  ERL_NIF_TERM k, v;

  k = enif_make_atom(env, "history");
  if (qos.history == RMW_QOS_POLICY_HISTORY_SYSTEM_DEFAULT) {
    v = enif_make_atom(env, "system_default");
  } else if (qos.history == RMW_QOS_POLICY_HISTORY_KEEP_LAST) {
    v = enif_make_atom(env, "keep_last");
  } else if (qos.history == RMW_QOS_POLICY_HISTORY_KEEP_ALL) {
    v = enif_make_atom(env, "keep_all");
  } else if (qos.history == RMW_QOS_POLICY_HISTORY_UNKNOWN) {
    v = enif_make_atom(env, "unknown");
  } else {
    return raise(env, __FILE__, __LINE__);
  }
  enif_make_map_put(env, map, k, v, &map);

  k = enif_make_atom(env, "depth");
  v = enif_make_uint(env, qos.depth);
  enif_make_map_put(env, map, k, v, &map);

  k = enif_make_atom(env, "reliability");
  if (qos.reliability == RMW_QOS_POLICY_RELIABILITY_SYSTEM_DEFAULT) {
    v = enif_make_atom(env, "system_default");
  } else if (qos.reliability == RMW_QOS_POLICY_RELIABILITY_RELIABLE) {
    v = enif_make_atom(env, "reliable");
  } else if (qos.reliability == RMW_QOS_POLICY_RELIABILITY_BEST_EFFORT) {
    v = enif_make_atom(env, "best_effort");
  } else if (qos.reliability == RMW_QOS_POLICY_RELIABILITY_UNKNOWN) {
    v = enif_make_atom(env, "unknown");
  } else {
    return raise(env, __FILE__, __LINE__);
  }
  enif_make_map_put(env, map, k, v, &map);

  k = enif_make_atom(env, "durability");
  if (qos.durability == RMW_QOS_POLICY_DURABILITY_SYSTEM_DEFAULT) {
    v = enif_make_atom(env, "system_default");
  } else if (qos.durability == RMW_QOS_POLICY_DURABILITY_TRANSIENT_LOCAL) {
    v = enif_make_atom(env, "transient_local");
  } else if (qos.durability == RMW_QOS_POLICY_DURABILITY_VOLATILE) {
    v = enif_make_atom(env, "volatile");
  } else if (qos.durability == RMW_QOS_POLICY_DURABILITY_UNKNOWN) {
    v = enif_make_atom(env, "unknown");
  } else {
    return raise(env, __FILE__, __LINE__);
  }
  enif_make_map_put(env, map, k, v, &map);

  k               = enif_make_atom(env, "deadline");
  double deadline = (double)qos.deadline.sec + (double)qos.deadline.nsec / (double)1000000000;
  v               = enif_make_double(env, deadline);
  enif_make_map_put(env, map, k, v, &map);

  k               = enif_make_atom(env, "lifespan");
  double lifespan = (double)qos.lifespan.sec + (double)qos.lifespan.nsec / (double)1000000000;
  v               = enif_make_double(env, lifespan);
  enif_make_map_put(env, map, k, v, &map);

  k = enif_make_atom(env, "liveliness");
  if (qos.liveliness == RMW_QOS_POLICY_LIVELINESS_SYSTEM_DEFAULT) {
    v = enif_make_atom(env, "system_default");
  } else if (qos.liveliness == RMW_QOS_POLICY_LIVELINESS_AUTOMATIC) {
    v = enif_make_atom(env, "automatic");
  } else if (qos.liveliness == RMW_QOS_POLICY_LIVELINESS_MANUAL_BY_TOPIC) {
    v = enif_make_atom(env, "manual_by_topic");
  } else if (qos.liveliness == RMW_QOS_POLICY_LIVELINESS_UNKNOWN) {
    v = enif_make_atom(env, "unknown");
  } else {
    return raise(env, __FILE__, __LINE__);
  }
  enif_make_map_put(env, map, k, v, &map);

  k = enif_make_atom(env, "liveliness_lease_duration");
  double liveliness_lease_duration =
      (double)qos.liveliness_lease_duration.sec +
      (double)qos.liveliness_lease_duration.nsec / (double)1000000000;
  v = enif_make_double(env, liveliness_lease_duration);
  enif_make_map_put(env, map, k, v, &map);

  k = enif_make_atom(env, "avoid_ros_namespace_conventions");
  if (qos.avoid_ros_namespace_conventions == true) {
    v = atom_true;
  } else if (qos.avoid_ros_namespace_conventions == false) {
    v = atom_false;
  } else {
    return raise(env, __FILE__, __LINE__);
  }
  enif_make_map_put(env, map, k, v, &map);

  return map;
}

ERL_NIF_TERM nif_get_qos_profile_for_test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  if (argc != 1) return enif_make_badarg(env);

  rmw_qos_profile_t qos;
  ERL_NIF_TERM ret = get_qos_profile_c(env, argv[0], &qos);
  if (!eq_enif_compare(ret, atom_ok)) return ret;
  return get_qos_profile_ex(env, qos);
}
