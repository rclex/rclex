#!/bin/bash

if [ $# -ne 1 ]; then
  echo "bad argument number"
  exit 1
fi

msgtypename_list=(${1//\// })
pkgname=${msgtypename_list[0]}
pkgname_upp=$(echo "$pkgname" | sed -e "s/\(.\)/\U\1/" -e "s/_\(.\)/\U\1/g")
typename=${msgtypename_list[2]}
typename_low=$(echo "$typename" | sed -e "s/\([A-Z]\)/_\L\1/g" -e "s/_//")
filename=${pkgname}/msg/${typename_low}
structname=${pkgname}__msg__${typename}
modulename=${pkgname_upp}.Msg.${typename}

membername=()
membertype=()
while read line
do
        list=(${line})
        membertype+=(${list[0]})
        membername+=(${list[1]})
done < <(cat src/${pkgname}/msg/${typename}.msg)
membernumber=${#membername[@]}

structmembers=()
structtype=()
setstruct=()
readtuple=()
readstruct=()
for i in `seq 0 $(($membernumber - 1))`
do
if [ $i -eq $(($membernumber - 1)) ]; then
  delimiter=$()
else
  delimiter=,
fi
structmembers+=(${membername[$i]}: nil${delimiter})
if [ "${membertype[$i]}" = "string" ]; then
  structtype+=(${membername[$i]}: \[integer\]${delimiter})
elif [ "${membertype[$i]}" = "bool" ]; then
  structtype+=(${membername[$i]}: boolean${delimiter})
elif [[ ${membertype[$i]} =~ byte|char|^.*int.*$ ]]; then
  structtype+=(${membername[$i]}: float${delimiter})
elif [[ ${membertype[$i]} =~ float.*$ ]]; then
  structtype+=(${membername[$i]}: integer${delimiter})
fi
if [ ${membertype[$i]} = "string" ]; then
  setstruct+=(length\(data.${membername[$i]}\) + 1, data.${membername[$i]}${delimiter})
else
  setstruct+=(data.${membername[$i]}${delimiter})
fi
readtuple+=(${membername[$i]}${delimiter})
readstruct+=(${membername[$i]}: ${membername[$i]}${delimiter})
done


cat << __DOC__ > lib/rclex/${filename}.ex
defmodule Rclex.${modulename} do
  defstruct ${structmembers[@]}
  @type t :: %Rclex.${modulename}{${structtype[@]}}
end
__DOC__

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
    Nifs.setdata_${structname}(msg, {${setstruct[@]}})
  end
  def read(_, msg) do
    {${readtuple[@]}} = Nifs.readdata_${structname}(msg)
    %Rclex.${modulename}{${readstruct[@]}}
  end
end
__DOC__

exit 0
