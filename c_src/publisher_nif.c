#ifdef __cplusplus
extern "C"
{
#endif
#include <erl_nif.h>
#include "total_nif.h"
#include "publisher_nif.h"
#include <stdio.h>
#include <string.h>

#include "rcl/publisher.h"
//#include "rcl/allocator.h"
//#include "rcl/error_handling.h"
//#include "rcl/expand_topic_name.h"
//#include "rcl/remap.h"
//#include "rcutils/logging.h"
//#include "rmw/error_handling.h"
//#include "rmw/validate_full_topic_name.h"
//#include "tracetools/tracetools.h"

//#include "./common.h"
//#include "./publisher_impl.h"

ERL_NIF_TERM nif_rcl_get_zero_initialized_publisher(ErlNifEnv* env,int argc,const ERL_NIF_TERM argv[]){
    rcl_publisher_t* res;
    ERL_NIF_TERM ret;
    res = enif_alloc_resource(rt_pub,sizeof(rcl_publisher_t));
    if(res == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res);
    enif_release_resource(res);
    *res = rcl_get_zero_initialized_publisher();

    return ret;
}

ERL_NIF_TERM nif_rcl_publisher_get_default_options(ErlNifEnv* env,int argc,const ERL_NIF_TERM argv[]){
  rcl_publisher_options_t* res;
  ERL_NIF_TERM ret;
  res = enif_alloc_resource(rt_pub_options,sizeof(rcl_publisher_options_t));
  if(res == NULL) return enif_make_badarg(env);
  ret = enif_make_resource(env,res);
  enif_release_resource(res);
  *res = rcl_publisher_get_default_options();

  return ret;
}


ERL_NIF_TERM nif_rcl_publisher_get_topic_name(ErlNifEnv* env,int argc,const ERL_NIF_TERM argv[]){
  rcl_publisher_t* res;
  if(argc != 1){
      return enif_make_badarg(env);
  }

  if(!enif_get_resource(env,argv[0],rt_pub,(void**) &res)){
      return enif_make_badarg(env);
  }
  const char* result;
  result = rcl_publisher_get_topic_name(res);
  return enif_make_string(env,result,ERL_NIF_LATIN1);
}


ERL_NIF_TERM nif_rcl_publisher_fini(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  rcl_ret_t* res;
  ERL_NIF_TERM ret;

  rcl_publisher_t* res_arg_pub;
  rcl_node_t* res_arg_node;

  if(argc != 2)
  {
      return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[0], rt_pub, (void**) &res_arg_pub))
  {
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[1], rt_node, (void**) &res_arg_node))
  {
    return enif_make_badarg(env);
  }

  res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
  if(res == NULL) return enif_make_badarg(env);
  ret = enif_make_resource(env,res);
  enif_release_resource(res);
  
  *res = rcl_publisher_fini(res_arg_pub,res_arg_node);
  
  return ret;
} 

//rcl_publisher_init(
//   rcl_publisher_t * publisher,
//   const rcl_node_t * node,
//   const rosidl_message_type_support_t * type_support,
//   const char * topic_name,
//   const rcl_publisher_options_t * options);

ERL_NIF_TERM nif_rcl_publisher_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc != 5){
        return enif_make_badarg(env);
  }
  rcl_ret_t* res_return;
  ERL_NIF_TERM ret;
  rcl_publisher_t*  res_pub;
  rcl_node_t* res_node;
  rosidl_message_type_support_t* res_idl;
  rcl_publisher_options_t* res_options;
  printf("0\n");
  if(!enif_get_resource(env, argv[0], rt_pub, (void**) &res_pub))
  {
    return enif_make_badarg(env);
  }
  printf("1\n");
  if(!enif_get_resource(env, argv[1], rt_node, (void**) &res_node))
  {
    return enif_make_badarg(env);
  }
  printf("2\n");
  if(!enif_get_resource(env, argv[2], rt_rosidl_msg_type_support, (void**) &res_idl))
  {
    return enif_make_badarg(env);
  }
  printf("3\n");
  char buf[128]; //トピック名を格納するためのバッファ
  (void)memset(&buf,'\0',sizeof(buf));
  if(!enif_get_string(env,argv[3],buf,sizeof(buf),ERL_NIF_LATIN1)){
    return enif_make_badarg(env);
  }
  printf("4\n");
  if(!enif_get_resource(env, argv[4], rt_pub_options, (void**) &res_options))
  {
    return enif_make_badarg(env);
  }
  printf("5\n");
  //各構造体ポインタそれぞれについて，alloc_resource
  res_return = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
  if(res_return == NULL) return enif_make_badarg(env);
  
  ret = enif_make_resource(env,res_return);
  enif_release_resource(res_return);
  printf("6\n");
  *res_return = rcl_publisher_init(res_pub,res_node,res_idl,buf,res_options);
  return ret;
}


ERL_NIF_TERM nif_rcl_publisher_is_valid(ErlNifEnv* env,int argc,const ERL_NIF_TERM argv[]){
  rcl_publisher_t* res;
  if(argc != 1){
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[0], rt_pub, (void**) &res))
  {
    return enif_make_badarg(env);
  }

  bool result;
  result = rcl_publisher_is_valid(res);
  if(result == true){
    return atom_true;
  }
  else return atom_false;
}


ERL_NIF_TERM nif_rcl_publish(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  rcl_ret_t* res;
  ERL_NIF_TERM ret;

  rcl_publisher_t* res_arg_pub;
  const void * ros_message; //void*にはどんな型でも入って，使う場合に任意の型にキャストする．
  rmw_publisher_allocation_t* res_arg_puballoc;

  if(argc != 3)
  {
      return enif_make_badarg(env);
  }

  if(!enif_get_resource(env, argv[0], rt_pub, (void**) &res_arg_pub))
  {
    return enif_make_badarg(env);
  }
  
  if(!enif_get_resource(env, argv[2], rt_rmw_pub_allocation, (void**) &res_arg_puballoc))
  {
    return enif_make_badarg(env);
  }

  res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
  if(res == NULL) return enif_make_badarg(env);
  
  ret = enif_make_resource(env,res);
  enif_release_resource(res);
  
  *res = rcl_publish(res_arg_pub,ros_message,res_arg_puballoc);
  
  return ret;
}

/*
static ERL_NIF_INIT(Elixir.RclEx.Publisher,nif_funcs,&load,&reload,NULL,NULL);
*/
#ifdef __cplusplus
}
#endif