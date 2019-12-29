#include <erl_nif.h>

ERL_NIF_TERM nif_rcl_get_zero_initialized_subscription(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_subscription_get_default_options(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_create_sub_alloc(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_subscription_fini(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_subscription_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_subscription_get_topic_name(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_take(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);

//ERL_NIF_TERM nif_rcl_take_with_null(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]);