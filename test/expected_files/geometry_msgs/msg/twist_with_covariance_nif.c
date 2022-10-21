#include <erl_nif.h>

#ifdef DASHING
#include <rosidl_generator_c/message_type_support_struct.h>
#define __STRING__ASSIGN rosidl_generator_c__String__assign
#define __U16STRING__ASSIGN rosidl_generator_c__U16String__assign_from_char
#elif FOXY
#include <rosidl_runtime_c/message_type_support_struct.h>
#define __STRING__ASSIGN rosidl_runtime_c__String__assign
#define __U16STRING__ASSIGN rosidl_runtime_c__U16String__assign_from_char
#endif

#include <geometry_msgs/msg/twist_with_covariance.h>
#include "pkgs/geometry_msgs/msg/twist_with_covariance_nif.h"
#include "total_nif.h"

ERL_NIF_TERM nif_get_typesupport_geometry_msgs_msg_twist_with_covariance(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  void* res;
  rosidl_message_type_support_t** res_ts;
  ERL_NIF_TERM ret;

  res = enif_alloc_resource(rt_void,sizeof(rosidl_message_type_support_t*));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  res_ts = (rosidl_message_type_support_t**) res;
  *res_ts = ROSIDL_GET_MSG_TYPE_SUPPORT(geometry_msgs,msg,TwistWithCovariance);
  return ret;
}

ERL_NIF_TERM nif_create_empty_msg_geometry_msgs_msg_twist_with_covariance(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  void* res;
  ERL_NIF_TERM ret;

  res = enif_alloc_resource(rt_void,sizeof(geometry_msgs__msg__TwistWithCovariance));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  return ret;
}

ERL_NIF_TERM nif_init_msg_geometry_msgs_msg_twist_with_covariance(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }
  void* res;
  ERL_NIF_TERM ret;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res)) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);

  geometry_msgs__msg__TwistWithCovariance__init((geometry_msgs__msg__TwistWithCovariance*) res);
  return ret;

}

ERL_NIF_TERM nif_setdata_geometry_msgs_msg_twist_with_covariance(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 2) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  geometry_msgs__msg__TwistWithCovariance* res;
  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }
  res = (geometry_msgs__msg__TwistWithCovariance*) res_tmp;
int data_arity;
const ERL_NIF_TERM* data;
if(!enif_get_tuple(env,argv[1],&data_arity,&data)) {
  return enif_make_badarg(env);
}
if(data_arity != 2) {
  return enif_make_badarg(env);
}
int data_0_arity;
const ERL_NIF_TERM* data_0;
if(!enif_get_tuple(env,data[0],&data_0_arity,&data_0)) {
  return enif_make_badarg(env);
}
if(data_0_arity != 2) {
  return enif_make_badarg(env);
}
int data_0_0_arity;
const ERL_NIF_TERM* data_0_0;
if(!enif_get_tuple(env,data_0[0],&data_0_0_arity,&data_0_0)) {
  return enif_make_badarg(env);
}
if(data_0_0_arity != 3) {
  return enif_make_badarg(env);
}
double data_0_0_0;
if(!enif_get_double(env,data_0_0[0],&data_0_0_0)) {
  return enif_make_badarg(env);
}
res->twist.linear.x = data_0_0_0;
double data_0_0_1;
if(!enif_get_double(env,data_0_0[1],&data_0_0_1)) {
  return enif_make_badarg(env);
}
res->twist.linear.y = data_0_0_1;
double data_0_0_2;
if(!enif_get_double(env,data_0_0[2],&data_0_0_2)) {
  return enif_make_badarg(env);
}
res->twist.linear.z = data_0_0_2;
int data_0_1_arity;
const ERL_NIF_TERM* data_0_1;
if(!enif_get_tuple(env,data_0[1],&data_0_1_arity,&data_0_1)) {
  return enif_make_badarg(env);
}
if(data_0_1_arity != 3) {
  return enif_make_badarg(env);
}
double data_0_1_0;
if(!enif_get_double(env,data_0_1[0],&data_0_1_0)) {
  return enif_make_badarg(env);
}
res->twist.angular.x = data_0_1_0;
double data_0_1_1;
if(!enif_get_double(env,data_0_1[1],&data_0_1_1)) {
  return enif_make_badarg(env);
}
res->twist.angular.y = data_0_1_1;
double data_0_1_2;
if(!enif_get_double(env,data_0_1[2],&data_0_1_2)) {
  return enif_make_badarg(env);
}
res->twist.angular.z = data_0_1_2;
unsigned data_1_length;
if(!enif_get_list_length(env,data[1],&data_1_length) || data_1_length != 36) {
  return enif_make_badarg(env);
} 
ERL_NIF_TERM data_1_list = data[1];
ERL_NIF_TERM data_1_head;
ERL_NIF_TERM data_1_tail;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_0;
if(!enif_get_double(env,data_1_head,&data_1_0)) {
  return enif_make_badarg(env);
}
res->covariance[0] = data_1_0;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_1;
if(!enif_get_double(env,data_1_head,&data_1_1)) {
  return enif_make_badarg(env);
}
res->covariance[1] = data_1_1;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_2;
if(!enif_get_double(env,data_1_head,&data_1_2)) {
  return enif_make_badarg(env);
}
res->covariance[2] = data_1_2;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_3;
if(!enif_get_double(env,data_1_head,&data_1_3)) {
  return enif_make_badarg(env);
}
res->covariance[3] = data_1_3;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_4;
if(!enif_get_double(env,data_1_head,&data_1_4)) {
  return enif_make_badarg(env);
}
res->covariance[4] = data_1_4;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_5;
if(!enif_get_double(env,data_1_head,&data_1_5)) {
  return enif_make_badarg(env);
}
res->covariance[5] = data_1_5;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_6;
if(!enif_get_double(env,data_1_head,&data_1_6)) {
  return enif_make_badarg(env);
}
res->covariance[6] = data_1_6;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_7;
if(!enif_get_double(env,data_1_head,&data_1_7)) {
  return enif_make_badarg(env);
}
res->covariance[7] = data_1_7;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_8;
if(!enif_get_double(env,data_1_head,&data_1_8)) {
  return enif_make_badarg(env);
}
res->covariance[8] = data_1_8;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_9;
if(!enif_get_double(env,data_1_head,&data_1_9)) {
  return enif_make_badarg(env);
}
res->covariance[9] = data_1_9;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_10;
if(!enif_get_double(env,data_1_head,&data_1_10)) {
  return enif_make_badarg(env);
}
res->covariance[10] = data_1_10;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_11;
if(!enif_get_double(env,data_1_head,&data_1_11)) {
  return enif_make_badarg(env);
}
res->covariance[11] = data_1_11;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_12;
if(!enif_get_double(env,data_1_head,&data_1_12)) {
  return enif_make_badarg(env);
}
res->covariance[12] = data_1_12;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_13;
if(!enif_get_double(env,data_1_head,&data_1_13)) {
  return enif_make_badarg(env);
}
res->covariance[13] = data_1_13;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_14;
if(!enif_get_double(env,data_1_head,&data_1_14)) {
  return enif_make_badarg(env);
}
res->covariance[14] = data_1_14;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_15;
if(!enif_get_double(env,data_1_head,&data_1_15)) {
  return enif_make_badarg(env);
}
res->covariance[15] = data_1_15;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_16;
if(!enif_get_double(env,data_1_head,&data_1_16)) {
  return enif_make_badarg(env);
}
res->covariance[16] = data_1_16;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_17;
if(!enif_get_double(env,data_1_head,&data_1_17)) {
  return enif_make_badarg(env);
}
res->covariance[17] = data_1_17;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_18;
if(!enif_get_double(env,data_1_head,&data_1_18)) {
  return enif_make_badarg(env);
}
res->covariance[18] = data_1_18;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_19;
if(!enif_get_double(env,data_1_head,&data_1_19)) {
  return enif_make_badarg(env);
}
res->covariance[19] = data_1_19;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_20;
if(!enif_get_double(env,data_1_head,&data_1_20)) {
  return enif_make_badarg(env);
}
res->covariance[20] = data_1_20;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_21;
if(!enif_get_double(env,data_1_head,&data_1_21)) {
  return enif_make_badarg(env);
}
res->covariance[21] = data_1_21;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_22;
if(!enif_get_double(env,data_1_head,&data_1_22)) {
  return enif_make_badarg(env);
}
res->covariance[22] = data_1_22;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_23;
if(!enif_get_double(env,data_1_head,&data_1_23)) {
  return enif_make_badarg(env);
}
res->covariance[23] = data_1_23;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_24;
if(!enif_get_double(env,data_1_head,&data_1_24)) {
  return enif_make_badarg(env);
}
res->covariance[24] = data_1_24;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_25;
if(!enif_get_double(env,data_1_head,&data_1_25)) {
  return enif_make_badarg(env);
}
res->covariance[25] = data_1_25;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_26;
if(!enif_get_double(env,data_1_head,&data_1_26)) {
  return enif_make_badarg(env);
}
res->covariance[26] = data_1_26;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_27;
if(!enif_get_double(env,data_1_head,&data_1_27)) {
  return enif_make_badarg(env);
}
res->covariance[27] = data_1_27;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_28;
if(!enif_get_double(env,data_1_head,&data_1_28)) {
  return enif_make_badarg(env);
}
res->covariance[28] = data_1_28;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_29;
if(!enif_get_double(env,data_1_head,&data_1_29)) {
  return enif_make_badarg(env);
}
res->covariance[29] = data_1_29;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_30;
if(!enif_get_double(env,data_1_head,&data_1_30)) {
  return enif_make_badarg(env);
}
res->covariance[30] = data_1_30;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_31;
if(!enif_get_double(env,data_1_head,&data_1_31)) {
  return enif_make_badarg(env);
}
res->covariance[31] = data_1_31;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_32;
if(!enif_get_double(env,data_1_head,&data_1_32)) {
  return enif_make_badarg(env);
}
res->covariance[32] = data_1_32;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_33;
if(!enif_get_double(env,data_1_head,&data_1_33)) {
  return enif_make_badarg(env);
}
res->covariance[33] = data_1_33;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_34;
if(!enif_get_double(env,data_1_head,&data_1_34)) {
  return enif_make_badarg(env);
}
res->covariance[34] = data_1_34;
if(!enif_get_list_cell(env,data_1_list,&data_1_head,&data_1_tail)) {
  return enif_make_badarg(env);
}
data_1_list = data_1_tail;
double data_1_35;
if(!enif_get_double(env,data_1_head,&data_1_35)) {
  return enif_make_badarg(env);
}
res->covariance[35] = data_1_35;

  return enif_make_atom(env,"ok");
}

ERL_NIF_TERM nif_readdata_geometry_msgs_msg_twist_with_covariance(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  geometry_msgs__msg__TwistWithCovariance* res;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }
  res = (geometry_msgs__msg__TwistWithCovariance*) res_tmp;
  return enif_make_tuple(env,2,
  enif_make_tuple(env,2,
  enif_make_tuple(env,3,
  enif_make_double(env,res->twist.linear.x),
  enif_make_double(env,res->twist.linear.y),
  enif_make_double(env,res->twist.linear.z)),
  enif_make_tuple(env,3,
  enif_make_double(env,res->twist.angular.x),
  enif_make_double(env,res->twist.angular.y),
  enif_make_double(env,res->twist.angular.z))),
  enif_make_list(env,36,
  enif_make_double(env,res->covariance[0]),
  enif_make_double(env,res->covariance[1]),
  enif_make_double(env,res->covariance[2]),
  enif_make_double(env,res->covariance[3]),
  enif_make_double(env,res->covariance[4]),
  enif_make_double(env,res->covariance[5]),
  enif_make_double(env,res->covariance[6]),
  enif_make_double(env,res->covariance[7]),
  enif_make_double(env,res->covariance[8]),
  enif_make_double(env,res->covariance[9]),
  enif_make_double(env,res->covariance[10]),
  enif_make_double(env,res->covariance[11]),
  enif_make_double(env,res->covariance[12]),
  enif_make_double(env,res->covariance[13]),
  enif_make_double(env,res->covariance[14]),
  enif_make_double(env,res->covariance[15]),
  enif_make_double(env,res->covariance[16]),
  enif_make_double(env,res->covariance[17]),
  enif_make_double(env,res->covariance[18]),
  enif_make_double(env,res->covariance[19]),
  enif_make_double(env,res->covariance[20]),
  enif_make_double(env,res->covariance[21]),
  enif_make_double(env,res->covariance[22]),
  enif_make_double(env,res->covariance[23]),
  enif_make_double(env,res->covariance[24]),
  enif_make_double(env,res->covariance[25]),
  enif_make_double(env,res->covariance[26]),
  enif_make_double(env,res->covariance[27]),
  enif_make_double(env,res->covariance[28]),
  enif_make_double(env,res->covariance[29]),
  enif_make_double(env,res->covariance[30]),
  enif_make_double(env,res->covariance[31]),
  enif_make_double(env,res->covariance[32]),
  enif_make_double(env,res->covariance[33]),
  enif_make_double(env,res->covariance[34]),
  enif_make_double(env,res->covariance[35])));
}
