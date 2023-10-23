defmodule Rclex.Generators.MsgC do
  @moduledoc false

  alias Rclex.Generators.Util
  alias Rclex.Parsers.TypeParser

  @ros2_builtin_types [
    "bool",
    "byte",
    "char",
    "float32",
    "float64",
    "int8",
    "uint8",
    "int16",
    "uint16",
    "int32",
    "uint32",
    "int64",
    "uint64",
    "string",
    "wstring"
  ]

  def generate(type, ros2_message_type_map) do
    EEx.eval_file(Path.join(Util.templates_dir_path(), "msg_c.eex"),
      header_name: to_header_name(type),
      deps_header_prefix_list: to_deps_header_prefix_list(type, ros2_message_type_map),
      header_prefix: to_header_prefix(type),
      function_prefix: "nif_" <> Util.type_down_snake(type),
      c_type: to_c_type(type),
      get_fun_fragments: get_fun_fragments(type, ros2_message_type_map)
    )
  end

  def to_header_name(ros2_message_type) do
    [_interfaces, "msg", type] = ros2_message_type |> String.split("/")
    Util.to_down_snake(type)
  end

  def to_deps_header_prefix_list(ros2_message_type, ros2_message_type_map) do
    get_deps_types(ros2_message_type, ros2_message_type_map)
    |> Enum.map(fn ros2_message_type ->
      [interfaces, "msg", type] = ros2_message_type |> String.split("/")
      [interfaces, "msg", "detail", Util.to_down_snake(type)] |> Path.join()
    end)
  end

  def to_header_prefix(ros2_message_type) do
    [interfaces, "msg", type] = ros2_message_type |> String.split("/")
    [interfaces, "msg", "detail", Util.to_down_snake(type)] |> Path.join()
  end

  @doc """
  iex> Rclex.Generators.MsgC.to_c_type("std_msgs/msg/String")
  "std_msgs__msg__String"

  iex> Rclex.Generators.MsgC.to_c_type("std_msgs/msg/UInt32MultiArray")
  "std_msgs__msg__UInt32MultiArray"
  """
  def to_c_type(ros2_message_type) do
    [interfaces, "msg", type] = ros2_message_type |> String.split("/")
    [interfaces, "_msg_", type] |> Enum.join("_")
  end

  defmodule Acc do
    @moduledoc false
    defstruct vars: [], mbrs: [], depth: 0, type: nil
  end

  def get_fun_fragments(ros2_message_type, ros2_message_type_map) do
    build_get_fun_fragments(%Acc{type: {:msg_type, ros2_message_type}}, ros2_message_type_map)
  end

  def build_get_fun_fragments(acc, lhs \\ "return", ros2_message_type_map) do
    {binary, accs} = enif_make(acc.type, acc, ros2_message_type_map)

    array_accs =
      Enum.filter(accs, fn acc ->
        {type_atom, _} = acc.type
        type_atom in [:msg_type_array, :built_in_type_array]
      end)

    if Enum.empty?(array_accs) do
      """
      #{lhs} #{binary};
      """
    else
      """
      #{Enum.map_join(array_accs, fn acc ->
        var = Enum.join(acc.vars, "_")
        mbr = Enum.join(acc.mbrs, ".")
        """
        ERL_NIF_TERM #{var}[message_p->#{mbr}.size];

        for (size_t #{var}_i = 0; #{var}_i < message_p->#{mbr}.size; ++#{var}_i)
        {
        #{build_get_fun_fragments(to_not_array_acc(acc), "#{var}[#{var}_i] =", ros2_message_type_map)}
        }
        """
      end)}


      #{lhs} #{binary};
      """
    end
  end

  defp to_not_array_acc(acc) do
    case acc.type do
      {:msg_type_array, type} -> %Acc{acc | type: {:msg_type, get_array_type(type)}}
      {:built_in_type_array, type} -> %Acc{acc | type: {:built_in_type, get_array_type(type)}}
    end
    |> then(
      &%Acc{&1 | mbrs: acc.mbrs ++ ["data[#{Enum.join(acc.vars, "_")}_i]"], depth: acc.depth + 1}
    )
  end

  def enif_make({:msg_type, ros2_message_type}, acc, ros2_message_type_map) do
    fields = get_fields(ros2_message_type, ros2_message_type_map)

    {binaries, accs} =
      Enum.map_reduce(fields, [], fn field, accs ->
        acc =
          case field do
            [_, name | _] -> %Acc{acc | vars: acc.vars ++ [name], mbrs: acc.mbrs ++ [name]}
            [_] -> acc
          end
          |> then(&%Acc{&1 | depth: acc.depth + 1, type: hd(field)})

        {binary, accs_} = enif_make(acc.type, acc, ros2_message_type_map)
        {binary, accs ++ accs_}
      end)

    binary =
      """
      enif_make_tuple(env, #{Enum.count(binaries)},
      #{Enum.join(binaries, ",\n")}
      )
      """

    {binary, accs}
  end

  def enif_make({:msg_type_array, type}, acc, ros2_messaage_type_map) do
    {enif_make_array(type, acc, ros2_messaage_type_map), [acc]}
  end

  def enif_make({:built_in_type_array, type}, acc, ros2_messaage_type_map) do
    {enif_make_array(type, acc, ros2_messaage_type_map), [acc]}
  end

  def enif_make({:built_in_type, type}, acc, ros2_messaage_type_map) do
    {enif_make_builtin(type, acc, ros2_messaage_type_map), [acc]}
  end

  defp enif_make_array(_type, acc, _ros2_messaage_type_map) do
    "enif_make_list_from_array(env, #{Enum.join(acc.vars, "_")}, message_p->#{Enum.join(acc.mbrs, ".")}.size)"
  end

  defp enif_make_builtin("int64", acc, _ros2_messaage_type_map) do
    "enif_make_int64(env, message_p->#{Enum.join(acc.mbrs, ".")})"
  end

  defp enif_make_builtin("int" <> _, acc, _ros2_messaage_type_map) do
    "enif_make_int(env, message_p->#{Enum.join(acc.mbrs, ".")})"
  end

  defp enif_make_builtin("uint64", acc, _ros2_messaage_type_map) do
    "enif_make_uint64(env, message_p->#{Enum.join(acc.mbrs, ".")})"
  end

  defp enif_make_builtin("uint" <> _, acc, _ros2_messaage_type_map) do
    "enif_make_uint(env, message_p->#{Enum.join(acc.mbrs, ".")})"
  end

  defp enif_make_builtin("float" <> _, acc, _ros2_messaage_type_map) do
    "enif_make_double(env, message_p->#{Enum.join(acc.mbrs, ".")})"
  end

  defp enif_make_builtin("string", acc, _ros2_messaage_type_map) do
    "enif_make_string(env, message_p->#{Enum.join(acc.mbrs, ".")}.data, ERL_NIF_LATIN1)"
  end

  defp get_deps_types(ros2_message_type, types \\ MapSet.new([]), ros2_message_type_map) do
    get_fields(ros2_message_type, ros2_message_type_map)
    |> Enum.reduce(types, fn field, acc ->
      [head | _] = field

      case head do
        {:msg_type, type} ->
          get_deps_types(type, MapSet.put(acc, type), ros2_message_type_map)

        {:msg_type_array, type} ->
          type = get_array_type(type)
          get_deps_types(type, MapSet.put(acc, type), ros2_message_type_map)

        _ ->
          acc
      end
    end)
  end

  defp get_fields(ros2_message_type, ros2_message_type_map) do
    Map.get(ros2_message_type_map, {:msg_type, ros2_message_type})
  end

  defp get_array_type(type) do
    {:ok, acc, _rest, _context, _line, _column} = TypeParser.parse(type)
    [type | _] = acc
    type
  end
end
