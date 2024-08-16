#include <erl_nif.h>

extern void make_action_client_atoms(ErlNifEnv *env);

ERL_NIF_TERM nif_rcl_action_client_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_set_cancel_client_callback(ErlNifEnv *env, int argc,
                                                              const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_set_feedback_subscription_callback(ErlNifEnv *env, int argc,
                                                                      const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_set_goal_client_callback(ErlNifEnv *env, int argc,
                                                            const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_set_result_client_callback(ErlNifEnv *env, int argc,
                                                              const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_set_status_subscription_callback(ErlNifEnv *env, int argc,
                                                                    const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_clear_cancel_client_callback(ErlNifEnv *env, int argc,
                                                                const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_clear_feedback_subscription_callback(ErlNifEnv *env, int argc,
                                                                        const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_clear_goal_client_callback(ErlNifEnv *env, int argc,
                                                              const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_clear_result_client_callback(ErlNifEnv *env, int argc,
                                                                const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_client_clear_status_subscription_callback(ErlNifEnv *env, int argc,
                                                                      const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_send_cancel_request(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_send_goal_request(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_send_result_request(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_take_cancel_response(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_take_feedback(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_take_goal_response(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_take_result_response(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_take_status(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_server_is_available(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]);
