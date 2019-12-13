#include <erl_nif.h>

ERL_NIF_TERM nif_rcl_get_zero_initialized_node(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_node_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_node_fini(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM express_node_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_node_get_default_options(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);