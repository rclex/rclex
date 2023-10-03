#include <erl_nif.h>

ERL_NIF_TERM nif_rcl_wait_set_init_subscription(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_wait_set_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_wait_subscription(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
