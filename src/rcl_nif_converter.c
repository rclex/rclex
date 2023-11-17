#include "rcl_nif_converter.h"

int term_to_rmw_time(ErlNifEnv *env, ERL_NIF_TERM term, rmw_time_t *time) {
  ErlNifUInt64 ip;
  int ret    = enif_get_uint64(env, term, &ip);
  time->sec  = ip / 1000000000;
  time->nsec = ip % 1000000000;
  return ret;
}

ERL_NIF_TERM rmw_time_to_term(ErlNifEnv *env, rmw_time_t time) {
  return enif_make_uint64(env, time.sec * 1000000000LL + time.nsec);
}

ERL_NIF_TERM qos_profile_to_keywordlist(ErlNifEnv *env, rmw_qos_profile_t qos) {

  ERL_NIF_TERM history_value = atom_system_default;
  if (qos.history == RMW_QOS_POLICY_HISTORY_KEEP_LAST) {
    history_value = atom_keep_last;
  } else if (qos.history == RMW_QOS_POLICY_HISTORY_KEEP_ALL) {
    history_value = atom_keep_all;
  }

  ERL_NIF_TERM reliability_value = atom_system_default;
  if (qos.reliability == RMW_QOS_POLICY_RELIABILITY_RELIABLE) {
    reliability_value = atom_reliable;
  } else if (qos.reliability == RMW_QOS_POLICY_RELIABILITY_BEST_EFFORT) {
    reliability_value = atom_best_effort;
  }

  ERL_NIF_TERM durability_value = atom_system_default;
  if (qos.durability == RMW_QOS_POLICY_DURABILITY_VOLATILE) {
    durability_value = atom_volatile;
  } else if (qos.durability == RMW_QOS_POLICY_DURABILITY_TRANSIENT_LOCAL) {
    durability_value = atom_transient_local;
  }

  ERL_NIF_TERM liveliness_value = atom_system_default;
  if (qos.liveliness == RMW_QOS_POLICY_LIVELINESS_AUTOMATIC) {
    liveliness_value = atom_automatic;
  } else if (qos.liveliness == RMW_QOS_POLICY_LIVELINESS_MANUAL_BY_TOPIC) {
    liveliness_value = atom_manual_by_topic;
  }

  ERL_NIF_TERM history     = enif_make_tuple2(env, atom_history, history_value);
  ERL_NIF_TERM depth       = enif_make_tuple2(env, atom_depth, enif_make_int(env, qos.depth));
  ERL_NIF_TERM reliability = enif_make_tuple2(env, atom_reliability, reliability_value);
  ERL_NIF_TERM durability  = enif_make_tuple2(env, atom_durability, durability_value);
  ERL_NIF_TERM deadline = enif_make_tuple2(env, atom_deadline, rmw_time_to_term(env, qos.deadline));
  ERL_NIF_TERM lifespan = enif_make_tuple2(env, atom_lifespan, rmw_time_to_term(env, qos.lifespan));
  ERL_NIF_TERM liveliness                = enif_make_tuple2(env, atom_liveliness, liveliness_value);
  ERL_NIF_TERM liveliness_lease_duration = enif_make_tuple2(
      env, atom_liveliness_lease_duration, rmw_time_to_term(env, qos.liveliness_lease_duration));
  ERL_NIF_TERM avoid_ros_namespace_conventions =
      enif_make_tuple2(env, atom_avoid_ros_namespace_conventions,
                       qos.avoid_ros_namespace_conventions ? atom_true : atom_false);

  ERL_NIF_TERM list =
      enif_make_list9(env, history, depth, reliability, durability, deadline, lifespan, liveliness,
                      liveliness_lease_duration, avoid_ros_namespace_conventions);

  return list;
}

int fill_qos_profile_from_opts(ErlNifEnv *env, ERL_NIF_TERM list, rmw_qos_profile_t *qos_profile) {
  ERL_NIF_TERM head, tail;

  while (enif_get_list_cell(env, list, &head, &tail)) {
    if (enif_is_tuple(env, head)) {
      const ERL_NIF_TERM *elems;
      ERL_NIF_TERM key, value;
      int arrity;

      enif_get_tuple(env, head, &arrity, &elems);
      if (arrity != 2) {
        return 0; // invalid keyword list, element not a 2-tuple
      }

      key   = elems[0];
      value = elems[1];
      if (enif_compare(key, atom_history) == 0) {
        if (enif_compare(value, atom_system_default) == 0) {
          qos_profile->history = RMW_QOS_POLICY_HISTORY_SYSTEM_DEFAULT;
        } else if (enif_compare(value, atom_keep_last) == 0) {
          qos_profile->history = RMW_QOS_POLICY_HISTORY_KEEP_LAST;
        } else if (enif_compare(value, atom_keep_all) == 0) {
          qos_profile->history = RMW_QOS_POLICY_HISTORY_KEEP_ALL;
        }
      } else if (enif_compare(key, atom_depth) == 0) {
        unsigned int depth;
        if (!enif_get_uint(env, value, &depth)) {
          return 0; // not an integer
        }
        qos_profile->depth = depth;
      } else if (enif_compare(key, atom_reliability) == 0) {
        if (enif_compare(value, atom_system_default) == 0) {
          qos_profile->reliability = RMW_QOS_POLICY_RELIABILITY_SYSTEM_DEFAULT;
        } else if (enif_compare(value, atom_reliable) == 0) {
          qos_profile->reliability = RMW_QOS_POLICY_RELIABILITY_RELIABLE;
        } else if (enif_compare(value, atom_best_effort) == 0) {
          qos_profile->reliability = RMW_QOS_POLICY_RELIABILITY_BEST_EFFORT;
        }
      } else if (enif_compare(key, atom_durability) == 0) {
        if (enif_compare(value, atom_system_default) == 0) {
          qos_profile->durability = RMW_QOS_POLICY_DURABILITY_SYSTEM_DEFAULT;
        } else if (enif_compare(value, atom_transient_local) == 0) {
          qos_profile->durability = RMW_QOS_POLICY_DURABILITY_TRANSIENT_LOCAL;
        } else if (enif_compare(value, atom_volatile) == 0) {
          qos_profile->durability = RMW_QOS_POLICY_DURABILITY_VOLATILE;
        }
      } else if (enif_compare(key, atom_deadline) == 0) {
        rmw_time_t deadline;
        if (!term_to_rmw_time(env, value, &deadline)) {
          return 0;
        }
        qos_profile->deadline = deadline;
      } else if (enif_compare(key, atom_lifespan) == 0) {
        rmw_time_t lifespan;
        if (!term_to_rmw_time(env, value, &lifespan)) {
          return 0;
        }
        qos_profile->lifespan = lifespan;
      } else if (enif_compare(key, atom_liveliness) == 0) {
        if (enif_compare(value, atom_system_default) == 0) {
          qos_profile->liveliness = RMW_QOS_POLICY_LIVELINESS_SYSTEM_DEFAULT;
        } else if (enif_compare(value, atom_automatic) == 0) {
          qos_profile->liveliness = RMW_QOS_POLICY_LIVELINESS_AUTOMATIC;
        } else if (enif_compare(value, atom_manual_by_topic) == 0) {
          qos_profile->liveliness = RMW_QOS_POLICY_LIVELINESS_MANUAL_BY_TOPIC;
        }
      } else if (enif_compare(key, atom_liveliness_lease_duration) == 0) {
        rmw_time_t liveliness_lease_duration;
        if (!term_to_rmw_time(env, value, &liveliness_lease_duration)) {
          return 0;
        }
        qos_profile->liveliness_lease_duration = liveliness_lease_duration;
      } else if (enif_compare(key, atom_avoid_ros_namespace_conventions) == 0) {
        if (enif_compare(value, atom_true) == 0) {
          qos_profile->avoid_ros_namespace_conventions = 1;
        } else if (enif_compare(value, atom_false) == 0) {
          qos_profile->avoid_ros_namespace_conventions = 0;
        }
      }
    } else {
      return 0; // invalid keyword list, element not a tuple
    }
    list = tail; // Move to the next pair
  }

  return 1;
}