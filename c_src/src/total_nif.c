#ifdef __cplusplus
extern "C"
{
#endif
#include "../include/total_nif.h"

//リソースタイプを作る．load()から呼び出される.各種nifファイルから見れるようstaticつけない
int open_resource(ErlNifEnv* env){
    const char* mod = "Elixir.RclEx";
    const char* modinit = "Elixir.RclEx.Init";
    const char* modnode = "Elixir.RclEx.Node";
    const char* modpub = "Elixir.RclEx.Publisher";
    const char* modsub = "Elixir.RclEx.Subscription";
    //for init_nif.c
    const char* name1 = "rcl_ret_t";
    const char* name2 = "rcl_context_t";
    const char* name3 = "rcl_init_options_t";
    //for node_nif.c
    const char* name4 = "rcl_node_t";
    const char* name5 = "rcl_node_options_t";
    
    //for publisher_nif.c
    const char* name6 = "rcl_publisher_t";
    const char* name7 = "rcl_publisher_options_t";
    const char* name8 = "rosidl_message_type_support_t";
    const char* name9 = "rmw_publisher_allocation_t";

    //for subscription_nif.c
    const char* namesub1 = "rcl_subscription_t";
    const char* namesub2 = "rcl_subscription_options_t";
    const char* namesub3 = "rmw_message_info_t";
    const char* namesub4 = "rmw_subscription_allocation_t";
    //for msg
    const char* namemsg1 = "std_msgs__msg__Int16";

    int flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;

    //RES_TYPE = enif_open_resource_type(env,mod,name,free_res,flags,NULL);
    rt_ret          = enif_open_resource_type(env,mod,name1,NULL,flags,NULL);
    rt_context      = enif_open_resource_type(env,mod,name2,NULL,flags,NULL);
    rt_init_options = enif_open_resource_type(env,mod,name3,NULL,flags,NULL);
    
    rt_node         = enif_open_resource_type(env,mod,name4,NULL,flags,NULL);
    rt_node_options = enif_open_resource_type(env,mod,name5,NULL,flags,NULL);
    
    rt_pub          = enif_open_resource_type(env,mod,name6,NULL,flags,NULL);
    rt_pub_options  = enif_open_resource_type(env,mod,name7,NULL,flags,NULL);
    rt_rosidl_msg_type_support = enif_open_resource_type(env,mod,name8,NULL,flags,NULL);
    rt_rmw_pub_allocation = enif_open_resource_type(env,mod,name9,NULL,flags,NULL);
    
    rt_sub          = enif_open_resource_type(env,mod,namesub1,NULL,flags,NULL);
    rt_sub_options  = enif_open_resource_type(env,mod,namesub2,NULL,flags,NULL);
    rt_msginfo      = enif_open_resource_type(env,mod,namesub3,NULL,flags,NULL);
    rt_sub_alloc    = enif_open_resource_type(env,mod,namesub4,NULL,flags,NULL);
    rt_Int16 = enif_open_resource_type(env,mod,namemsg1,NULL,flags,NULL);

    //1〜5まで
    if(rt_node == NULL || rt_ret == NULL || rt_node_options == NULL || rt_context == NULL || rt_init_options == NULL) return -1;
    return 0;
}

//@on_loadで呼び出す
int load(ErlNifEnv* env, void** priv,ERL_NIF_TERM load_info){
    if(open_resource(env) == -1) return -1;

    atom_ok = enif_make_atom(env,"ok");
    atom_true = enif_make_atom(env,"true");
    atom_false = enif_make_atom(env,"false");
    return 0;
}

int reload(ErlNifEnv* env,void** priv,ERL_NIF_TERM load_info){
    if(open_resource(env) == -1) return -1;
    return 0;
}

ErlNifFunc nif_funcs[] = {
    //-----------init_nif.c-----------
    {"rcl_get_zero_initialized_init_options",0,nif_rcl_get_zero_initialized_init_options},
    {"rcl_init_options_init",1,nif_rcl_init_options_init},
    {"rcl_get_zero_initialized_context",0,nif_rcl_get_zero_initialized_context},
    {"rcl_init",4,nif_rcl_init},
    {"rcl_init_with_null",2,nif_rcl_init_with_null},
    {"rcl_shutdown",1,nif_rcl_shutdown},
    {"nif_read_context",1,nif_read_context},
    //--------------node_nif.c--------------
    {"rcl_get_zero_initialized_node",0,nif_rcl_get_zero_initialized_node},
    {"rcl_node_get_default_options",0,nif_rcl_node_get_default_options},
    {"rcl_node_init",5,nif_rcl_node_init},
    {"express_node_init",0,express_node_init},
    {"rcl_node_fini",1,nif_rcl_node_fini},
    //--------------publisher_nif.c-------------
    
    {"rcl_get_zero_initialized_publisher",0,nif_rcl_get_zero_initialized_publisher},
    {"rcl_publisher_get_default_options",0,nif_rcl_publisher_get_default_options},
    {"rcl_publisher_get_topic_name",1,nif_rcl_publisher_get_topic_name},
    {"rcl_publisher_fini",2,nif_rcl_publisher_fini},
    {"rcl_publisher_init",5,nif_rcl_publisher_init},
    {"rcl_publisher_is_valid",1,nif_rcl_publisher_is_valid},
    {"rcl_publish",2,nif_rcl_publish},

    //---------------subscription_nif.c-------------
    {"rcl_get_zero_initialized_subscription",0,nif_rcl_get_zero_initialized_subscription},
    {"rcl_subscription_get_default_options",0,nif_rcl_subscription_get_default_options},
    {"rcl_subscription_init",5,nif_rcl_subscription_init},
    {"rcl_subscription_fini",2,nif_rcl_subscription_fini},
    {"rcl_take",4,nif_rcl_take},
    //---------------msg_int16_nif.c-----------
    
    {"std_msgs__msg__Int16__init",1,nif_std_msgs__msg__Int16__init},
    {"std_msgs__msg__Int16__destroy",1,nif_std_msgs__msg__Int16__destroy},
    {"get_message_type_from_std_msgs_msg_Int16",0,nif_getmsgtype_int16},
    
};

/*
#ifndef _MSC_VER
#if defined (__SUNPRO_C) && (__SUNPRO_C >= 0x550)
__global
#elif defined __GNUC__
__attribute__ ((visibility("default")))
#endif
*/
ERL_NIF_INIT(Elixir.RclEx,nif_funcs,&load,&reload,NULL,NULL);
#ifdef __cplusplus
}
#endif