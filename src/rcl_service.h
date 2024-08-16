#include <erl_nif.h>

extern void make_service_atoms(ErlNifEnv *env);

ERL_NIF_TERM nif_rcl_service_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_service_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_take_request_with_info(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_send_response(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_service_set_on_new_request_callback(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_service_clear_request_callback(ErlNifEnv *env, int argc,
                                                    const ERL_NIF_TERM argv[]);