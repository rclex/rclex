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
    (void)memset(&res_names_and_types[0],NULL,sizeof(rcl_names_and_types_t));
    res = rcl_get_topic_names_and_types(res_arg_node, res_alloc, false, res_names_and_types);
    
    int names_length = res_names_and_types->names.size;
    ERL_NIF_TERM *names_array = enif_alloc(sizeof(ERL_NIF_TERM) * names_length);
    for(int i = 0; i < names_length; i++) {
        names_array[i] = enif_make_string(env, res_names_and_types->names.data[i], ERL_NIF_LATIN1);
    }
    int types_length = res_names_and_types->types->size;
    ERL_NIF_TERM **types_array = enif_alloc(sizeof(ERL_NIF_TERM *) * names_length);
    for(int i = 0; i < names_length; i++){
        types_array[i] =  
        enif_alloc(sizeof(ERL_NIF_TERM) * types_length);
    }
    for(int i = 0; i < names_length; i++) {
        for(int j = 0; j < types_length; j++){
            types_array[i][j] = enif_make_string(env, res_names_and_types->types[i].data[j], ERL_NIF_LATIN1);
        }
    }
    return enif_make_tuple2(
        env,
        enif_make_list_from_array(
            env, 
            names_array,
            names_length
        ),
        enif_make_list_from_array(
            env, 
            types_array,
            names_length
        )
    );
}

#ifdef __cplusplus
}
#endif