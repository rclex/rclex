#include "terms.h"
#include "macros.h"
#include <erl_nif.h>

ERL_NIF_TERM atom_ok;
ERL_NIF_TERM atom_error;
ERL_NIF_TERM atom_true;
ERL_NIF_TERM atom_false;
ERL_NIF_TERM subscription_take_failed;

void make_common_atoms(ErlNifEnv *env) {
  atom_ok                  = enif_make_atom(env, "ok");
  atom_error               = enif_make_atom(env, "error");
  atom_true                = enif_make_atom(env, "true");
  atom_false               = enif_make_atom(env, "false");
  subscription_take_failed = enif_make_atom(env, "subscription_take_failed");
}

ERL_NIF_TERM nif_test_raise(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argc);
  ignore_unused(argv);

  return raise(env, __FILE__, __LINE__);
}

ERL_NIF_TERM nif_test_raise_with_message(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]) {
  ignore_unused(argc);
  ignore_unused(argv);

  return raise_with_message(env, __FILE__, __LINE__, "test");
}
