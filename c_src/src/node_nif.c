
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

#define ROS_SECURITY_STRATEGY_VAR_NAME "ROS_SECURITY_STRATEGY"
#define ROS_SECURITY_ENABLE_VAR_NAME "ROS_SECURITY_ENABLE"
#define ROS_DOMAIN_ID_VAR_NAME "ROS_DOMAIN_ID"

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

ERL_NIF_TERM nif_rcl_node_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
   
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
/*
ERL_NIF_INIT(Elixir.RclEx.Node,nif_funcs,&load,&reload,NULL,NULL);
*/
#ifdef __cplusplus
}
#endif