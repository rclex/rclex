#include <erl_nif.h>

ERL_NIF_TERM nif_rcl_get_zero_initialized_wait_set(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_wait_set_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_wait_set_fini(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_wait_set_add_subscription(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_wait(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);