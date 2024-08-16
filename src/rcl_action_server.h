#include <erl_nif.h>

extern void make_action_server_atoms(ErlNifEnv *env);

ERL_NIF_TERM nif_rcl_action_server_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_server_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_accept_new_goal(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_expire_goals(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_get_goal_status_array(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_notify_goal_done(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_process_cancel_request(ErlNifEnv *env, int argc,
                                                   const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_publish_feedback(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_publish_status(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_send_cancel_response(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_send_goal_response(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_send_result_response(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_server_get_goal_handles(ErlNifEnv *env, int argc,
                                                    const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_server_goal_exists(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_server_set_cancel_service_callback(ErlNifEnv *env, int argc,
                                                               const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_server_set_goal_service_callback(ErlNifEnv *env, int argc,
                                                             const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_server_set_result_service_callback(ErlNifEnv *env, int argc,
                                                               const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_server_clear_cancel_service_callback(ErlNifEnv *env, int argc,
                                                                 const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_server_clear_goal_service_callback(ErlNifEnv *env, int argc,
                                                               const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_server_clear_result_service_callback(ErlNifEnv *env, int argc,
                                                                 const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_take_cancel_request(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_take_goal_request(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_take_result_request(ErlNifEnv *env, int argc,
                                                const ERL_NIF_TERM argv[]);

ERL_NIF_TERM nif_rcl_action_goal_handle_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_update_goal_state(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_goal_handle_get_info(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_goal_handle_get_status(ErlNifEnv *env, int argc,
                                                   const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_goal_handle_is_active(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_goal_handle_is_cancelable(ErlNifEnv *env, int argc,
                                                      const ERL_NIF_TERM argv[]);
ERL_NIF_TERM nif_rcl_action_goal_handle_is_valid(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);
