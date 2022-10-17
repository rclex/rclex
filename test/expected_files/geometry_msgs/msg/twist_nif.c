#include <erl_nif.h>

#ifdef DASHING
#include <rosidl_generator_c/message_type_support_struct.h>
#define __STRING__ASSIGN rosidl_generator_c__String__assign
#define __U16STRING__ASSIGN rosidl_generator_c__U16String__assign_from_char
#elif FOXY
#include <rosidl_runtime_c/message_type_support_struct.h>
#define __STRING__ASSIGN rosidl_runtime_c__String__assign
#define __U16STRING__ASSIGN rosidl_runtime_c__U16String__assign_from_char
#endif

#include <geometry_msgs/msg/twist.h>
#include "geometry_msgs/msg/twist_nif.h"
#include "total_nif.h"

ERL_NIF_TERM nif_get_typesupport_geometry_msgs_msg_twist(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
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
  *res_ts = ROSIDL_GET_MSG_TYPE_SUPPORT(geometry_msgs,msg,Twist);
  return ret;
}

ERL_NIF_TERM nif_create_empty_msg_geometry_msgs_msg_twist(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  void* res;
  ERL_NIF_TERM ret;

  res = enif_alloc_resource(rt_void,sizeof(geometry_msgs__msg__Twist));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  return ret;
}

ERL_NIF_TERM nif_init_msg_geometry_msgs_msg_twist(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
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

  geometry_msgs__msg__Twist__init((geometry_msgs__msg__Twist*) res);
  return ret;

}

ERL_NIF_TERM nif_setdata_geometry_msgs_msg_twist(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 2) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  geometry_msgs__msg__Twist* res;
  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }
  res = (geometry_msgs__msg__Twist*) res_tmp;
  int data_arity;
  const ERL_NIF_TERM* data;
  if(!enif_get_tuple(env,argv[1],&data_arity,&data)) {
    return enif_make_badarg(env);
  }
  if(data_arity != 2) {
    return enif_make_badarg(env);
  }
  int data_0_arity;
  const ERL_NIF_TERM* data_0;
  if(!enif_get_tuple(env,data[0],&data_0_arity,&data_0)) {
    return enif_make_badarg(env);
  }
  if(data_0_arity != 3) {
    return enif_make_badarg(env);
  }
  double data_0_0;
  if(!enif_get_double(env,data_0[0],&data_0_0)) {
    return enif_make_badarg(env);
  }
  res->linear.x = data_0_0;
  double data_0_1;
  if(!enif_get_double(env,data_0[1],&data_0_1)) {
    return enif_make_badarg(env);
  }
  res->linear.y = data_0_1;
  double data_0_2;
  if(!enif_get_double(env,data_0[2],&data_0_2)) {
    return enif_make_badarg(env);
  }
  res->linear.z = data_0_2;
  int data_1_arity;
  const ERL_NIF_TERM* data_1;
  if(!enif_get_tuple(env,data[1],&data_1_arity,&data_1)) {
    return enif_make_badarg(env);
  }
  if(data_1_arity != 3) {
    return enif_make_badarg(env);
  }
  double data_1_0;
  if(!enif_get_double(env,data_1[0],&data_1_0)) {
    return enif_make_badarg(env);
  }
  res->angular.x = data_1_0;
  double data_1_1;
  if(!enif_get_double(env,data_1[1],&data_1_1)) {
    return enif_make_badarg(env);
  }
  res->angular.y = data_1_1;
  double data_1_2;
  if(!enif_get_double(env,data_1[2],&data_1_2)) {
    return enif_make_badarg(env);
  }
  res->angular.z = data_1_2;
  return enif_make_atom(env,"ok");
}

ERL_NIF_TERM nif_readdata_geometry_msgs_msg_twist(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  geometry_msgs__msg__Twist* res;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }
  res = (geometry_msgs__msg__Twist*) res_tmp;
  return enif_make_tuple(env,2,
    enif_make_tuple(env,3,
    enif_make_double(env,res->linear.x),
    enif_make_double(env,res->linear.y),
    enif_make_double(env,res->linear.z)),
    enif_make_tuple(env,3,
    enif_make_double(env,res->angular.x),
    enif_make_double(env,res->angular.y),
    enif_make_double(env,res->angular.z)));
}
