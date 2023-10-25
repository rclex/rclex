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
      rosidl_get_msg_type_support: rosidl_get_msg_type_support(type),
      c_type: to_c_type(type),
      set_fun_fragments: set_fun_fragments(type, ros2_message_type_map),
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

  def rosidl_get_msg_type_support(ros2_message_type) do
    [interfaces, "msg", type] = ros2_message_type |> String.split("/")
    "ROSIDL_GET_MSG_TYPE_SUPPORT(#{interfaces}, msg, #{type})"
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
    defstruct vars: [], mbrs: [], type: nil, terms: []
  end

  def set_fun_fragments(ros2_message_type, ros2_message_type_map) do
    enif_get({:msg_type, ros2_message_type}, %Acc{}, ros2_message_type_map)
    |> format
  end

  def enif_get({:msg_type, ros2_message_type}, acc, ros2_message_type_map) do
    fields = get_fields(ros2_message_type, ros2_message_type_map)

    Enum.with_index(fields)
    |> Enum.map_join("\n", fn {[_, name | _] = field, index} ->
      acc =
        %Acc{
          acc
          | vars: acc.vars ++ [name],
            mbrs: acc.mbrs ++ [name],
            terms: acc.vars ++ ["tuple[#{index}]"],
            type: hd(field)
        }

      case acc.type do
        {:msg_type, _type} ->
          var = Enum.join(acc.vars, "_")
          term = Enum.join(acc.terms, "_")

          binary =
            enif_get(acc.type, acc, ros2_message_type_map)
            |> String.replace_suffix("\n", "")

          """
          int #{var}_arity;
          const ERL_NIF_TERM *#{var}_tuple;
          if (!enif_get_tuple(env, #{term}, &#{var}_arity, &#{var}_tuple))
            return enif_make_badarg(env);

          #{binary}
          """

        _ ->
          enif_get(acc.type, acc, ros2_message_type_map)
      end
    end)
  end

  def enif_get({:builtin_type, type}, acc, _ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")
    term = Enum.join(acc.terms, "_")

    enif_get_builtin(type, var, mbr, term)
  end

  def enif_get({:msg_type_array, type}, acc, ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")
    term = Enum.join(acc.terms, "_")

    sequence = "#{to_c_type(get_array_type(type))}__Sequence"

    binary =
      (fn ->
         acc = %Acc{acc | vars: acc.vars ++ ["i"], mbrs: acc.mbrs ++ ["data[#{var}_i]"]}
         enif_get({:msg_type, get_array_type(type)}, acc, ros2_message_type_map)
       end).()
      |> format()

    """
    unsigned int #{var}_length;
    if (!enif_get_list_length(env, #{term}, &#{var}_length))
      return enif_make_badarg(env);

    #{sequence} *#{var} = #{sequence}__create(#{var}_length);
    if (#{var} == NULL) return raise(env, __FILE__, __LINE__);
    message_p->#{mbr} = *#{var};

    unsigned int #{var}_i;
    ERL_NIF_TERM #{var}_left, #{var}_head, #{var}_tail;
    for (#{var}_i = 0, #{var}_left = #{term}; #{var}_i < #{var}_length; ++#{var}_i, #{var}_left = #{var}_tail)
    {
      if (!enif_get_list_cell(env, #{var}_left, &#{var}_head, &#{var}_tail))
        return enif_make_badarg(env);

      int #{var}_i_arity;
      const ERL_NIF_TERM *#{var}_i_tuple;
      if (!enif_get_tuple(env, #{var}_head, &#{var}_i_arity, &#{var}_i_tuple))
        return enif_make_badarg(env);

    #{binary}
    }
    """
  end

  def enif_get({:builtin_type_array, type}, acc, ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")
    term = Enum.join(acc.terms, "_")

    sequence = "rosidl_runtime_c__#{get_array_type(type)}__Sequence"

    binary =
      (fn ->
         acc = %Acc{
           acc
           | vars: acc.vars ++ [get_array_type(type)],
             mbrs: acc.mbrs ++ ["data[#{var}_i]"],
             terms: acc.vars ++ ["head"]
         }

         enif_get({:builtin_type, get_array_type(type)}, acc, ros2_message_type_map)
       end).()
      |> format()

    """
    unsigned int #{var}_length;
    if (!enif_get_list_length(env, #{term}, &#{var}_length))
      return enif_make_badarg(env);

    #{sequence} #{var};
    if(!#{sequence}__init(&#{var}, #{var}_length))
      return enif_make_badarg(env);
    message_p->#{mbr} = #{var};

    unsigned int #{var}_i;
    ERL_NIF_TERM #{var}_left, #{var}_head, #{var}_tail;
    for (#{var}_i = 0, #{var}_left = #{term}; #{var}_i < #{var}_length; ++#{var}_i, #{var}_left = #{var}_tail)
    {
      if (!enif_get_list_cell(env, #{var}_left, &#{var}_head, &#{var}_tail))
        return enif_make_badarg(env);

    #{binary}
    }
    """
  end

  defp enif_get_builtin("bool", var, mbr, term) do
    """
    unsigned int #{var}_length;
    if (!enif_get_atom_length(env, #{term}, &#{var}_length, ERL_NIF_LATIN1))
      return enif_make_badarg(env);

    char #{var}[#{var}_length + 1];
    if (enif_get_atom(env, #{term}, #{var}, #{var}_length + 1, ERL_NIF_LATIN1) <= 0)
      return enif_make_badarg(env);

    strcmp(#{var}, "true") == 0 ? message_p->#{mbr} = true : message_p->#{mbr} = false;
    """
  end

  defp enif_get_builtin("int64", var, mbr, term) do
    """
    int64_t #{var};
    if (!enif_get_int64(env, #{term}, &#{var}))
      return enif_make_badarg(env);
    message_p->#{mbr} = #{var};
    """
  end

  defp enif_get_builtin("int" <> _, var, mbr, term) do
    """
    int #{var};
    if (!enif_get_int(env, #{term}, &#{var}))
      return enif_make_badarg(env);
    message_p->#{mbr} = #{var};
    """
  end

  defp enif_get_builtin("uint64", var, mbr, term) do
    """
    uint64_t #{var};
    if (!enif_get_uint64(env, #{term}, &#{var}))
      return enif_make_badarg(env);
    message_p->#{mbr} = #{var};
    """
  end

  defp enif_get_builtin("uint" <> _, var, mbr, term) do
    """
    unsigned int #{var};
    if (!enif_get_uint(env, #{term}, &#{var}))
      return enif_make_badarg(env);
    message_p->#{mbr} = #{var};
    """
  end

  defp enif_get_builtin("float64", var, mbr, term) do
    """
    double #{var};
    if (!enif_get_double(env, #{term}, &#{var}))
      return enif_make_badarg(env);
    message_p->#{mbr} = #{var};
    """
  end

  defp enif_get_builtin("float32", var, mbr, term) do
    """
    double #{var};
    if (!enif_get_double(env, #{term}, &#{var}))
      return enif_make_badarg(env);
    message_p->#{mbr} = (float)#{var};
    """
  end

  defp enif_get_builtin("string", var, mbr, term) do
    """
    unsigned int #{var}_length;
    #if (ERL_NIF_MAJOR_VERSION == 2 && ERL_NIF_MINOR_VERSION >= 17) // OTP-26 and later
    if (!enif_get_string_length(env, #{term}, &#{var}_length, ERL_NIF_LATIN1))
      return enif_make_badarg(env);
    #else
    if (!enif_get_list_length(env, #{term}, &#{var}_length))
      return enif_make_badarg(env);
    #endif

    char #{var}[#{var}_length + 1];
    if (enif_get_string(env, #{term}, #{var}, #{var}_length + 1, ERL_NIF_LATIN1) <= 0)
      return enif_make_badarg(env);

    if (!rosidl_runtime_c__String__assign(&(message_p->#{mbr}), #{var}))
      return raise(env, __FILE__, __LINE__);
    """
  end

  def get_fun_fragments(ros2_message_type, ros2_message_type_map) do
    build_get_fun_fragments(%Acc{type: {:msg_type, ros2_message_type}}, ros2_message_type_map)
    |> format()
  end

  def build_get_fun_fragments(acc, lhs \\ "return", ros2_message_type_map) do
    {binary, accs} = enif_make(acc.type, acc, ros2_message_type_map)

    array_accs =
      Enum.filter(accs, fn acc ->
        {type_atom, _} = acc.type
        type_atom in [:msg_type_array, :builtin_type_array]
      end)

    rhs = binary |> String.replace_suffix("\n", "")

    Enum.map_join(array_accs, fn acc ->
      var = Enum.join(acc.vars, "_")
      mbr = Enum.join(acc.mbrs, ".")

      binary =
        build_get_fun_fragments(
          to_not_array_acc(acc),
          "#{var}[#{var}_i] =",
          ros2_message_type_map
        )
        |> format()

      """
      ERL_NIF_TERM #{var}[message_p->#{mbr}.size];

      for (size_t #{var}_i = 0; #{var}_i < message_p->#{mbr}.size; ++#{var}_i)
      {
      #{binary}
      }

      """
    end) <> "#{lhs} #{rhs};"
  end

  defp to_not_array_acc(acc) do
    case acc.type do
      {:msg_type_array, type} -> %Acc{acc | type: {:msg_type, get_array_type(type)}}
      {:builtin_type_array, type} -> %Acc{acc | type: {:builtin_type, get_array_type(type)}}
    end
    |> then(&%Acc{&1 | mbrs: acc.mbrs ++ ["data[#{Enum.join(acc.vars, "_")}_i]"]})
  end

  def enif_make({:msg_type, ros2_message_type}, acc, ros2_message_type_map) do
    fields = get_fields(ros2_message_type, ros2_message_type_map)

    {binaries, accs} =
      Enum.map_reduce(fields, [], fn [_, name | _] = field, accs ->
        acc = %Acc{acc | vars: acc.vars ++ [name], mbrs: acc.mbrs ++ [name], type: hd(field)}
        {binary, accs_} = enif_make(acc.type, acc, ros2_message_type_map)
        {binary, accs ++ accs_}
      end)

    binary = Enum.join(binaries, ",\n") |> format()

    binary =
      """
      enif_make_tuple(env, #{Enum.count(binaries)},
      #{binary}
      )
      """
      |> String.replace_suffix("\n", "")

    {binary, accs}
  end

  def enif_make({:msg_type_array, type}, acc, ros2_message_type_map) do
    {enif_make_array(type, acc, ros2_message_type_map), [acc]}
  end

  def enif_make({:builtin_type_array, type}, acc, ros2_message_type_map) do
    {enif_make_array(type, acc, ros2_message_type_map), [acc]}
  end

  def enif_make({:builtin_type, type}, acc, _ros2_message_type_map) do
    mbr = Enum.join(acc.mbrs, ".")
    {enif_make_builtin(type, mbr), [acc]}
  end

  defp enif_make_array(_type, acc, _ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")
    "enif_make_list_from_array(env, #{var}, message_p->#{mbr}.size)"
  end

  defp enif_make_builtin("int64", mbr) do
    "enif_make_int64(env, message_p->#{mbr})"
  end

  defp enif_make_builtin("int" <> _, mbr) do
    "enif_make_int(env, message_p->#{mbr})"
  end

  defp enif_make_builtin("uint64", mbr) do
    "enif_make_uint64(env, message_p->#{mbr})"
  end

  defp enif_make_builtin("uint" <> _, mbr) do
    "enif_make_uint(env, message_p->#{mbr})"
  end

  defp enif_make_builtin("float" <> _, mbr) do
    "enif_make_double(env, message_p->#{mbr})"
  end

  defp enif_make_builtin("string", mbr) do
    "enif_make_string(env, message_p->#{mbr}.data, ERL_NIF_LATIN1)"
  end

  defp format(binary) do
    indent = String.duplicate(" ", 2)

    binary
    |> String.replace_suffix("\n", "")
    |> String.split("\n")
    |> Enum.map_join("\n", fn
      "" -> ""
      line = "#" <> _ -> line
      line -> indent <> line
    end)
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
