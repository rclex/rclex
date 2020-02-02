#ifdef __cplusplus
extern "C"
{
#endif

#include <erl_nif.h>

#include <stdio.h>
#include <stdlib.h>
#include "../include/total_nif.h"
#include "../include/wait_nif.h"

#include "rcl/wait.h"
#include "rcl/allocator.h"

//空のrcl_allocator_tを作成
ERL_NIF_TERM nif_rcl_get_default_allocator(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc!=0){
    return enif_make_badarg(env);
  }
  rcl_allocator_t *res;
  ERL_NIF_TERM ret;
  
  res = enif_alloc_resource(rt_default_alloc,sizeof(rcl_allocator_t));
  if(res == NULL) return enif_make_badarg(env);
  ret = enif_make_resource(env,res);
  //enif_release_resource(res);
  *res = rcl_get_default_allocator();
  return ret;
}
/*
//空のwaitsetを作成
ERL_NIF_TERM nif_create_empty_waitset(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc!=0){
    return enif_make_badarg(env);
  }
  rcl_wait_set_t *res;
  ERL_NIF_TERM ret;
  
  res = enif_alloc_resource(rt_waitset,sizeof(rcl_wait_set_t));
  if(res == NULL) return enif_make_badarg(env);
  ret = enif_make_resource(env,res);
  //enif_release_resource(res);

  return ret;
}
*/
//waitsetを作って初期化
ERL_NIF_TERM nif_rcl_get_zero_initialized_wait_set(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc != 0){
      return enif_make_badarg(env);
  }
  rcl_wait_set_t* res;
  ERL_NIF_TERM ret;
  res = enif_alloc_resource(rt_waitset,sizeof(rcl_wait_set_t));
  if(res == NULL) return enif_make_badarg(env);

  *res = rcl_get_zero_initialized_wait_set();
  ret = enif_make_resource(env,res);
  return ret;
}

/*
  rcl_ret_t
  rcl_wait_set_init(
    rcl_wait_set_t * wait_set,
    size_t number_of_subscriptions,
    size_t number_of_guard_conditions,
    size_t number_of_timers,
    size_t number_of_clients,
    size_t number_of_services,
    size_t number_of_events,
    rcl_context_t * context,
    rcl_allocator_t allocator);

*/
ERL_NIF_TERM nif_rcl_wait_set_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc != 9){
      return enif_make_badarg(env);
  }
  
  ERL_NIF_TERM ret;
  rcl_wait_set_t* res_waitset;
  rcl_context_t* res_context;
  rcl_allocator_t* res_alloc;
  if(!enif_get_resource(env, argv[0], rt_waitset, (void**) &res_waitset)){
      return enif_make_badarg(env);
  }
  int a = 0;
  int b = 0;
  int c = 0;
  int d = 0;
  int e = 0;
  int f = 0;


  if(!enif_get_int(env,argv[1],&a)){
        return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[2],&b)){
        return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[3],&c)){
        return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[4],&d)){
        return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[5],&e)){
        return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[6],&f)){
        return enif_make_badarg(env);
  }
  if(!enif_get_resource(env, argv[7], rt_context, (void**) &res_context)){
      return enif_make_badarg(env);
  }
  
  if(!enif_get_resource(env, argv[8], rt_default_alloc, (void**) &res_alloc)){
      return enif_make_badarg(env);
  }
  
  ret = enif_make_resource(env,res_waitset);

  size_t number_of_subscriptions = (size_t)a;
  size_t number_of_guard_conditions = (size_t)b;
  size_t number_of_timers = (size_t)c;
  size_t number_of_clients = (size_t)d;
  size_t number_of_services = (size_t)e;
  size_t number_of_events = (size_t)f;
  rcl_wait_set_init(res_waitset,number_of_subscriptions,number_of_guard_conditions,number_of_timers,number_of_clients,
                            number_of_services,number_of_events,res_context,*res_alloc);
  return ret;
}

//rcl_ret_t rcl_wait_set_fini(rcl_wait_set_t* wait_set)
ERL_NIF_TERM nif_rcl_wait_set_fini(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc != 1){
      return enif_make_badarg(env);
  }
  rcl_ret_t* res;
  ERL_NIF_TERM ret;
  rcl_wait_set_t* res_waitset;
  if(!enif_get_resource(env,argv[0],rt_waitset,(void**) &res_waitset)){
    return enif_make_badarg(env);
  }
  res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
  if(res == NULL) return enif_make_badarg(env);
  
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  *res = rcl_wait_set_fini(res_waitset);

  return ret;
}
/*
  rcl_ret_t
  rcl_wait_set_add_subscription(
    rcl_wait_set_t * wait_set,
    const rcl_subscription_t * subscription,
    size_t * index);
*/
ERL_NIF_TERM nif_rcl_wait_set_clear(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc != 1){
    return enif_make_badarg(env);
  }
  rcl_ret_t* res;
  ERL_NIF_TERM ret;
  rcl_wait_set_t* res_waitset;
  if(!enif_get_resource(env,argv[0],rt_waitset,(void**) &res_waitset)){
    return enif_make_badarg(env);
  }
  res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
  if(res == NULL) return enif_make_badarg(env);
  ret = enif_make_resource(env,res);
  enif_release_resource(res);
  
  *res = rcl_wait_set_clear(res_waitset);
  return ret;
}

ERL_NIF_TERM nif_rcl_wait_set_add_subscription(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc != 2){
      return enif_make_badarg(env);
  }
  rcl_ret_t* res;
  ERL_NIF_TERM ret;
  rcl_wait_set_t* res_waitset;
  rcl_subscription_t* res_sub;

  if(!enif_get_resource(env,argv[0],rt_waitset,(void**) &res_waitset)){
    return enif_make_badarg(env);
  }
  if(!enif_get_resource(env,argv[1],rt_sub,(void**) &res_sub)){
    return enif_make_badarg(env);
  }
  
  res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
  if(res == NULL) return enif_make_badarg(env);
  ret = enif_make_resource(env,res);
  enif_release_resource(res);
  *res = rcl_wait_set_add_subscription(res_waitset,res_sub,NULL);
  
  return ret;

}
/*
  rcl_ret_t
  rcl_wait(rcl_wait_set_t * wait_set, int64_t timeout);
*/
ERL_NIF_TERM nif_rcl_wait(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc != 2){
      return enif_make_badarg(env);
  }
  rcl_ret_t* res;
  ERL_NIF_TERM ret;
  rcl_wait_set_t* res_waitset;
  int64_t timeout;
  if(!enif_get_resource(env,argv[0],rt_waitset,(void**) &res_waitset)){
    return enif_make_badarg(env);
  }
  if(!enif_get_int64(env,argv[1],&timeout)){
    return enif_make_badarg(env);
  }
  res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
  if(res == NULL) return enif_make_badarg(env);
  ret = enif_make_resource(env,res);
  enif_release_resource(res);
  *res = rcl_wait(res_waitset,RCL_MS_TO_NS(timeout));

  return ret;

}

ERL_NIF_TERM nif_check_subscription_another(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc != 1){
      return enif_make_badarg(env);
  }
  rcl_subscription_t* res_sub;
  if(!enif_get_resource(env,argv[0],rt_sub,(void**) &res_sub)){
    return enif_make_badarg(env);
  }
  if(res_sub){
    return enif_make_atom(env,"true");
  }else{
    return enif_make_atom(env,"false");
  }
}

ERL_NIF_TERM nif_check_subscription(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc != 2){
      return enif_make_badarg(env);
  }
  rcl_wait_set_t* res_waitset;
  int index = 0;
  if(!enif_get_resource(env,argv[0],rt_waitset,(void**) &res_waitset)){
    return enif_make_badarg(env);
  }
  if(!enif_get_int(env,argv[1],&index)){
      return enif_make_badarg(env);
  }
  if(res_waitset->subscriptions[index]){
    return enif_make_atom(env,"true");
  }else{
    return enif_make_atom(env,"false");
  }
}

ERL_NIF_TERM nif_get_sublist_from_waitset(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
  if(argc != 1){
      return enif_make_badarg(env);
  }

  rcl_wait_set_t* res_waitset;
  rcl_subscription_t* res_sub;
  
  ERL_NIF_TERM* ret;
  if(!enif_get_resource(env,argv[0],rt_waitset,(void**) &res_waitset)){
    return enif_make_badarg(env);
  }
  
  int num_of_sub = 0;
  num_of_sub = res_waitset->size_of_subscriptions;
  //printf("num_of_sub:%d\n",num_of_sub);
  ret = (ERL_NIF_TERM *)malloc(num_of_sub*sizeof(ERL_NIF_TERM));
  for(int i=0;i<num_of_sub;i++){
    //res_waitset->subscriptions[i] = enif_alloc_resource(rt_sub,sizeof(rcl_subscription_t));
    //↑が悪さをしてたっぽい
    //if(*(res_waitset->subscriptions[i]) == NULL) return enif_make_badarg(env);
    ret[i] = enif_make_resource(env,(res_waitset->subscriptions[i]));
  }
  return enif_make_list_from_array(env,ret,num_of_sub);
  free(ret);
}

#ifdef __cplusplus
}
#endif