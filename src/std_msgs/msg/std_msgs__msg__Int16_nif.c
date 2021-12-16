#ifdef __cplusplus
extern "C"
{
#endif

#include <erl_nif.h>

#ifdef DASHING
#include <rosidl_generator_c/message_type_support_struct.h>
#define __STRING__ASSIGN rosidl_generator_c__String__assign
#elif FOXY
#include <rosidl_runtime_c/message_type_support_struct.h>
#define __STRING__ASSIGN rosidl_runtime_c__String__assign
#endif

#include <std_msgs/msg/int16.h>
#include "total_nif.h"
#include "std_msgs/msg/std_msgs__msg__Int16_nif.h"

ERL_NIF_TERM nif_get_typesupport_std_msgs__msg__Int16(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  void* res;
  rosidl_message_type_support_t** res_ts;
  ERL_NIF_TERM ret;

  res = enif_alloc_resource(rt_void,sizeof(rosidl_message_type_support_t*));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  res_ts = (rosidl_message_type_support_t**) res;
  *res_ts = ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,Int16);
  return ret;
}

ERL_NIF_TERM nif_create_empty_msg_std_msgs__msg__Int16(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  void* res;
  ERL_NIF_TERM ret;

  res = enif_alloc_resource(rt_void,sizeof(std_msgs__msg__Int16));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  return ret;
}

ERL_NIF_TERM nif_init_msg_std_msgs__msg__Int16(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }
  void* res;
  ERL_NIF_TERM ret;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res)) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);

  std_msgs__msg__Int16__init((std_msgs__msg__Int16*) res);
  return ret;

}

ERL_NIF_TERM nif_setdata_std_msgs__msg__Int16(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 2) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  std_msgs__msg__Int16* res;
  int data = 0;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[1],&data)) {
    return enif_make_badarg(env);
  }

  res = (std_msgs__msg__Int16*) res_tmp;
  res->data = data;
  return enif_make_atom(env,"ok");
}

ERL_NIF_TERM nif_readdata_std_msgs__msg__Int16(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  std_msgs__msg__Int16* res;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }

  res = (std_msgs__msg__Int16*) res_tmp;
  return enif_make_int(env,res->data);
}

#ifdef __cplusplus
}
#endif

