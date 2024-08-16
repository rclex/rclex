#include <erl_nif.h>
#include <rcl/context.h>
#include <rcl/guard_condition.h>

typedef struct {
  ErlNifThreadOpts *opts_p;
  ErlNifTid tid;
  ErlNifPid pid;
  rcl_context_t context;
  rcl_guard_condition_t wait_condition;
  rcl_guard_condition_t exit_condition;
} thread_ctx_t;

extern void make_node_atoms(ErlNifEnv *env);

extern ERL_NIF_TERM nif_rcl_node_init(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
extern ERL_NIF_TERM nif_rcl_node_fini(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
extern ERL_NIF_TERM nif_rcl_node_get_domain_id(ErlNifEnv *env, int argc, const ERL_NIF_TERM argv[]);
extern ERL_NIF_TERM nif_rcl_node_get_graph_guard_condition(ErlNifEnv *env, int argc,
                                                           const ERL_NIF_TERM argv[]);
extern ERL_NIF_TERM nif_node_start_waitset_thread(ErlNifEnv *env, int argc,
                                                  const ERL_NIF_TERM argv[]);
extern ERL_NIF_TERM nif_node_stop_waitset_thread(ErlNifEnv *env, int argc,
                                                 const ERL_NIF_TERM argv[]);