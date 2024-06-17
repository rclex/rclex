#include <erl_nif.h>
#include <rmw/types.h>

void make_qos_atoms(ErlNifEnv *env);
ERL_NIF_TERM get_c_qos_profile(ErlNifEnv *env, ERL_NIF_TERM map, rmw_qos_profile_t *qos_p);
ERL_NIF_TERM get_ex_qos_profile(ErlNifEnv *env, rmw_qos_profile_t qos);
ERL_NIF_TERM nif_rmw_qos_profile_sensor_data(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rmw_qos_profile_parameters(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rmw_qos_profile_default(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rmw_qos_profile_services_default(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rmw_qos_profile_parameter_events(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rmw_qos_profile_system_default(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_test_qos_profile(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
