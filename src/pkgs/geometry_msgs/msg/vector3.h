#include <erl_nif.h>

ERL_NIF_TERM nif_rosidl_get_geometry_msgs_msg_vector3_type_support(ErlNifEnv *env, int argc,
                                                                   const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_geometry_msgs_msg_vector3_create(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_geometry_msgs_msg_vector3_destroy(ErlNifEnv *env, int argc,
                                                   const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_geometry_msgs_msg_vector3_set(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_geometry_msgs_msg_vector3_get(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
