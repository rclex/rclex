#ifdef __cplusplus
extern "C"
{
#endif

#include <erl_nif.h>
#include <rcl/rcl.h>
#include <rosidl_generator_c/message_type_support_struct.h>

#include <std_msgs/msg/int16.h>

//test_reamp_integration.cppを参考

#include "../../include/total_nif.h"
//#include "../../include/msg/msg_types.h"
#include "../../include/msg/msg_int16_nif.h"
#include "rmw/types.h"

//空のInt16メッセージオブジェクトを作る関数
ERL_NIF_TERM nif_create_empty_int16(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 0){
        return enif_make_badarg(env);
    }
    std_msgs__msg__Int16* res;
    ERL_NIF_TERM ret;
    res = enif_alloc_resource(rt_Int16,sizeof(std_msgs__msg__Int16));
    if(res == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res);
    enif_release_resource(res);

    return ret;
}
//空のrmw_message_info_tリソースオブジェクトを作る関数
ERL_NIF_TERM nif_create_msginfo(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 0){
        return enif_make_badarg(env);
    }
    rmw_message_info_t* res;
    ERL_NIF_TERM ret;
    res = enif_alloc_resource(rt_msginfo,sizeof(rmw_message_info_t));
    if(res == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res);
    enif_release_resource(res);

    return ret;
}

ERL_NIF_TERM nif_std_msgs__msg__Int16__init(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 1){
        return enif_make_badarg(env);
    }

    std_msgs__msg__Int16* res_msg;
    if(!enif_get_resource(env, argv[0], rt_Int16, (void**) &res_msg)){
        return enif_make_badarg(env);
    }
    bool ret;
    ret = std_msgs__msg__Int16__init(res_msg); 
    if(!ret){
        return atom_false;
    }
    return atom_true;
}

ERL_NIF_TERM nif_std_msgs__msg__Int16__destroy(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 1){
        return enif_make_badarg(env);
    }
    std_msgs__msg__Int16* res_msg;
    ERL_NIF_TERM ret;
    if(!enif_get_resource(env,argv[0],rt_Int16,(void**)&res_msg)){
        return enif_make_badarg(env);
    }
    std_msgs__msg__Int16__destroy(res_msg);
    return atom_ok;
}

//メッセージ型を作る関数
ERL_NIF_TERM nif_getmsgtype_int16(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 0){
        return enif_make_badarg(env);
    }
    //ほんまはconstがいる
    //rosidl_message_type_support_t* res_tmp;
    rosidl_message_type_support_t** res_tmp;
    //const rosidl_message_type_support_t* res;
    ERL_NIF_TERM ret;
    
    res_tmp = enif_alloc_resource(rt_msg_type_support,sizeof(rosidl_message_type_support_t*));
    if(res_tmp == NULL) return enif_make_badarg(env);
    ret = enif_make_resource(env,res_tmp);
    enif_release_resource(res_tmp);
    *res_tmp = ROSIDL_GET_MSG_TYPE_SUPPORT(std_msgs,msg,Int16);
    return ret;
}
ERL_NIF_TERM nif_readdata_int16(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 1){
        return enif_make_badarg(env);
    }
    std_msgs__msg__Int16* res_msg;
    ERL_NIF_TERM ret;
    if(!enif_get_resource(env,argv[0],rt_Int16,(void**)&res_msg)){
        return enif_make_badarg(env);
    }
    return enif_make_tuple2(env,atom_ok,enif_make_int(env,res_msg->data));
}

//int16のdataに数値を入れる関数
ERL_NIF_TERM nif_setdata_int16(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[]){
    if(argc != 2){
        return enif_make_badarg(env);
    }
    std_msgs__msg__Int16* res_msg;
    int num = 0;
    ERL_NIF_TERM ret;
    if(!enif_get_resource(env,argv[0],rt_Int16,(void**)&res_msg)){
        return enif_make_badarg(env);
    }
    if(!enif_get_int(env,argv[1],&num)){
        return enif_make_badarg(env);
    }
    res_msg->data = num;
    return enif_make_atom(env,"ok");
}

#ifdef __cplusplus
}
#endif