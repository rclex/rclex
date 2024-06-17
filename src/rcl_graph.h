#include <erl_nif.h>

ERL_NIF_TERM nif_rcl_count_publishers(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_count_subscribers(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_get_client_names_and_types_by_node(ErlNifEnv *env, int argc,
                                                        const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_get_node_names(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_get_node_names_with_enclaves(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_get_publisher_names_and_types_by_node(ErlNifEnv *env, int argc,
                                                           const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_get_publishers_info_by_topic(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_get_service_names_and_types(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_get_service_names_and_types_by_node(ErlNifEnv *env, int argc,
                                                         const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_get_subscriber_names_and_types_by_node(ErlNifEnv *env, int argc,
                                                            const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_get_subscribers_info_by_topic(ErlNifEnv *env, int argc,
                                                   const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_get_topic_names_and_types(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_service_server_is_available(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
// ERL_NIF_TERM nif_rcl_wait_for_publishers(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
// ERL_NIF_TERM nif_rcl_wait_for_subscribers(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
