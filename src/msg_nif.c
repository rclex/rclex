#ifdef __cplusplus
extern "C"
{
#endif

#include <erl_nif.h>

#include "total_nif.h"
#include "msg_nif.h"
#include "rmw/types.h"

ERL_NIF_TERM nif_create_msginfo(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  rmw_message_info_t* res;
  ERL_NIF_TERM ret;

  res = enif_alloc_resource(rt_msginfo,sizeof(rmw_message_info_t));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  return ret;
}

#ifdef __cplusplus
}
#endif

