#include <erl_nif.h>

ERL_NIF_TERM nif_create_empty_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_string_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_getmsgtype_String(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_setdata_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_readdata_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);
