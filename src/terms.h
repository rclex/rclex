#include <erl_nif.h>
#include <stdio.h>

extern ERL_NIF_TERM atom_ok;
extern ERL_NIF_TERM atom_error;
extern ERL_NIF_TERM atom_true;
extern ERL_NIF_TERM atom_false;

extern void make_common_atoms(ErlNifEnv *env);
extern ERL_NIF_TERM nif_test_raise(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
extern ERL_NIF_TERM nif_test_raise_with_message(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]);
extern ERL_NIF_TERM enif_make_binary_wrapper(ErlNifEnv *env, const char *data, size_t size);

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
