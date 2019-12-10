#include <erl_nif.h>

ERL_NIF_TERM nif_rcl_get_zero_initialized_publisher(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_publisher_get_default_options(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_publisher_get_topic_name(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_publisher_fini(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_publisher_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_publisher_is_valid(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_publish(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);