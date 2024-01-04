#include <erl_nif.h>

void make_qos_atoms(ErlNifEnv *env);
ERL_NIF_TERM nif_get_qos_profile_for_test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
