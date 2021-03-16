#ifdef __cplusplus
extern "C"
{
#endif


#include <erl_nif.h>
#include "total_nif.h"
#include "graph_nif.h"

#include "rcl/rcl.h"
#include "rcl/graph.h"

/*
rcl_ret_t
rcl_get_topic_names_and_types(
   const rcl_node_t * node,
   rcl_allocator_t * allocator,
   bool no_demangle,
   rcl_names_and_types_t * topic_names_and_types);
*/
ERL_NIF_TERM nif_rcl_get_topic_names_and_types(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 3){
        printf("arg tarite naiyo\n");
        return enif_make_badarg(env);
    }
    int res;
    rcl_names_and_types_t * res_names_and_types;
    ERL_NIF_TERM ret;

    rcl_node_t* res_arg_node;
    rcl_allocator_t* res_alloc;
    char res_no_demangle[128];
    
    (void)memset(&res_no_demangle,'\0',sizeof(res_no_demangle));
   
    if(!enif_get_resource(env, argv[0], rt_node, (void**) &res_arg_node)){
        return enif_make_badarg(env);
    }

    if(!enif_get_resource(env, argv[1], rt_default_alloc, (void**) &res_alloc)){
        return enif_make_badarg(env);
    }
/*
    if(!enif_get_string(env, argv[2], res_no_demangle, sizeof(res_no_demangle),ERL_NIF_LATIN1)){
        return enif_make_badarg(env);
    }
*/
    
   
    bool no_demangle = res_no_demangle == "true";
    res_names_and_types = enif_alloc_resource(rt_names_and_types,sizeof(rcl_names_and_types_t));
    if(res_names_and_types == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res_names_and_types);
    res = rcl_get_topic_names_and_types(res_arg_node, res_alloc, false, res_names_and_types);
    
    int names_length = sizeof(res_names_and_types->names.data)/sizeof(res_names_and_types->names.data[0]);
    return enif_make_list_from_array(
        env, 
        res_names_and_types->names.data,
        names_length);
}

#ifdef __cplusplus
}
#endif