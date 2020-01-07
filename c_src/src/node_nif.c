
#ifdef __cplusplus
extern "C"
{
#endif
#include <erl_nif.h>
#include "../include/total_nif.h"
#include "../include/node_nif.h"

#include <limits.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "rcl/rcl.h"



ERL_NIF_TERM nif_rcl_get_zero_initialized_node(ErlNifEnv* env,int argc,const ERL_NIF_TERM argv[]){
    rcl_node_t* res;
    ERL_NIF_TERM ret;
    
    if(argc != 0){
        return enif_make_badarg(env);
    }
    res = enif_alloc_resource(rt_node,sizeof(rcl_node_t));
    if(res == NULL) return enif_make_badarg(env);

    ret = enif_make_resource(env,res);
    enif_release_resource(res);
    
    *res = rcl_get_zero_initialized_node();

    return ret;
}
/*
    rcl_ret_t
    rcl_node_init(
  rcl_node_t * node,
  const char * name,
  const char * namespace_,
  rcl_context_t * context,
  const rcl_node_options_t * options);
*/
/*
ERL_NIF_TERM express_node_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    printf("express node init\n");
    if(argc != 0){   
        return enif_make_badarg(env);
    }

    rcl_ret_t* res_ret;
    rcl_init_options_t* res_init_options;
    rcl_context_t* res_context;  //rcl_initの引数でconstがついてない   
    rcl_node_options_t* res_node_options;
    rcl_node_t* res_node;
    ERL_NIF_TERM ret_context;
    ERL_NIF_TERM ret_ret;
    ERL_NIF_TERM ret_init_options;
    ERL_NIF_TERM ret_node_options;
    ERL_NIF_TERM ret_node;
    
    res_init_options = enif_alloc_resource(rt_init_options,sizeof(rcl_init_options_t));
    if(res_init_options == NULL) return enif_make_badarg(env);
    ret_init_options = enif_make_resource(env,res_init_options);
    enif_release_resource(res_init_options);
    
    res_context = enif_alloc_resource(rt_context,sizeof(rcl_context_t));
    if(res_context == NULL) return enif_make_badarg(env);
    ret_context = enif_make_resource(env,res_context);
    enif_release_resource(res_context);
    
    res_ret = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
    if(res_ret == NULL) return enif_make_badarg(env);
    ret_ret = enif_make_resource(env,res_ret);
    enif_release_resource(res_ret);

    res_node_options = enif_alloc_resource(rt_node_options,sizeof(rcl_node_options_t));
    if(res_node_options == NULL) return enif_make_badarg(env);
    ret_node_options = enif_make_resource(env,res_node_options);
    enif_release_resource(res_node_options);
    
    res_node = enif_alloc_resource(rt_node,sizeof(rcl_node_t));
    if(res_node == NULL) return enif_make_badarg(env);
    ret_node = enif_make_resource(env,res_node);
    enif_release_resource(res_node);
    char const* const* init_argv = "";
    printf("1\n");
    *res_init_options = rcl_get_zero_initialized_init_options();
     printf("2\n");
    *res_context = rcl_get_zero_initialized_context();
     printf("3\n");
    *res_ret = rcl_init(1,&init_argv[0],res_init_options,res_context);
     printf("4\n");
    *res_node_options = rcl_node_get_default_options();
     printf("5\n");
    *res_node = rcl_get_zero_initialized_node();
     printf("6\n");
    rcl_node_init(res_node,"nodename","namespace_",res_context,res_node_options);
    printf("finish node init\n");

    
    return enif_make_tuple1(env,atom_ok);
}
*/
ERL_NIF_TERM nif_rcl_node_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    printf("enter node_init\n");
    if(argc != 5){
        
        return enif_make_badarg(env);
    }
    
    rcl_ret_t* res;
    ERL_NIF_TERM ret;

    rcl_node_t* res_arg_node;
    rcl_context_t* res_arg_context;
    const rcl_node_options_t* res_arg_options;

    char name_buf[128];
    char namespace_buf[128];    
    (void)memset(&name_buf,'\0',sizeof(name_buf));
    (void)memset(&namespace_buf,'\0',sizeof(namespace_buf));
   
    if(!enif_get_resource(env, argv[0], rt_node, (void**) &res_arg_node)){
        return enif_make_badarg(env);
    }
   
    if(!enif_get_string(env,argv[1],name_buf,sizeof(name_buf),ERL_NIF_LATIN1)){
        return enif_make_badarg(env);
    }
    
    if(!enif_get_string(env,argv[2],name_buf,sizeof(namespace_buf),ERL_NIF_LATIN1)){
        return enif_make_badarg(env);
    }
   
    if(!enif_get_resource(env, argv[3], rt_context, (void**) &res_arg_context)){
        return enif_make_badarg(env);
    }
   
    if(!enif_get_resource(env, argv[4], rt_node_options, (void**) &res_arg_options)){
        return enif_make_badarg(env);
    }
   
    res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
    if(res == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res);
    enif_release_resource(res);
   
    *res = rcl_node_init(res_arg_node,name_buf,namespace_buf,res_arg_context,res_arg_options);
    
    return ret;
}

ERL_NIF_TERM nif_rcl_node_fini(ErlNifEnv* env,int argc,const ERL_NIF_TERM argv[]){
    if(argc != 1){
        return enif_make_badarg(env);
    }
    rcl_ret_t* res;
    ERL_NIF_TERM ret;

    rcl_node_t* res_arg_node;
    if(!enif_get_resource(env, argv[0], rt_node, (void**) &res_arg_node)){
        return enif_make_badarg(env);
    }
    res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
    if(res == NULL) return enif_make_badarg(env);
    res_arg_node = enif_alloc_resource(rt_node,sizeof(rcl_node_t));
    if(res_arg_node == NULL) return enif_make_badarg(env);

    ret = enif_make_resource(env,res);
    enif_release_resource(res);

    *res = rcl_node_fini(res_arg_node);
    return ret;
} 

ERL_NIF_TERM nif_rcl_node_get_default_options(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 0){
        return enif_make_badarg(env);
    }

    rcl_node_options_t* res;
    ERL_NIF_TERM ret;

    res = enif_alloc_resource(rt_node_options,sizeof(rcl_node_options_t));
    if(res == NULL) return enif_make_badarg(env);

    ret = enif_make_resource(env,res);
    enif_release_resource(res);
    
    *res = rcl_node_get_default_options();

    return ret;
    
}

ERL_NIF_TERM nif_read_guard_condition(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    rcl_node_t* res_node;
    if(!enif_get_resource(env, argv[0], rt_node, (void**) &res_node)){
	    return enif_make_badarg(env);
    }
    //return enif_make_tuple1(env,res_node->impl->graph_guard_condition->impl->allocated_rmw_guard_condition);
    //graph_guard_condition以降はnode.cで定義されてるものだからアクセスする必要がないってこと？
    return enif_make_atom(env,"ok");
}
/*
ERL_NIF_INIT(Elixir.RclEx.Node,nif_funcs,&load,&reload,NULL,NULL);
*/
#ifdef __cplusplus
}
#endif