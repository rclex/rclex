#include <erl_nif.h>

ERL_NIF_TERM nif_rcl_get_zero_initialized_init_options(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_init_options_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_init_options_fini(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_get_zero_initialized_context(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_init_with_null(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_shutdown(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);
