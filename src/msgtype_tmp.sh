#!/bin/bash

if [ $# -ne 1 ]; then
  echo "bad argument number"
  exit 1
fi

msgtypename_list=(${1//\// })
pkgname=${msgtypename_list[0]}
typename=${msgtypename_list[2]}
typename_low=$(echo "$typename" | sed -e "s/\([A-Z]\)/_\L\1/g" -e "s/_//")
filename=${pkgname}/msg/${typename_low}
structname=${pkgname}__msg__${typename}

membername=()
membertype=()
datalength=0
while read line
do
	list=(${line})
	membertype+=(${list[0]})
	membername+=(${list[1]})
	if [ ${list[0]} = "string" ]; then
		let datalength++
	fi
done < <(cat src/${pkgname}/msg/${typename}.msg)
membernumber=${#membername[@]}
datalength=$(($datalength + $membernumber))

cat << __DOC__ > src/${filename}_nif.c
#include <erl_nif.h>

#ifdef DASHING
#include <rosidl_generator_c/message_type_support_struct.h>
#define __STRING__ASSIGN rosidl_generator_c__String__assign
#elif FOXY
#include <rosidl_runtime_c/message_type_support_struct.h>
#define __STRING__ASSIGN rosidl_runtime_c__String__assign
#endif

#include <${filename}.h>
#include "${filename}_nif.h"
#include "total_nif.h"

ERL_NIF_TERM nif_get_typesupport_${structname}(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
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
  *res_ts = ROSIDL_GET_MSG_TYPE_SUPPORT(${pkgname},msg,${typename});
  return ret;
}

ERL_NIF_TERM nif_create_empty_msg_${structname}(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 0) {
    return enif_make_badarg(env);
  }
  void* res;
  ERL_NIF_TERM ret;

  res = enif_alloc_resource(rt_void,sizeof(${structname}));
  if(res == NULL) {
    return enif_make_badarg(env);
  }
  ret = enif_make_resource(env,res);
  enif_release_resource(res);

  return ret;
}

ERL_NIF_TERM nif_init_msg_${structname}(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
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

  ${structname}__init((${structname}*) res);
  return ret;

}

ERL_NIF_TERM nif_setdata_${structname}(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 2) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  ${structname}* res;
  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }
  res = (${structname}*) res_tmp;
  int data_arity;
  const ERL_NIF_TERM* data_tuple;
  if(!enif_get_tuple(env,argv[1],&data_arity,&data_tuple) || data_arity != ${datalength}) {
    return enif_make_badarg(env);
  }
__DOC__
j=0
for i in `seq 0 $(($membernumber - 1))`
do
if [ "${membertype[$i]}" = "string" ]; then
  cat << __DOC__ >> src/${filename}_nif.c
  int data${i}_size;
  if(!enif_get_int(env,data_tuple[${j}],&data${i}_size)) {
    return enif_make_badarg(env);
  }
__DOC__
  let j++
  cat << __DOC__ >> src/${filename}_nif.c
  char* data${i} = (char*) malloc(data${i}_size);
  if(!enif_get_string(env,data_tuple[${j}],data${i},data${i}_size,ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
  }
  __STRING__ASSIGN(&(res->${membername[$i]}),data${i});
  free(data${i});
__DOC__
elif [ "${membertype[$i]}" = "bool" ]; then
  cat << __DOC__ >> src/${filename}_nif.c
  unsigned* data${i};
  if(!enif_get_atom_length(env,data_tuple[${j}],&data${i},ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
  }
  if(data${i} == 4) res->${membernumber[$i]} = true;
  else if (data${i} == 5) res->${membernumber[$i]} = false;
__DOC__
elif [[ ${membertype[$i]} =~ byte|char|^.*int.*$ ]]; then
  cat << __DOC__ >> src/${filename}_nif.c
  int data${i};
  if(!enif_get_int(env,data_tuple[${j}],&data${i})) {
    return enif_make_badarg(env);
  }
  res->${membername[$i]} = data${i};
__DOC__
elif [[ ${membertype[$i]} =~ float.*$ ]]; then
  cat << __DOC__ >> src/${filename}_nif.c
  double data${i};
  if(!enif_get_double(env,data_tuple[${j}],&data${i})) {
    return enif_make_badarg(env);
  }
  res->${membername[$i]} = data${i};
__DOC__
fi
let j++
done
cat << __DOC__ >> src/${filename}_nif.c
  return enif_make_atom(env,"ok");
}

ERL_NIF_TERM nif_readdata_${structname}(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
{
  if(argc != 1) {
    return enif_make_badarg(env);
  }
  void* res_tmp;
  ${structname}* res;

  if(!enif_get_resource(env,argv[0],rt_void,(void**)&res_tmp)) {
    return enif_make_badarg(env);
  }
  res = (${structname}*) res_tmp;
  return enif_make_tuple(env,${membernumber},
__DOC__
for i in `seq 0 $(($membernumber - 1))`
do
if [ $i -eq $(($membernumber - 1)) ]; then
  delimiter=\)\;
else
  delimiter=,
fi
if [ "${membertype[$i]}" = "string" ]; then
  echo "    enif_make_string(env,res->${membername[$i]}.data,ERL_NIF_LATIN1)${delimiter}" >> src/${filename}_nif.c
elif [ "${membertype[$i]}" = "bool" ]; then
  echo "    enif_make_atom(env,(res->${membername[$i]}?*\"true\":*\"false\"))${delimiter}" >> src/${filename}_nif.c
elif [[ ${membertype[$i]} =~ byte|char|^.*int.*$ ]]; then
  echo "    enif_make_int(env,res->${membername[$i]})${delimiter}" >> src/${filename}_nif.c
elif [[ ${membertype[$i]} =~ float.*$ ]]; then
  echo "    enif_make_double(env,res->${membername[$i]})${delimiter}" >> src/${filename}_nif.c
fi
done
echo "}" >> src/${filename}_nif.c

exit 0
