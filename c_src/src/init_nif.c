#ifdef __cplusplus
extern "C"
{
#endif

#include <erl_nif.h>
#include "../include/init_nif.h"
#include "../include/total_nif.h"
#include <stdio.h>
#include "./arguments_impl.h"
#include "rcl/rcl.h"    //include先からcontext.hにたどり着く
#include "rcl/context.h"
#include "rcl/init_options.h"
#include "rcutils/allocator.h"

ERL_NIF_TERM nif_rcl_get_zero_initialized_init_options(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 0){
        return enif_make_badarg(env);
    }
    rcl_init_options_t* res;
    ERL_NIF_TERM ret;
    res = enif_alloc_resource(rt_init_options,sizeof(rcl_init_options_t));
    if(res == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res);
    enif_release_resource(res);

    *res = rcl_get_zero_initialized_init_options();
    
    return ret;
}

ERL_NIF_TERM nif_rcl_init_options_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 1){
        return enif_make_badarg(env);
    }
    rcl_init_options_t* res_init_options;
    rcl_ret_t* res_ret;
    ERL_NIF_TERM ret;
    if(!enif_get_resource(env, argv[0], rt_init_options, (void**) &res_init_options)){
        return enif_make_badarg(env);
    }
    
    res_ret = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
    if(res_ret == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res_ret);
    enif_release_resource(res_ret);
    *res_ret = rcl_init_options_init(res_init_options,rcutils_get_default_allocator());
    return enif_make_atom(env,"ok");
}

ERL_NIF_TERM nif_rcl_get_zero_initialized_context(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 0){
        return enif_make_badarg(env);
    }
    rcl_context_t* res;
    ERL_NIF_TERM ret;
    res = enif_alloc_resource(rt_context,sizeof(rcl_context_t));
    if(res == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res);
    enif_release_resource(res);

    *res = rcl_get_zero_initialized_context();

    return ret;
}

ERL_NIF_TERM nif_rcl_init_with_null(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    
    if(argc != 2){
        return enif_make_badarg(env);
    }

    rcl_ret_t* res;
    ERL_NIF_TERM ret;
    const rcl_init_options_t* res_options;
    rcl_context_t* res_context;  //rcl_initの引数でconstがついてない   
    
    if(!enif_get_resource(env, argv[0], rt_init_options, (void**) &res_options)){
	    return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[1], rt_context, (void**) &res_context)){
	    return enif_make_badarg(env);
    }
    res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
    if(res == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res);
    enif_release_resource(res);
    
   
    //ポインタも，その指し示す先もconst(変更不可)であることを示す
    
    //argc,argvに直接値を入れている
    *res = rcl_init(0,NULL,res_options,res_context);
    printf("finished rcl_init\n");
    return ret;
}

//return rcl_ret_t

ERL_NIF_TERM nif_rcl_init_options_fini(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 1){
        return enif_make_badarg(env);
    }
    rcl_ret_t* res;
    ERL_NIF_TERM ret;

    rcl_init_options_t* res_init_options;
    
    if(!enif_get_resource(env,argv[0],rt_init_options,(void**)&res_init_options)){
        return enif_make_badarg(env);
    }
     
    res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
    if(res == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res);
    enif_release_resource(res);
    *res = rcl_init_options_fini(res_init_options);

    return ret;

}
//コンテキストの中身を見る関数
/*
ERL_NIF_TERM nif_read_context(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    rcl_context_t* res_context;
    if(!enif_get_resource(env, argv[0], rt_context, (void**) &res_context)){
	    return enif_make_badarg(env);
    }
    return enif_make_int(env,res_context->global_arguments.impl->log_level);
}
*/
ERL_NIF_TERM nif_rcl_shutdown(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    printf("enter rcl_shutdown\n");
    if(argc != 1){
        return enif_make_badarg(env);
    }
    rcl_ret_t* res;
    ERL_NIF_TERM ret;

    rcl_context_t* res_arg_context;
    if(!enif_get_resource(env,argv[0],rt_context,(void**) &res_arg_context)){
        return enif_make_badarg(env);
    }
    res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
    if(res == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res);
    enif_release_resource(res);

    *res = rcl_shutdown(res_arg_context);

    return enif_make_tuple2(env,atom_ok,ret);
}
/*
ErlNifFunc nif_funcs[]={
    {"rcl_get_zero_initialized_init_options",0,nif_rcl_get_zero_initialized_init_options},
    {"rcl_get_zero_initialized_context",0,nif_rcl_get_zero_initialized_context},
    {"rcl_init",4,nif_rcl_init},
    {"rcl_shutdown",1,nif_rcl_shutdown},
};
ERL_NIF_INIT(Elixir.RclEx.Init,nif_funcs,&load,&reload,NULL,NULL);
*/
#ifdef __cplusplus
}
#endif