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

#include <std_msgs/msg/string.h>
#include "total_nif.h"
#include "std_msgs/msg/std_msgs__msg__String_nif.h"

ERL_NIF_TERM nif_get_typesupport_std_msgs__msg__String(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
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
  *res_ts = ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,String);
  return ret;
}

ERL_NIF_TERM nif_create_empty_msg_std_msgs__msg__String(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  void* res;
  ERL_NIF_TERM ret;

  res = enif_alloc_resource(rt_void,sizeof(std_msgs__msg__String));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  return ret;
}

ERL_NIF_TERM nif_init_msg_std_msgs__msg__String(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
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

  std_msgs__msg__String__init((std_msgs__msg__String*) res);
  return ret;

}

ERL_NIF_TERM nif_setdata_std_msgs__msg__String(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 3) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  std_msgs__msg__String* res;
  int str_size = 0;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[2],&str_size)) {
    return enif_make_badarg(env);
  }
  char* data_buf = (char*) malloc(str_size);
  if(!enif_get_string(env,argv[1],data_buf,str_size,ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
  }

  res = (std_msgs__msg__String*) res_tmp;
  __STRING__ASSIGN(res,data_buf);
  free(data_buf);
  return enif_make_atom(env,"ok");
}

ERL_NIF_TERM nif_readdata_std_msgs__msg__String(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  std_msgs__msg__String* res;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }

  res = (std_msgs__msg__String*) res_tmp;
  return enif_make_string(env,res->data.data,ERL_NIF_LATIN1);
}

#ifdef __cplusplus
}
#endif

