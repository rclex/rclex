#include <erl_nif.h>

ERL_NIF_TERM nif_rcl_timer_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_timer_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_timer_is_ready(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_timer_call(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
