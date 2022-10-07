#ifdef __cplusplus
extern "C"
{
#endif

#include <erl_nif.h>

#include "init_nif.h"
#include "node_nif.h"
#include "publisher_nif.h"
#include "subscription_nif.h"
#include "wait_nif.h"
#include "graph_nif.h"
#include "msg_nif.h"
//-----<custom_msgtype>_nif.h-----start-----
#include "geometry_msgs/msg/twist_nif.h"
#include "std_msgs/msg/string_nif.h"
//-----<custom_msgtype>_nif.h-----end-----

//各種リソースタイプの宣言やリソースタイプの作成を行う
//------------------------nif_init.c-------------------
extern ErlNifResourceType *rt_ret;
extern ErlNifResourceType *rt_context;
extern ErlNifResourceType *rt_init_options;

//------------------------node_nif.cで追加--------------------
extern ErlNifResourceType *rt_node;
extern ErlNifResourceType *rt_node_options;

//-----------------------publisher_nif.cで追加-------------------
extern ErlNifResourceType *rt_pub;
extern ErlNifResourceType *rt_pub_options;
extern ErlNifResourceType *rt_msg_type_support;
extern ErlNifResourceType *rt_pub_alloc;
//----------------------subscription_nif.cで追加-------------------
extern ErlNifResourceType *rt_sub;
extern ErlNifResourceType *rt_sub_options;
extern ErlNifResourceType *rt_msginfo;
extern ErlNifResourceType *rt_sub_alloc;
//----------------------graph_nif.c------------
extern ErlNifResourceType *rt_names_and_types;
//-------------------wait_nif.cで追加------------------------
extern ErlNifResourceType *rt_default_alloc;
extern ErlNifResourceType *rt_waitset;
//--------------------<custom_msgtype>_nif.c--------------------
extern ErlNifResourceType *rt_void;

extern ERL_NIF_TERM atom_ok;
extern ERL_NIF_TERM atom_true;
extern ERL_NIF_TERM atom_false;

//リソースタイプを作る．load()から呼び出される
int open_resource(ErlNifEnv* env);

/* eliminate top-level warning
//@on_loadで呼び出す
static int load(ErlNifEnv* env, void** priv,ERL_NIF_TERM load_info);

static int reload(ErlNifEnv* env,void** priv,ERL_NIF_TERM load_info);

static int upgrade(ErlNifEnv* env, void** priv,void** old_priv,ERL_NIF_TERM load_info);

static void unload(ErlNifEnv* env, void* priv);
*/








#ifdef __cplusplus
}
#endif
