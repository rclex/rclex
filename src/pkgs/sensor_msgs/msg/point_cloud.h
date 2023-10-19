#include <erl_nif.h>

ERL_NIF_TERM nif_sensor_msgs_msg_point_cloud_type_support(ErlNifEnv *env, int argc,
                                                          const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_sensor_msgs_msg_point_cloud_create(ErlNifEnv *env, int argc,
                                                    const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_sensor_msgs_msg_point_cloud_destroy(ErlNifEnv *env, int argc,
                                                     const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_sensor_msgs_msg_point_cloud_set(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_sensor_msgs_msg_point_cloud_get(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
