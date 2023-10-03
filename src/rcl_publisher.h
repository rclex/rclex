#include <erl_nif.h>

ERL_NIF_TERM nif_rcl_publisher_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_publisher_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_publish(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
