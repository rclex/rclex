#!/bin/bash

msgtypename=$1
pkgname=${msgtypename%%/*}
typename=${msgtypename##*/}
typename_low=$(echo "$typename" | sed -e "s/\([A-Z]\)/_\L\1/g" -e "s/_//")
filename=${pkgname}/msg/${typename_low}
structname=${pkgname}__msg__${typename}

declare -A member_set
declare -A member_read

set_structmember()
{
local membertype=$1
local data=$2
local res=$3
local tmp=$4

if [[ $membertype =~ __msg__ ]]; then
setread_structmembers "$membertype" "$tmp" "$res."
cat << __DOC__
  int ${tmp}_arity;
  const ERL_NIF_TERM* ${tmp};
  if(!enif_get_tuple(env,${data},&${tmp}_arity,&${tmp})) {
    return enif_make_badarg(env);
  }
${member_set[$membertype]}
__DOC__

elif [ $membertype = "bool" ]; then
cat << __DOC__
  unsigned ${tmp};
  if(!enif_get_atom_length(env,${data},&${tmp},ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
  }
  if(${tmp} == 4) ${res} = true;
  else if(${tmp} == 5) ${res} = false;
__DOC__

elif [[ $membertype =~ int ]]; then
cat << __DOC__
  ${membertype} ${tmp};
  if(!enif_get_int(env,${data},&${tmp})) {
    return enif_make_badarg(env);
  }
  ${res} = ${tmp};
__DOC__

elif [[ $membertype =~ float|double ]]; then
cat << __DOC__
  ${membertype} ${tmp};
  if(!enif_get_double(env,${data},&${tmp})) {
    return enif_make_badarg(env);
  }
  ${res} = ${tmp};
__DOC__

elif [ $membertype = "rosidl_runtime_c__String" ]; then
cat << __DOC__
  unsigned ${tmp}_length;
  if(!enif_get_list_length(env,${data},&${tmp}_length)) {
    return enif_make_badarg(env);
  }
  char* ${tmp} = (char*) malloc(${tmp}_length + 1);
  if(!enif_get_string(env,${data},${tmp},${tmp}_length + 1,ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
  }
  __STRING__ASSIGN(&(${res}),${tmp});
  free(${tmp});
__DOC__

elif [ $membertype = "rosidl_runtime_c__U16String" ]; then
cat << __DOC__
  unsigned ${tmp}_length;
  if(!enif_get_list_length(env,${data},&${tmp}_length)) {
    return enif_make_badarg(env);
  }
  char* ${tmp} = (char*) malloc(${tmp}_length + 1);
  if(!enif_get_string(env,${data},${tmp},${tmp}_length + 1,ERL_NIF_LATIN1)) {
    return enif_make_badarg(env);
	  }
  __U16STRING__ASSIGN(&(${data}),${tmp});
  free(${tmp});
__DOC__

fi
}

read_structmember()
{
local membertype=$1
local res=$2

if [[ $membertype =~ __msg__ ]]; then
setread_structmembers "$membertype" "$tmp" "$res."
cat << __DOC__
    ${member_read[$membertype]}
__DOC__

elif [ $membertype = "bool" ]; then
cat <<< "    enif_make_atom(env,(${res}?\"true\":\"false\"))"

elif [[ $membertype =~ int ]]; then
cat <<< "    enif_make_int(env,${res})"

elif [[ $membertype =~ float|double ]]; then
cat <<< "    enif_make_double(env,${res})"

elif [ $membertype = "rosidl_runtime_c__String" ]; then
cat <<< "    enif_make_string(env,${res}.data,ERL_NIF_LATIN1)"

elif [ $membertype = "rosidl_runtime_c__U16String" ]; then
cat <<< "    enif_make_string(env,(char*)(${res}.data),ERL_NIF_LATIN1)"

fi
}

setread_structmembers() 
{
# argument : structname, tuplename, resourcename
	local structname=$1
	local pkgname=${structname%%__*}
	local typename=${structname##*__}
	local typename_low=$(echo "$typename" | sed -e "s/\([A-Z]\)/_\L\1/g" -e "s/_//")
	local pkgdir=$(ros2 pkg prefix ${pkgname})
	local dec=false
	local i=0
	local membertype
	local membername
	local arraynumber
	local data=$2
	local res=$3
	member_set[$structname]=$()
	member_read[$structname]=$()

	while read line
	do
		if [ "$line" = "} ${structname};" ]; then
			break
		elif [ "$line" = "typedef struct ${structname}" ]; then
			dec=true
		elif ${dec} && [ "$line" != "{" ]; then
			membertype=$(echo "${line% *}" | sed -e "s/ //g")
			membername=$(echo "${line##* }" | sed -e "s/;//")

			if [[ $membername =~ \[.*\] ]]; then
				arraynumber=$(echo "$membername" | sed -e "s/^.*\[\(.*\)\]$/\1/")
				membername=$(echo "$membername" | sed -e "s/^\(.*\)\[.*\]$/\1/")
				member_set[$structname]=$(cat <<- __DOC__
					${member_set[$structname]}
					  unsigned ${data}_${i}_length;
					  if(!enif_get_list_length(env,${data}[${i}],&${data}_${i}_length) || ${data}_${i}_length != ${arraynumber}) {
					    return enif_make_badarg(env);
					  } 
					  ERL_NIF_TERM ${data}_${i}_list = ${data}[${i}];
					  ERL_NIF_TERM ${data}_${i}_head;
					  ERL_NIF_TERM ${data}_${i}_tail;
				__DOC__
				)
				member_read[$structname]=$(cat <<- __DOC__
					${member_read[$structname]},
					    enif_make_list(env,${arraynumber}
				__DOC__
				)
				for j in `seq 0 $(($arraynumber - 1))`; do
					member_set[$structname]=$(cat <<- __DOC__
						${member_set[$structname]}
						  if(!enif_get_list_cell(env,${data}_${i}_list,&${data}_${i}_head,&${data}_${i}_tail)) {
						    return enif_make_badarg(env);
						  }
						  ${data}_${i}_list = ${data}_${i}_tail;
						$(set_structmember "$membertype" "${data}_${i}_head" "${res}${membername}[${j}]" "${data}_${i}_${j}")
					__DOC__
					)
					member_read[$structname]=$(cat <<- __DOC__
						${member_read[$structname]},
						$(read_structmember "$membertype" "${res}${membername}[${j}]")
					__DOC__
					)
				done
				member_read[$structname]=$(cat <<- __DOC__
					${member_read[$structname]})
				__DOC__
				)
			else
				member_set[$structname]=$(cat <<- __DOC__
					${member_set[$structname]}
					$(set_structmember "$membertype" "${data}[${i}]" "${res}${membername}" "${data}_${i}")
				__DOC__
				)
				member_read[$structname]=$(cat <<- __DOC__
					${member_read[$structname]},
					$(read_structmember "$membertype" "${res}${membername}")
				__DOC__
				)
			fi
			let i++
		fi
	done < ${pkgdir}/include/${pkgname}/msg/detail/${typename_low}__struct.h
	member_set[$structname]=$(cat <<- __DOC__
		  if(${data}_arity != ${i}) {
		    return enif_make_badarg(env);
		  }${member_set[$structname]}
	__DOC__
	)
	member_read[$structname]=$(cat <<- __DOC__
		enif_make_tuple(env,${i}${member_read[$structname]})
	__DOC__
	)	
}

setread_structmembers "$structname" "data" "res->"

cat << __DOC__ > src/${filename}_nif.c
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
  const ERL_NIF_TERM* data;
  if(!enif_get_tuple(env,argv[1],&data_arity,&data)) {
    return enif_make_badarg(env);
  }
${member_set[$structname]}
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
  return ${member_read[$structname]};
}
__DOC__

exit 0
