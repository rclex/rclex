#include <erl_nif.h>

ERL_NIF_TERM nif_builtin_interfaces_msg_time_type_support(ErlNifEnv *env, int argc,
                                                          const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_builtin_interfaces_msg_time_create(ErlNifEnv *env, int argc,
                                                    const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_builtin_interfaces_msg_time_destroy(ErlNifEnv *env, int argc,
                                                     const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_builtin_interfaces_msg_time_set(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_builtin_interfaces_msg_time_get(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
