#include <erl_nif.h>
#include <rmw/types.h>

void make_qos_atoms(ErlNifEnv *env);
ERL_NIF_TERM get_c_qos_profile(ErlNifEnv *env, ERL_NIF_TERM map, rmw_qos_profile_t *qos_p);
ERL_NIF_TERM nif_get_qos_profile_for_test(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
