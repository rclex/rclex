#include <erl_nif.h>

extern void make_client_atom(ErlNifEnv *env);

ERL_NIF_TERM nif_rcl_client_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_client_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_send_request(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_take_response_with_info(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_client_set_on_new_response_callback(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_client_clear_response_callback(ErlNifEnv *env, int argc,
                                                    const ERL_NIF_TERM argv[]);
