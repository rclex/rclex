#ifdef __cplusplus
extern "C"
{
#endif
#include <erl_nif.h>
#include "total_nif.h"
#include "subscription_nif.h"
#include <stdio.h>
#include <string.h>

#include "rcl/subscription.h"
#include "rmw/types.h"

#ifdef DASHING
#include <rosidl_generator_c/message_type_support_struct.h>
#elif FOXY
#include <rosidl_runtime_c/message_type_support_struct.h>
#endif

#include <std_msgs/msg/int16.h>
#include <std_msgs/msg/string.h>
ERL_NIF_TERM nif_rcl_get_zero_initialized_subscription(ErlNifEnv* env,int argc,const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  rcl_subscription_t* res;
  ERL_NIF_TERM ret;
  res = enif_alloc_resource(rt_sub,sizeof(rcl_subscription_t));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);
  *res = rcl_get_zero_initialized_subscription();

  return ret;
}

ERL_NIF_TERM nif_rcl_subscription_get_default_options(ErlNifEnv* env,int argc,const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  rcl_subscription_options_t* res;
  ERL_NIF_TERM ret;
  res = enif_alloc_resource(rt_sub_options,sizeof(rcl_subscription_options_t));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);
  *res = rcl_subscription_get_default_options();
  return ret;
}

/*
  rcl_ret_t
  rcl_subscription_init(
    rcl_subscription_t * subscription,
    const rcl_node_t * node,
    const rosidl_message_type_support_t * type_support,
    const char * topic_name,
    const rcl_subscription_options_t * options
  );
*/
ERL_NIF_TERM nif_rcl_subscription_init(ErlNifEnv* env,int argc,const ERL_NIF_TERM argv[])
{
  int return_value;
  ERL_NIF_TERM ret;
  rcl_subscription_t*  res_sub;
  rcl_node_t* res_node;
  void* res_ts_tmp;
  rosidl_message_type_support_t** res_ts;
  rcl_subscription_options_t* res_sub_options;

  if(!enif_get_resource(env, argv[0], rt_sub, (void**) &res_sub)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[1], rt_node, (void**) &res_node)) {
    return enif_make_badarg(env);
  }

  char topic_buf[128]; //トピック名を格納するためのバッファ
  (void)memset(&topic_buf,'\0',sizeof(topic_buf));
  if(!enif_get_string(env,argv[2],topic_buf,sizeof(topic_buf),ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[3], rt_void, (void**) &res_ts_tmp)){
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[4], rt_sub_options, (void**) &res_sub_options)) {
    return enif_make_badarg(env);
  }

  res_ts = (rosidl_message_type_support_t**) res_ts_tmp;
  return_value = rcl_subscription_init(res_sub,res_node,*res_ts,topic_buf,res_sub_options);

  ret = enif_make_resource(env,res_sub);
  return ret;
}

/*
  rcl_ret_t
  rcl_subscription_fini(
    rcl_subscription_t * subscription,
    rcl_node_t * node
  );
*/

ERL_NIF_TERM nif_rcl_subscription_fini(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  rcl_ret_t* res;
  ERL_NIF_TERM ret;

  rcl_subscription_t* res_sub;
  rcl_node_t* res_node;

  if(argc != 2) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[0], rt_sub, (void**) &res_sub)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[1], rt_node, (void**) &res_node)) {
    return enif_make_badarg(env);
  }

  res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  *res = rcl_subscription_fini(res_sub,res_node);

  return ret;
}

ERL_NIF_TERM nif_rcl_subscription_get_topic_name(ErlNifEnv* env,int argc,const ERL_NIF_TERM argv[])
{
  rcl_subscription_t* res;
  if(argc != 1) {
    return enif_make_badarg(env);
  }

  if(!enif_get_resource(env,argv[0],rt_sub,(void**) &res)) {
    return enif_make_badarg(env);
  }
  const char* result;
  result = rcl_subscription_get_topic_name(res);
  return enif_make_string(env,result,ERL_NIF_LATIN1);
}

ERL_NIF_TERM nif_create_sub_alloc(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  rmw_subscription_allocation_t* res;
  ERL_NIF_TERM ret;
  res = enif_alloc_resource(rt_sub_alloc,sizeof(rmw_subscription_allocation_t));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  return ret;
}

/*
  rcl_ret_t
  rcl_take(
    const rcl_subscription_t * subscription,
    void * ros_message,
    rmw_message_info_t * message_info,
    rmw_subscription_allocation_t * allocation
  );
*/
ERL_NIF_TERM nif_rcl_take(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  int return_value = 100;
  rcl_subscription_t* res_sub;
  rmw_message_info_t* res_msginfo;
  rmw_subscription_allocation_t* res_sub_alloc;
  ERL_NIF_TERM ret,ret_sub,ret_msginfo,ret_sub_alloc;

  void * ros_message;

  if(argc != 4) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[0], rt_sub, (void**) &res_sub)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env,argv[1], rt_void, (void**) &ros_message)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[2], rt_msginfo, (void**) &res_msginfo)) {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[3], rt_sub_alloc, (void**) &res_sub_alloc)) {
    return enif_make_badarg(env);
  }

  return_value = rcl_take(res_sub,ros_message,res_msginfo,res_sub_alloc);
  ret_sub = enif_make_resource(env,res_sub);
  ret_msginfo = enif_make_resource(env,res_msginfo);
  ret_sub_alloc = enif_make_resource(env,res_sub_alloc);

  return enif_make_tuple4(env,enif_make_int(env,return_value),ret_sub,ret_msginfo,ret_sub_alloc);
}

#ifdef __cplusplus
}
#endif
