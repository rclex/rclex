defmodule Rclex.Generators.MsgC do
  @moduledoc false

  alias Rclex.Generators.Util
  alias Rclex.Parsers.TypeParser

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
    defstruct vars: [], mbrs: [], depth: 0, type_or_field: nil
  end

  def get_fun_fragments(ros2_message_type, ros2_message_type_map) do
    build_get_fun_fragments(%Acc{type_or_field: ros2_message_type}, ros2_message_type_map)
  end

  def build_get_fun_fragments(acc, lhs \\ "return", ros2_message_type_map) do
    IO.inspect(acc.type_or_field)
    {binary, accs} = enif_make(acc.type_or_field, acc, ros2_message_type_map)

    array =
      Enum.filter(accs, fn acc ->
        [{type_array, _type} | _tail] = acc.type_or_field
        type_array in [:msg_type_array, :built_in_type_array]
      end)

    if Enum.empty?(array) do
      """
      #{lhs} #{binary};
      """
    else
      """
      #{Enum.map_join(array, fn acc ->
        var = Enum.join(acc.vars, "_")
        mbr = Enum.join(acc.mbrs, ".")
        acc = update_array_acc(acc)
        """
        ERL_NIF_TERM #{var}[message_p->#{mbr}.size];

        for (size_t #{var}_i = 0; #{var}_i < message_p->#{mbr}.size; ++#{var}_i)
        {
        #{build_get_fun_fragments(acc, "#{var}[#{var}_i] =", ros2_message_type_map)}
        }
        """
      end)}


      #{lhs} #{binary};
      """
    end
  end

  defp update_array_acc(acc) do
    [{type_array, type} | tail] = acc.type_or_field
    var = Enum.join(acc.vars, "_")

    case type_array do
      :msg_type_array ->
        %Acc{
          acc
          | mbrs: acc.mbrs ++ ["data[#{var}_i]"],
            depth: acc.depth + 1,
            type_or_field: get_array_type(type)
        }

      :built_in_type_array ->
        %Acc{
          acc
          | mbrs: acc.mbrs ++ ["data[#{var}_i]"],
            depth: acc.depth + 1,
            type_or_field: [{:built_in_type, get_array_type(type)} | tail]
        }
    end
  end

  def enif_make(type, acc, ros2_message_type_map) when is_binary(type) do
    fields = Map.get(ros2_message_type_map, type)

    {binaries, accs} =
      Enum.reduce(fields, {[], []}, fn field, {binaries, accs} ->
        {binary, new_accs} =
          enif_make(field, %Acc{acc | depth: acc.depth + 1}, ros2_message_type_map)

        {binaries ++ [binary], accs ++ new_accs}
      end)

    binary =
      """
      enif_make_tuple(env, #{Enum.count(binaries)},
      #{Enum.join(binaries, ",\n")}
      )
      """

    {binary, accs}
  end

  def enif_make(field, acc, ros2_message_type_map) when is_list(field) do
    [type, name | _] = field

    acc = %Acc{acc | vars: acc.vars ++ [name], mbrs: acc.mbrs ++ [name], type_or_field: field}
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")

    case type do
      {:msg_type, type1} -> enif_make(type1, acc, ros2_message_type_map)
      _ -> {enif_make_(type, var, mbr), [acc]}
    end
  end

  defp enif_make_({:msg_type_array, _type}, var, mbr) do
    "enif_make_list_from_array(env, #{var}, message_p->#{mbr}.size)"
  end

  defp enif_make_({:built_in_type_array, _type}, var, mbr) do
    "enif_make_list_from_array(env, #{var}, message_p->#{mbr}.size)"
  end

  defp enif_make_({:built_in_type, "int64"}, _var, mbr) do
    "enif_make_int64(env, message_p->#{mbr})"
  end

  defp enif_make_({:built_in_type, "int" <> _}, _var, mbr) do
    "enif_make_int(env, message_p->#{mbr})"
  end

  defp enif_make_({:built_in_type, "uint64"}, _var, mbr) do
    "enif_make_uint64(env, message_p->#{mbr})"
  end

  defp enif_make_({:built_in_type, "uint" <> _}, _var, mbr) do
    "enif_make_uint(env, message_p->#{mbr})"
  end

  defp enif_make_({:built_in_type, "float" <> _}, _var, mbr) do
    "enif_make_double(env, message_p->#{mbr})"
  end

  defp enif_make_({:built_in_type, "string"}, _var, mbr) do
    "enif_make_string(env, message_p->#{mbr}.data, ERL_NIF_LATIN1)"
  end

  defp get_deps_types(ros2_message_type, types \\ MapSet.new([]), ros2_message_type_map) do
    Map.get(ros2_message_type_map, ros2_message_type)
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

  defp get_array_type(type) do
    {:ok, acc, _rest, _context, _line, _column} = TypeParser.parse(type)
    [type | _] = acc
    type
  end
end
