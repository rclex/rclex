#ifdef __cplusplus
extern "C"
{
#endif

#include <erl_nif.h>

#include "init_nif.h"
//各種リソースタイプの宣言やリソースタイプの作成を行う
//------------------------nif_init.c-------------------
ErlNifResourceType* rt_ret;
ErlNifResourceType* rt_context;
ErlNifResourceType* rt_init_options;

//------------------------node_nif.cで追加--------------------
ErlNifResourceType* rt_node;
ErlNifResourceType* rt_node_options;

//-----------------------publisher_nif.cで追加-------------------
ErlNifResourceType* rt_pub;
ErlNifResourceType* rt_pub_options;
ErlNifResourceType* rt_rosidl_msg_type_support;
ErlNifResourceType* rt_rmw_pub_allocation;

//---------msg_int16_nif.c------------
ErlNifResourceType* rt_Int16;

ERL_NIF_TERM atom_ok;
ERL_NIF_TERM atom_true;
ERL_NIF_TERM atom_false;

//リソースタイプを作る．load()から呼び出される
int open_resource(ErlNifEnv* env);

//@on_loadで呼び出す
int load(ErlNifEnv* env, void** priv,ERL_NIF_TERM load_info);

int reload(ErlNifEnv* env,void** priv,ERL_NIF_TERM load_info);






#ifdef __cplusplus
}
#endif