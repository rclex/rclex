#include "rclex.h"
#include <rcl/rcl.h>  //<>なのでカレントディレクトリを探しに行かない
int handle_load(UnifexEnv * env, void ** priv_data) {
  UNIFEX_UNUSED(env);
  UNIFEX_UNUSED(priv_data);
  printf("Hello from the native side!\r\n");
  return 0;
}

UNIFEX_TERM state_init(UnifexEnv* env) {
  State * state = unifex_alloc_state(env);
  state->a = 42;
  UNIFEX_TERM res = state_init_result_ok(env, state);
  unifex_release_state(env, state);
  return res;
}
UNIFEX_TERM check_state(UnifexEnv* env, UnifexPid target_pid, UnifexNifState* state){
  return check_state_result_ok(env,state->a);
}
void handle_destroy_state(UnifexEnv* env, State* state) {
  UNIFEX_UNUSED(env);
  state -> a = 0;
}