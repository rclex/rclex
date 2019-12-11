#ifdef __cplusplus
extern "C"
{
#endif

#include <erl_nif.h>
#include "../include/init_nif.h"
#include "../include/total_nif.h"
#include <stdio.h>

#include "rcl/rcl.h"    //include先からcontext.hにたどり着く


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

ERL_NIF_TERM nif_rcl_init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    
    if(argc != 4){
        return enif_make_badarg(env);
    }

    rcl_ret_t* res;
    ERL_NIF_TERM ret;
    int argcval;
    char argv_buf[1024];    
    (void)memset(&argv_buf, '\0', sizeof(argv_buf));
    const rcl_init_options_t* res_arg_options;
    rcl_context_t* res_arg_context;
    if(!enif_get_int(env,argv[0],&argcval)){
        return enif_make_badarg(env);
    }
    if(!enif_get_string(env,argv[1],argv_buf,sizeof(argv_buf),ERL_NIF_LATIN1)){
        return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[2], rt_init_options, (void**) &res_arg_options)){
	    return enif_make_badarg(env);
    }
    if(!enif_get_resource(env, argv[3], rt_context, (void**) &res_arg_context)){
	    return enif_make_badarg(env);
    }
    res = enif_alloc_resource(rt_ret,sizeof(rcl_ret_t));
    if(res == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res);
    enif_release_resource(res);
    
   
    //ポインタも，その指し示す先もconst(変更不可)であることを示す
    *res = rcl_init(argcval,(const char * const *)argv_buf,res_arg_options,res_arg_context);
    
    return ret;
}


ERL_NIF_TERM nif_rcl_shutdown(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
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