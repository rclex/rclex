#include <erl_nif.h>

ERL_NIF_TERM nif_sensor_msgs_msg_channel_float32_type_support(ErlNifEnv *env, int argc,
                                                              const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_sensor_msgs_msg_channel_float32_create(ErlNifEnv *env, int argc,
                                                        const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_sensor_msgs_msg_channel_float32_destroy(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_sensor_msgs_msg_channel_float32_set(ErlNifEnv *env, int argc,
                                                     const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_sensor_msgs_msg_channel_float32_get(ErlNifEnv *env, int argc,
                                                     const ERL_NIF_TERM argv[]);
