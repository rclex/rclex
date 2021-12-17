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

#include <smp_msgs/msg/namenumber.h>
#include "total_nif.h"
#include "smp_msgs/msg/namenumber_nif.h"

ERL_NIF_TERM nif_get_typesupport_smp_msgs__msg__Namenumber(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
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
  *res_ts = ROSIDL_GET_MSG_TYPE_SUPPORT(smp_msgs,msg,Namenumber);
  return ret;
}

ERL_NIF_TERM nif_create_empty_msg_smp_msgs__msg__Namenumber(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  void* res;
  ERL_NIF_TERM ret;

  res = enif_alloc_resource(rt_void,sizeof(smp_msgs__msg__Namenumber));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  return ret;
}

ERL_NIF_TERM nif_init_msg_smp_msgs__msg__Namenumber(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
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

  smp_msgs__msg__Namenumber__init((smp_msgs__msg__Namenumber*) res);
  return ret;

}

ERL_NIF_TERM nif_setdata_smp_msgs__msg__Namenumber(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 4) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  smp_msgs__msg__Namenumber* res;
  int name_size = 0;
  int number = 0;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[2],&name_size)) {
    return enif_make_badarg(env);
  }
  char* name_buf = (char*) malloc(name_size);
  if(!enif_get_string(env,argv[1],name_buf,name_size,ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[3],&number)) {
    return enif_make_badarg(env);
  }

  res = (smp_msgs__msg__Namenumber*) res_tmp;
  __STRING__ASSIGN(&(res->name),name_buf);
  free(name_buf);
  res->number = number;
  return enif_make_atom(env,"ok");
}

ERL_NIF_TERM nif_readdata_smp_msgs__msg__Namenumber(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  smp_msgs__msg__Namenumber* res;
  ERL_NIF_TERM ret_name;
  ERL_NIF_TERM ret_number;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }

  res = (smp_msgs__msg__Namenumber*) res_tmp;
  ret_name = enif_make_string(env,res->name.data,ERL_NIF_LATIN1);
  ret_number = enif_make_int(env,res->number);
  return enif_make_tuple2(env,ret_name,ret_number);
}

#ifdef __cplusplus
}
#endif

