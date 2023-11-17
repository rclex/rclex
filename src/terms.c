#include "terms.h"
#include "macros.h"
#include <erl_nif.h>

ERL_NIF_TERM atom_ok;
ERL_NIF_TERM atom_error;
ERL_NIF_TERM atom_true;
ERL_NIF_TERM atom_false;

ERL_NIF_TERM atom_history;
ERL_NIF_TERM atom_depth;
ERL_NIF_TERM atom_reliability;
ERL_NIF_TERM atom_durability;
ERL_NIF_TERM atom_deadline;
ERL_NIF_TERM atom_lifespan;
ERL_NIF_TERM atom_liveliness;
ERL_NIF_TERM atom_liveliness_lease_duration;
ERL_NIF_TERM atom_avoid_ros_namespace_conventions;

ERL_NIF_TERM atom_system_default; // Impplementation specific default.
ERL_NIF_TERM atom_keep_last; // Only store up to a maximum number of samples, dropping oldest once
                             // max is exceeded.
ERL_NIF_TERM atom_keep_all;  // Store all samples, subject to resource limits.
ERL_NIF_TERM atom_transient_local; // The rmw publisher is responsible for persisting samples for
                                   // “late-joining” subscribers.
ERL_NIF_TERM atom_volatile;        // Samples are not persistent.
ERL_NIF_TERM atom_reliable;    // Guarantee that samples are delivered, may retry multiple times.
ERL_NIF_TERM atom_best_effort; // Attempt to deliver samples, but some may be lost if the network is
                               // not robust.
ERL_NIF_TERM
    atom_automatic; // The signal that establishes a Topic is alive comes from the ROS rmw layer.
ERL_NIF_TERM atom_manual_by_topic; // The signal that establishes a Topic is alive is at the Topic
                                   // level. Only publishing a message on the Topic or an explicit
                                   // signal from the application to assert liveliness on the Topic
                                   // will mark the Topic as being alive.

void make_atoms(ErlNifEnv *env) {
  atom_ok    = enif_make_atom(env, "ok");
  atom_error = enif_make_atom(env, "error");
  atom_true  = enif_make_atom(env, "true");
  atom_false = enif_make_atom(env, "false");

  atom_history                         = enif_make_atom(env, "history");
  atom_system_default                  = enif_make_atom(env, "system_default");
  atom_keep_all                        = enif_make_atom(env, "keep_all");
  atom_keep_last                       = enif_make_atom(env, "keep_last");
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
  atom_liveliness_lease_duration       = enif_make_atom(env, "liveliness_lease_duration");
  atom_avoid_ros_namespace_conventions = enif_make_atom(env, "avoid_ros_namespace_conventions");
  atom_reliable                        = enif_make_atom(env, "reliable");
  atom_best_effort                     = enif_make_atom(env, "best_effort");
  atom_automatic                       = enif_make_atom(env, "automatic");
  atom_manual_by_topic                 = enif_make_atom(env, "manual_by_topic");
}

ERL_NIF_TERM nif_raise_for_test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argc);
  ignore_unused(argv);

  return raise(env, __FILE__, __LINE__);
}

ERL_NIF_TERM nif_raise_with_message_for_test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argc);
  ignore_unused(argv);

  return raise_with_message(env, __FILE__, __LINE__, "test");
}
