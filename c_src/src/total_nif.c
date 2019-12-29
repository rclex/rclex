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

    //for timer
    const char* namewait = "rcl_wait_set_t";
    int flags = ERL_NIF_RT_CREATE | ERL_NIF_RT_TAKEOVER;

    /*
    //リソースの解放処理を行う関数
    void free_ret(ErlNifEnv* env,void* arg){
        printf("free_resource_ret\n");
    }
    void free_context(ErlNifEnv* env,void* arg){
        printf("free_context\n");
    }
    void free_initoptions(ErlNifEnv* env,void* arg){
        printf("free_initoptions\n");
    }
    void free_node(ErlNifEnv* env,void* arg){
        printf("free_node:%p\n",arg);
    }
    void free_nodeoptions(ErlNifEnv* env,void* arg){
        printf("free_nodeoptions:%p\n",arg);
    }
    void free_pub(ErlNifEnv* env,void* arg){
        printf("free_pub:%p\n",arg);
    }
    void free_puboptions(ErlNifEnv* env,void* arg){
        printf("free_puboptions:%p\n",arg);
    }
    void free_msgtype_support(ErlNifEnv* env,void* arg){
        printf("free_msgtype_support:%p\n",arg);
    }
    void free_puballoc(ErlNifEnv* env,void* arg){
        printf("free_puballoc:%p\n",arg);
    }
    void free_sub(ErlNifEnv* env,void* arg){
        printf("free_sub:%p\n",arg);
    }
    void free_suboptions(ErlNifEnv* env,void* arg){
        printf("free_suboptions:%p\n",arg);
    }
    void free_msginfo(ErlNifEnv* env,void* arg){
        printf("free_msginfo:%p\n",arg);
    }
    void free_suballoc(ErlNifEnv* env,void* arg){
        printf("free_suballoc:%p\n",arg);
    }
    void free_int16(ErlNifEnv* env,void* arg){
        printf("free_int16:%p\n",arg);
    }
    void free_waitset(ErlNifEnv* env,void* arg){
        printf("free_waitset:%p\n",arg);
    }
    
    rt_ret          = enif_open_resource_type(env,mod,name1,free_ret,flags,NULL);
    rt_context      = enif_open_resource_type(env,mod,name2,free_context,flags,NULL);
    rt_init_options = enif_open_resource_type(env,mod,name3,free_initoptions,flags,NULL);
    rt_node         = enif_open_resource_type(env,mod,name4,free_node,flags,NULL);
    rt_node_options = enif_open_resource_type(env,mod,name5,free_nodeoptions,flags,NULL);
    
    rt_pub          = enif_open_resource_type(env,mod,name6,free_pub,flags,NULL);
    rt_pub_options  = enif_open_resource_type(env,mod,name7,free_puboptions,flags,NULL);
    rt_rosidl_msg_type_support = enif_open_resource_type(env,mod,name8,free_msgtype_support,flags,NULL);
    rt_rmw_pub_allocation = enif_open_resource_type(env,mod,name9,free_puballoc,flags,NULL);
    
    rt_sub          = enif_open_resource_type(env,mod,namesub1,free_sub,flags,NULL);
    rt_sub_options  = enif_open_resource_type(env,mod,namesub2,free_suboptions,flags,NULL);
    rt_msginfo      = enif_open_resource_type(env,mod,namesub3,free_msginfo,flags,NULL);
    rt_sub_alloc    = enif_open_resource_type(env,mod,namesub4,free_suballoc,flags,NULL);
    rt_Int16        = enif_open_resource_type(env,mod,namemsg1,free_int16,flags,NULL);
    rt_waitset      = enif_open_resource_type(env,mod,namewait,free_waitset,flags,NULL);
    */

    //RES_TYPE = enif_open_resource_type(env,mod,name,free_res,flags,NULL);
    rt_ret          = enif_open_resource_type(env,mod,name1,NULL,flags,NULL);
    rt_context      = enif_open_resource_type(env,mod,name2,NULL,flags,NULL);
    rt_init_options = enif_open_resource_type(env,mod,name3,NULL,flags,NULL);
    rt_node         = enif_open_resource_type(env,mod,name4,NULL,flags,NULL);
    rt_node_options = enif_open_resource_type(env,mod,name5,NULL,flags,NULL);
    
    rt_pub          = enif_open_resource_type(env,mod,name6,NULL,flags,NULL);
    rt_pub_options  = enif_open_resource_type(env,mod,name7,NULL,flags,NULL);
    rt_rosidl_msg_type_support = enif_open_resource_type(env,mod,name8,NULL,flags,NULL);
    rt_pub_alloc = enif_open_resource_type(env,mod,name9,NULL,flags,NULL);
    
    rt_sub          = enif_open_resource_type(env,mod,namesub1,NULL,flags,NULL);
    rt_sub_options  = enif_open_resource_type(env,mod,namesub2,NULL,flags,NULL);
    rt_msginfo      = enif_open_resource_type(env,mod,namesub3,NULL,flags,NULL);
    rt_sub_alloc    = enif_open_resource_type(env,mod,namesub4,NULL,flags,NULL);
    rt_Int16        = enif_open_resource_type(env,mod,namemsg1,NULL,flags,NULL);
    rt_waitset      = enif_open_resource_type(env,mod,namewait,NULL,flags,NULL);
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
    {"rcl_init_options_fini",1,nif_rcl_init_options_fini},
    {"rcl_get_zero_initialized_context",0,nif_rcl_get_zero_initialized_context},
    {"rcl_init_with_null",2,nif_rcl_init_with_null},
    {"rcl_shutdown",1,nif_rcl_shutdown},
    //{"nif_read_context",1,nif_read_context},
    //--------------node_nif.c--------------
    {"rcl_get_zero_initialized_node",0,nif_rcl_get_zero_initialized_node},
    {"rcl_node_get_default_options",0,nif_rcl_node_get_default_options},
    {"rcl_node_init",5,nif_rcl_node_init},
    //{"express_node_init",0,express_node_init},
    {"rcl_node_fini",1,nif_rcl_node_fini},
    {"read_guard_condition",1,nif_read_guard_condition},
    //--------------publisher_nif.c-------------
    
    {"rcl_get_zero_initialized_publisher",0,nif_rcl_get_zero_initialized_publisher},
    {"rcl_publisher_get_default_options",0,nif_rcl_publisher_get_default_options},
    {"rcl_publisher_get_topic_name",1,nif_rcl_publisher_get_topic_name},
    {"rcl_publisher_fini",2,nif_rcl_publisher_fini},
    {"rcl_publisher_init",4,nif_rcl_publisher_init},
    {"rcl_publisher_is_valid",1,nif_rcl_publisher_is_valid},
    {"rcl_publish",3,nif_rcl_publish},
    {"create_pub_alloc",0,nif_create_pub_alloc},

    //---------------subscription_nif.c-------------
    {"rcl_get_zero_initialized_subscription",0,nif_rcl_get_zero_initialized_subscription},
    {"rcl_subscription_get_default_options",0,nif_rcl_subscription_get_default_options},
    {"create_sub_alloc",0,nif_create_sub_alloc},
    {"rcl_subscription_init",4,nif_rcl_subscription_init},
    {"rcl_subscription_fini",2,nif_rcl_subscription_fini},
    {"rcl_subscription_get_topic_name",1,nif_rcl_subscription_get_topic_name},
    {"rcl_take",4,nif_rcl_take},
    //{"rcl_take_with_null",3,nif_rcl_take_with_null},
    //---------------msg_int16_nif.c-----------
    {"create_empty_msgInt16",0,nif_create_empty_msgInt16},
    {"create_msginfo",0,nif_create_msginfo},
    {"std_msgs__msg__Int16__init",1,nif_std_msgs__msg__Int16__init},
    {"std_msgs__msg__Int16__destroy",1,nif_std_msgs__msg__Int16__destroy},
    {"get_message_type_from_std_msgs_msg_Int16",0,nif_getmsgtype_int16},
    {"print_msg",1,nif_print_msg},
    {"set_data",2,nif_set_data},
    //----------------wait_nif.c-----------------
    {"rcl_get_zero_initialized_wait_set",0,nif_rcl_get_zero_initialized_wait_set},
    {"rcl_wait_set_init",8,nif_rcl_wait_set_init},
    {"rcl_wait_set_fini",1,nif_rcl_wait_set_fini},
    {"rcl_wait_set_add_subscription",2,nif_rcl_wait_set_add_subscription},
    {"rcl_wait",2,nif_rcl_wait},

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