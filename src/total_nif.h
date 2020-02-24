#ifdef __cplusplus
extern "C"
{
#endif

#include <erl_nif.h>

#include "init_nif.h"
#include "node_nif.h"
#include "publisher_nif.h"
#include "msg_int16_nif.h"
#include "msg_string_nif.h"
#include "subscription_nif.h"
#include "wait_nif.h"

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
ErlNifResourceType* rt_msg_type_support;
ErlNifResourceType* rt_pub_alloc;
//----------------------subscription_nif.cで追加-------------------
ErlNifResourceType* rt_sub;
ErlNifResourceType* rt_sub_options;
ErlNifResourceType* rt_msginfo;
ErlNifResourceType* rt_sub_alloc;
//----------------------msg_int16_nif.c------------
ErlNifResourceType* rt_Int16;
//----------------------msg_string_nif.c---------------
ErlNifResourceType* rt_String;
//-------------------wait_nif.cで追加------------------------
ErlNifResourceType* rt_default_alloc;
ErlNifResourceType* rt_waitset;

ERL_NIF_TERM atom_ok;
ERL_NIF_TERM atom_true;
ERL_NIF_TERM atom_false;

//リソースタイプを作る．load()から呼び出される
int open_resource(ErlNifEnv* env);

//@on_loadで呼び出す
static int load(ErlNifEnv* env, void** priv,ERL_NIF_TERM load_info);

static int reload(ErlNifEnv* env,void** priv,ERL_NIF_TERM load_info);

static int upgrade(ErlNifEnv* env, void** priv,void** old_priv,ERL_NIF_TERM load_info);

static void unload(ErlNifEnv* env, void* priv);







#ifdef __cplusplus
}
#endif