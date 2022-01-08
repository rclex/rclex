#!/bin/bash

create_implementation=$2

msgtypename=$1
pkgname=${msgtypename%%/*}
pkgname_upp=$(echo "$pkgname" | sed -e "s/\(.\)/\U\1/" -e "s/_\(.\)/\U\1/g")
typename=${msgtypename##*/}
typename_low=$(echo "$typename" | sed -e "s/\([A-Z]\)/_\L\1/g" -e "s/_//")
filename=${pkgname}/msg/${typename_low}
structname=${pkgname}__msg__${typename}
modulename=${pkgname_upp}.Msg.${typename}

declare -A member_define
declare -A member_types
declare -A member_set
declare -A member_read
declare -A struct_return

typedef_structmember()
{
local membertype=$1
if [ $membertype = "bool" ]; then
	echo "boolean"
elif [[ $membertype =~ int ]]; then
	echo "integer"
elif [[ $membertype =~ float|double ]]; then
	echo "float"
elif [[ $membertype =~ rosidl_runtime_c__(U16)?String ]]; then
	echo "[integer]"
elif [[ $membertype =~ __msg__ ]]; then
	echo "${member_types[$membertype]}"
fi
}

setread_structmembers()
{
	local structname=$1
	local pkgname=${structname%%__*}
	local pkgname_upp=$(echo "$pkgname" | sed -e "s/\(.\)/\U\1/" -e "s/_\(.\)/\U\1/g")
	local typename=${structname##*__}
	local typename_low=$(echo "$typename" | sed -e "s/\([A-Z]\)/_\L\1/g" -e "s/_//")
	local modulename=${pkgname_upp}.Msg.${typename}
	local pkgdir=$(ros2 pkg prefix ${pkgname})
	local dec=false
	local i=0
	local membertype
	local membername
	local arraynumber
	local data=$2
	local tmp=$3

	member_define[$1]=$()
	member_types[$1]=$()
	member_set[$1]=$()
	member_read[$1]=$()
	struct_return[$1]=$()
	while read line
	do
		if [ "$line" = "} ${structname};" ]; then
			break
		elif [ "$line" = "typedef struct ${structname}" ]; then
			dec=true
		elif ${dec} && [ "$line" != "{" ]; then
			membertype=$(echo "${line% *}" | sed -e "s/ //g")
			membername=$(echo "${line##* }" | sed -e "s/;//")

			if [[ $membertype =~ __msg__ ]]; then
				setread_structmembers "$membertype" "${data}.${membername}" "${tmp}_${i}"
				membertype_msgtypename=$(echo "$membertype" | sed -e "s/__/\//g")
				mkdir -p lib/rclex/${membertype_msgtypename%/*}
				bash lib/rclex/msgtype_tmp.sh ${membertype_msgtypename} false
				if [[ $membername =~ \[.*\] ]]; then
					arraynumber=$(echo "$membername" | sed -e "s/^.*\[\(.*\)\]$/\1/")
					membername=$(echo "$membername" | sed -e "s/^\(.*\)\[.*\]$/\1/")
					member_define[$1]+="${membername}: nil, "
					member_types[$1]+="${membername}: [$(typedef_structmember "$membertype")], "
					member_set[$1]+="["
					member_read[$1]+="["
					struct_return[$1]+="${membername}: ["
					for j in `seq 0 $(($arraynumber - 1))`
					do
						member_set[$1]+=$(echo "${member_set[$membertype]}, " | sed -e "s/${data}.${membername}/Enum.at(${data}.${membername},${j})/g")
						member_read[$1]+=$(echo "${member_read[$membertype]}, " | sed -e "s/${tmp}_${i}/${tmp}_${i}_${j}/g")
						struct_return[$1]+=$(echo "${struct_return[$membertype]}, " | sed -e "s/${tmp}_${i}/${tmp}_${i}_${j}/g")
					done
					member_set[$1]+="${member_set[$1]%, }]"
					member_read[$1]+="${member_read[$1]%, }]"
					struct_return[$1]+="${struct_return[$1]%, }]"
				else
					member_define[$1]+="${membername}: ${member_define[$membertype]}, "
					member_types[$1]+="${membername}: $(typedef_structmember "$membertype"), "
					member_set[$1]+="${member_set[$membertype]}, "
					member_read[$1]+="${member_read[$membertype]}, "
					struct_return[$1]+="${membername}: ${struct_return[$membertype]}, "
				fi
			else
				if [[ $membername =~ \[.*\] ]]; then
					membername=$(echo "$membername" | sed -e "s/^\(.*\)\[.*\]$/\1/")
					member_types[$1]+="${membername}: [$(typedef_structmember "$membertype")], "
				else
					member_types[$1]+="${membername}: $(typedef_structmember "$membertype"), "
				fi
				member_define[$1]+="${membername}: nil, "
				member_set[$1]+="${data}.${membername}, "
				member_read[$1]+="${tmp}_${i}, "
				struct_return[$1]+="${membername}: ${tmp}_${i}, "
			fi
			let i++
		fi	
	done < ${pkgdir}/include/${pkgname}/msg/detail/${typename_low}__struct.h
	member_define[$1]="%Rclex.${modulename}{${member_define[$1]%, }}"
	member_types[$1]="%Rclex.${modulename}{${member_types[$1]%, }}"
	member_set[$1]="{${member_set[$1]%, }}"
	member_read[$1]="{${member_read[$1]%, }}"
	struct_return[$1]="%Rclex.${modulename}{${struct_return[$1]%, }}"
}

setread_structmembers "$structname" "data" "data"

cat << __DOC__ > lib/rclex/${filename}.ex
defmodule Rclex.${modulename} do
  defstruct $(echo ${member_define[$structname]} | sed -e "s/^%Rclex.${modulename}{\(.*\)}$/\1/")
  @type t :: ${member_types[$structname]}
end
__DOC__

if $create_implementation; then
cat << __DOC__ > lib/rclex/${filename}_impl.ex
defimpl Rclex.MsgProt, for: Rclex.${modulename} do
  alias Rclex.Nifs, as: Nifs

  def typesupport(_) do
    Nifs.get_typesupport_${structname}()
  end
  def initialize(_) do
    Nifs.create_empty_msg_${structname}()
    |> Nifs.init_msg_${structname}()
  end
  def set(data, msg) do
    Nifs.setdata_${structname}(msg, ${member_set[$structname]})
  end
  def read(_, msg) do
    ${member_read[$structname]} = Nifs.readdata_${structname}(msg)
    ${struct_return[$structname]}
  end
end
__DOC__
fi

exit 0
