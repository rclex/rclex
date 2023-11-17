#ifndef TERMS_H
#define TERMS_H
#ifdef __cplusplus
extern "C" {
#endif
#include <erl_nif.h>
#include <stdio.h>

extern ERL_NIF_TERM atom_ok;
extern ERL_NIF_TERM atom_error;
extern ERL_NIF_TERM atom_true;
extern ERL_NIF_TERM atom_false;

extern ERL_NIF_TERM atom_history;
extern ERL_NIF_TERM atom_depth;
extern ERL_NIF_TERM atom_reliability;
extern ERL_NIF_TERM atom_durability;
extern ERL_NIF_TERM atom_deadline;
extern ERL_NIF_TERM atom_lifespan;
extern ERL_NIF_TERM atom_liveliness;
extern ERL_NIF_TERM atom_liveliness_lease_duration;
extern ERL_NIF_TERM atom_avoid_ros_namespace_conventions;

extern ERL_NIF_TERM atom_system_default; // Impplementation specific default.
extern ERL_NIF_TERM atom_keep_last; // Only store up to a maximum number of samples, dropping oldest
                                    // once max is exceeded.
extern ERL_NIF_TERM atom_keep_all;  // Store all samples, subject to resource limits.
extern ERL_NIF_TERM atom_transient_local; // The rmw publisher is responsible for persisting samples
                                          // for “late-joining” subscribers.
extern ERL_NIF_TERM atom_volatile;        // Samples are not persistent.
extern ERL_NIF_TERM
    atom_reliable; // Guarantee that samples are delivered, may retry multiple times.
extern ERL_NIF_TERM atom_best_effort; // Attempt to deliver samples, but some may be lost if the
                                      // network is not robust.
extern ERL_NIF_TERM
    atom_automatic; // The signal that establishes a Topic is alive comes from the ROS rmw layer.
extern ERL_NIF_TERM
    atom_manual_by_topic; // The signal that establishes a Topic is alive is at the Topic level.
                          // Only publishing a message on the Topic or an explicit signal from the
                          // application to assert liveliness on the Topic will mark the Topic as
                          // being alive.

extern void make_atoms(ErlNifEnv *env);
extern ERL_NIF_TERM nif_raise_for_test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
extern ERL_NIF_TERM nif_raise_with_message_for_test(ErlNifEnv *env, int argc,
                                                    const ERL_NIF_TERM argv[]);

static inline ERL_NIF_TERM raise(ErlNifEnv *env, const char *file, int line) {
  char str[1024];
  snprintf(str, sizeof(str), "at %s:%d", file, line);
  return enif_raise_exception(env, enif_make_string(env, str, ERL_NIF_LATIN1));
}

static inline ERL_NIF_TERM raise_with_message(ErlNifEnv *env, const char *file, int line,
                                              const char *message) {
  char str[1024];
  snprintf(str, sizeof(str), "at %s:%d %s", file, line, message);
  return enif_raise_exception(env, enif_make_string(env, str, ERL_NIF_LATIN1));
}

#ifdef __cplusplus
}
#endif
#endif