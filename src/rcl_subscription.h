#include <erl_nif.h>

extern void make_subscription_atom(ErlNifEnv *env);

ERL_NIF_TERM nif_rcl_subscription_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_subscription_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_take(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_subscription_set_on_new_message_callback(ErlNifEnv *env, int argc,
                                                              const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_subscription_clear_message_callback(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]);
