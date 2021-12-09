#ifdef __cplusplus
extern "C"
{
#endif

#include <erl_nif.h>
#include <rcl/rcl.h>
#ifdef DASHING
#include <rosidl_generator_c/message_type_support_struct.h>
#define __STRING__ASSIGN rosidl_generator_c__String__assign
#elif FOXY
#include <rosidl_runtime_c/message_type_support_struct.h>
#define __STRING__ASSIGN rosidl_runtime_c__String__assign
#endif

#include <std_msgs/msg/string.h>

#include "total_nif.h"
#include "msg_string_nif.h"
#include "rmw/types.h"


//空のStringメッセージオブジェクトを作る関数
ERL_NIF_TERM nif_create_empty_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
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

  return ret;
}

//init関数
ERL_NIF_TERM nif_string_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }
  ERL_NIF_TERM ret;
  void* res_msg;
  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_msg)) {
    return enif_make_badarg(env);
  }

  std_msgs__msg__String__init((std_msgs__msg__String *)res_msg);
  ret = enif_make_resource(env,res_msg);
  return ret;

}

//std_msgs__msg__Stringのdataに文字列を入れる関数
ERL_NIF_TERM nif_setdata_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 3) {
    return enif_make_badarg(env);
  }
  void* res_msg;
  ERL_NIF_TERM ret;
  int str_size = 0;
  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_msg)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[2],&str_size)) {
    return enif_make_badarg(env);
  }
  char* data_buf = (char*) malloc(str_size);   //この値がデータサイズの上限を変更する
  if(!enif_get_string(env,argv[1],data_buf,str_size,ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
  }
  //String型の構造体に引数の文字列とサイズを入れる．
  __STRING__ASSIGN((std_msgs__msg__String *)res_msg,data_buf);
  free(data_buf);
  return enif_make_atom(env,"ok");
}
ERL_NIF_TERM nif_readdata_string(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }
  void* res_msg;
  std_msgs__msg__String* res_msg_String;
  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_msg)) {
    return enif_make_badarg(env);
  }
  res_msg_String = (std_msgs__msg__String*)res_msg;
  return enif_make_string(env,res_msg_String->data.data,ERL_NIF_LATIN1);
}
#ifdef __cplusplus
}
#endif

