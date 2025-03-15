defmodule Rclex.Generators.MsgC do
  @moduledoc false

  alias Rclex.Generators.Util
  alias Rclex.Parsers.TypeParser

  def generate(type, ros2_message_type_map) do
    set_fun_fragments = set_fun_fragments(type, ros2_message_type_map)
    is_empty_type? = set_fun_fragments == ""

    EEx.eval_file(Path.join(Util.templates_dir_path(), "msg_c.eex"),
      header_name: to_header_name(type),
      deps_header_prefix_list: to_deps_header_prefix_list(type, ros2_message_type_map),
      header_prefix: to_header_prefix(type),
      function_prefix: "nif_" <> Util.type_down_snake(type),
      rosidl_get_msg_type_support: rosidl_get_msg_type_support(type),
      c_type: to_c_type(type),
      set_fun_fragments: set_fun_fragments,
      get_fun_fragments: get_fun_fragments(type, ros2_message_type_map),
      is_empty_type?: is_empty_type?
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
      acc = %Acc{
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
          if (!enif_get_tuple(env, #{term}, &#{var}_arity, &#{var}_tuple)) {
            term = enif_make_badarg(env);
            goto after;
          }

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
    case get_array_type(type) do
      %{type: type, kind: :unbounded_dynamic} ->
        enif_get({:msg_type_array_unbounded, type}, acc, ros2_message_type_map)
    end
  end

  def enif_get({:msg_type_array_unbounded, type}, acc, ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")
    term = Enum.join(acc.terms, "_")

    sequence = "#{to_c_type(type)}__Sequence"

    binary =
      (fn ->
         acc = %Acc{acc | vars: acc.vars ++ ["i"], mbrs: acc.mbrs ++ ["data[#{var}_i]"]}
         enif_get({:msg_type, type}, acc, ros2_message_type_map)
       end).()
      |> format()

    """
    unsigned int #{var}_length;
    if (!enif_get_list_length(env, #{term}, &#{var}_length)) {
      term = enif_make_badarg(env);
      goto after;
    }

    #{sequence} *#{var} = #{sequence}__create(#{var}_length);
    if (#{var} == NULL) {
      term = raise(env, __FILE__, __LINE__);
      goto after;
    }
    message_p->#{mbr} = *#{var};

    unsigned int #{var}_i;
    ERL_NIF_TERM #{var}_left, #{var}_head, #{var}_tail;
    for (#{var}_i = 0, #{var}_left = #{term}; #{var}_i < #{var}_length; ++#{var}_i, #{var}_left = #{var}_tail)
    {
      if (!enif_get_list_cell(env, #{var}_left, &#{var}_head, &#{var}_tail)) {
        term = enif_make_badarg(env);
        goto after;
      }

      int #{var}_i_arity;
      const ERL_NIF_TERM *#{var}_i_tuple;
      if (!enif_get_tuple(env, #{var}_head, &#{var}_i_arity, &#{var}_i_tuple)) {
        term = enif_make_badarg(env);
        goto after;
      }

    #{binary}
    }
    """
  end

  def enif_get({:builtin_type_array, type}, acc, ros2_message_type_map) do
    case get_array_type(type) do
      %{type: type, kind: :unbounded_dynamic} ->
        enif_get({:builtin_type_array_unbounded, type}, acc, ros2_message_type_map)

      %{type: type, kind: :static, size: size} ->
        enif_get({:builtin_type_array_static, type, size}, acc, ros2_message_type_map)
    end
  end

  def enif_get({:builtin_type_array_unbounded, "uint8" = type}, acc, _ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")
    term = Enum.join(acc.terms, "_")

    sequence = rosidl_runtime_c_type_sequence(type)

    """
    ErlNifBinary #{var}_binary;
    if (!enif_inspect_binary(env, #{term}, &#{var}_binary)) {
      term = enif_make_badarg(env);
      goto after;
    }

    #{sequence} #{var};
    if (!#{sequence}__init(&#{var}, #{var}_binary.size)) {
      term = enif_make_badarg(env);
      goto after;
    }
    memcpy((void *)#{var}.data, (const void *)#{var}_binary.data, #{var}_binary.size);
    // Copying the struct via assignment.
    message_p->#{mbr} = #{var};
    """
  end

  def enif_get({:builtin_type_array_unbounded, type}, acc, ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")
    term = Enum.join(acc.terms, "_")

    sequence = rosidl_runtime_c_type_sequence(type)

    vars = acc.vars ++ [type]
    mbrs = acc.mbrs ++ ["data[#{var}_i]"]
    terms = acc.vars ++ ["head"]

    binary =
      (fn ->
         acc = %Acc{acc | vars: vars, mbrs: mbrs, terms: terms}
         enif_get({:builtin_type, type}, acc, ros2_message_type_map)
       end).()
      |> format()

    """
    unsigned int #{var}_length;
    if (!enif_get_list_length(env, #{term}, &#{var}_length)) {
      term = enif_make_badarg(env);
      goto after;
    }

    #{sequence} #{var};
    if(!#{sequence}__init(&#{var}, #{var}_length)) {
      term = enif_make_badarg(env);
      goto after;
    }
    message_p->#{mbr} = #{var};

    unsigned int #{var}_i;
    ERL_NIF_TERM #{var}_left, #{var}_head, #{var}_tail;
    for (#{var}_i = 0, #{var}_left = #{term}; #{var}_i < #{var}_length; ++#{var}_i, #{var}_left = #{var}_tail)
    {
      if (!enif_get_list_cell(env, #{var}_left, &#{var}_head, &#{var}_tail)) {
        term = enif_make_badarg(env);
        goto after;
      }

    #{binary}
    }
    """
  end

  def enif_get({:builtin_type_array_static, "uint8" = _type, size}, acc, _ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")
    term = Enum.join(acc.terms, "_")

    """
    ErlNifBinary #{var}_binary;
    if (!enif_inspect_binary(env, #{term}, &#{var}_binary)) {
      term = enif_make_badarg(env);
      goto after;
    }
    memcpy((void *)message_p->#{mbr}, (const void *)#{var}_binary.data, #{size});
    """
  end

  def enif_get({:builtin_type_array_static, type, size}, acc, ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    term = Enum.join(acc.terms, "_")

    vars = acc.vars ++ [type]
    mbrs = List.pop_at(acc.mbrs, -1) |> then(fn {mbr, mbrs} -> mbrs ++ ["#{mbr}[#{var}_i]"] end)
    terms = acc.vars ++ ["head"]

    binary =
      (fn ->
         acc = %Acc{acc | vars: vars, mbrs: mbrs, terms: terms}
         enif_get({:builtin_type, type}, acc, ros2_message_type_map)
       end).()
      |> format()

    """
    unsigned int #{var}_i;
    ERL_NIF_TERM #{var}_left, #{var}_head, #{var}_tail;
    for (#{var}_i = 0, #{var}_left = #{term}; #{var}_i < #{size}; ++#{var}_i, #{var}_left = #{var}_tail)
    {
      if (!enif_get_list_cell(env, #{var}_left, &#{var}_head, &#{var}_tail)) {
        term = enif_make_badarg(env);
        goto after;
      }
    #{binary}
    }
    """
  end

  defp enif_get_builtin("bool", var, mbr, term) do
    """
    unsigned int #{var}_length;
    if (!enif_get_atom_length(env, #{term}, &#{var}_length, ERL_NIF_LATIN1)) {
      term = enif_make_badarg(env);
      goto after;
    }

    char #{var}[#{var}_length + 1];
    if (enif_get_atom(env, #{term}, #{var}, #{var}_length + 1, ERL_NIF_LATIN1) <= 0) {
      term = enif_make_badarg(env);
      goto after;
    }

    message_p->#{mbr} = (strncmp(#{var}, "true", 4) == 0);
    """
  end

  defp enif_get_builtin("int64", var, mbr, term) do
    """
    int64_t #{var};
    if (!enif_get_int64(env, #{term}, &#{var})) {
      term = enif_make_badarg(env);
      goto after;
    }

    message_p->#{mbr} = #{var};
    """
  end

  defp enif_get_builtin("byte", var, mbr, term) do
    """
    unsigned int #{var};
    if (!enif_get_uint(env, #{term}, &#{var})) {
      term = enif_make_badarg(env);
      goto after;
    }

    message_p->#{mbr} = (uint8_t)#{var};
    """
  end

  defp enif_get_builtin("int" <> _, var, mbr, term) do
    """
    int #{var};
    if (!enif_get_int(env, #{term}, &#{var})) {
      term = enif_make_badarg(env);
      goto after;
    }

    message_p->#{mbr} = #{var};
    """
  end

  defp enif_get_builtin("uint64", var, mbr, term) do
    """
    uint64_t #{var};
    if (!enif_get_uint64(env, #{term}, &#{var})) {
      term = enif_make_badarg(env);
      goto after;
    }

    message_p->#{mbr} = #{var};
    """
  end

  defp enif_get_builtin("uint" <> _, var, mbr, term) do
    """
    unsigned int #{var};
    if (!enif_get_uint(env, #{term}, &#{var})) {
      term = enif_make_badarg(env);
      goto after;
    }

    message_p->#{mbr} = #{var};
    """
  end

  defp enif_get_builtin("float64", var, mbr, term) do
    """
    double #{var};
    if (!enif_get_double(env, #{term}, &#{var})) {
      term = enif_make_badarg(env);
      goto after;
    }

    message_p->#{mbr} = #{var};
    """
  end

  defp enif_get_builtin("float32", var, mbr, term) do
    """
    double #{var};
    if (!enif_get_double(env, #{term}, &#{var})) {
      term = enif_make_badarg(env);
      goto after;
    }

    message_p->#{mbr} = (float)#{var};
    """
  end

  defp enif_get_builtin("string", var, mbr, term) do
    """
    ErlNifBinary #{var}_binary;
    if (!enif_inspect_binary(env, #{term}, &#{var}_binary)) {
      term = enif_make_badarg(env);
      goto after;
    }

    if (!rosidl_runtime_c__String__assignn(&(message_p->#{mbr}), (const char *)#{var}_binary.data, #{var}_binary.size)) {
      term = raise(env, __FILE__, __LINE__);
      goto after;
    }
    """
  end

  def get_fun_fragments(ros2_message_type, ros2_message_type_map) do
    build_get_fun_fragments(%Acc{type: {:msg_type, ros2_message_type}}, ros2_message_type_map)
    |> format()
  end

  def build_get_fun_fragments(acc, lhs \\ "term =", ros2_message_type_map) do
    {binary, accs} = enif_make(acc.type, acc, ros2_message_type_map)

    rhs = binary |> String.replace_suffix("\n", "")

    array_accs =
      Enum.filter(accs, fn acc ->
        {type_atom, _} = acc.type
        type_atom in [:msg_type_array, :builtin_type_array]
      end)

    Enum.map_join(array_accs, fn acc ->
      build_get_fun_fragments_array(acc.type, acc, ros2_message_type_map)
    end) <> "#{lhs} #{rhs};"
  end

  def build_get_fun_fragments_array({:msg_type_array, type}, acc, ros2_message_type_map) do
    case get_array_type(type) do
      %{type: type, kind: :unbounded_dynamic} ->
        array_for(
          {:unbounded, type},
          %Acc{acc | type: {:msg_type, type}},
          ros2_message_type_map
        )
    end
  end

  def build_get_fun_fragments_array({:builtin_type_array, type}, acc, ros2_message_type_map) do
    case get_array_type(type) do
      %{type: type, kind: :unbounded_dynamic} ->
        array_for(
          {:unbounded, type},
          %Acc{acc | type: {:builtin_type, type}},
          ros2_message_type_map
        )

      %{type: type, kind: :static, size: size} ->
        array_for(
          {:static, type, size},
          %Acc{acc | type: {:builtin_type, type}},
          ros2_message_type_map
        )
    end
  end

  defp array_for({:unbounded, "uint8" = _type}, acc, _ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")

    """
    ErlNifBinary #{var}_binary;
    if (!enif_alloc_binary(message_p->#{mbr}.size, &#{var}_binary)) {
      term = raise(env, __FILE__, __LINE__);
      goto after;
    }
    memcpy((void *)#{var}_binary.data, (const void *)message_p->#{mbr}.data, #{var}_binary.size);

    """
  end

  defp array_for({:unbounded, _type}, acc, ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")

    mbrs = acc.mbrs ++ ["data[#{var}_i]"]

    acc = %Acc{acc | mbrs: mbrs}

    binary =
      build_get_fun_fragments(acc, "#{var}[#{var}_i] =", ros2_message_type_map)
      |> format()

    """
    ERL_NIF_TERM #{var}[message_p->#{mbr}.size];

    for (size_t #{var}_i = 0; #{var}_i < message_p->#{mbr}.size; ++#{var}_i)
    {
    #{binary}
    }

    """
  end

  defp array_for({:static, "uint8" = _type, size}, acc, _ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")

    """
    ErlNifBinary #{var}_binary;
    if (!enif_alloc_binary(#{size}, &#{var}_binary)) {
      term = raise(env, __FILE__, __LINE__);
      goto after;
    }
    memcpy((void *)#{var}_binary.data, (const void *)message_p->#{mbr}, #{size});

    """
  end

  defp array_for({:static, _type, size}, acc, ros2_message_type_map) do
    var = Enum.join(acc.vars, "_")

    mbrs = List.pop_at(acc.mbrs, -1) |> then(fn {mbr, mbrs} -> mbrs ++ ["#{mbr}[#{var}_i]"] end)

    acc = %Acc{acc | mbrs: mbrs}

    binary =
      build_get_fun_fragments(acc, "#{var}[#{var}_i] =", ros2_message_type_map)
      |> format()

    """
    ERL_NIF_TERM #{var}[#{size}];

    for (size_t #{var}_i = 0; #{var}_i < #{size}; ++#{var}_i)
    {
    #{binary}
    }

    """
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
      case Enum.count(binaries) do
        0 ->
          """
          enif_make_tuple(env, 0)
          """

        _ ->
          """
          enif_make_tuple(env, #{Enum.count(binaries)},
          #{binary}
          )
          """
      end
      |> String.replace_suffix("\n", "")

    {binary, accs}
  end

  def enif_make({:msg_type_array, type}, acc, _ros2_message_type_map) do
    case get_array_type(type) do
      %{type: type, kind: :unbounded_dynamic} ->
        {enif_make_array({:unbounded, type}, acc), [acc]}

      %{type: type, kind: :static, size: size} ->
        {enif_make_array({:static, type, size}, acc), [acc]}
    end
  end

  def enif_make({:builtin_type_array, type}, acc, _ros2_message_type_map) do
    case get_array_type(type) do
      %{type: type, kind: :unbounded_dynamic} ->
        {enif_make_array({:unbounded, type}, acc), [acc]}

      %{type: type, kind: :static, size: size} ->
        {enif_make_array({:static, type, size}, acc), [acc]}
    end
  end

  def enif_make({:builtin_type, type}, acc, _ros2_message_type_map) do
    mbr = Enum.join(acc.mbrs, ".")
    {enif_make_builtin(type, mbr), [acc]}
  end

  defp enif_make_array({:unbounded, "uint8" = _type}, acc) do
    var = Enum.join(acc.vars, "_")
    "enif_make_binary(env, &#{var}_binary)"
  end

  defp enif_make_array({:unbounded, _type}, acc) do
    var = Enum.join(acc.vars, "_")
    mbr = Enum.join(acc.mbrs, ".")
    "enif_make_list_from_array(env, #{var}, message_p->#{mbr}.size)"
  end

  defp enif_make_array({:static, "uint8" = _type, _size}, acc) do
    var = Enum.join(acc.vars, "_")
    "enif_make_binary(env, &#{var}_binary)"
  end

  defp enif_make_array({:static, _type, size}, acc) do
    var = Enum.join(acc.vars, "_")
    "enif_make_list_from_array(env, #{var}, #{size})"
  end

  defp enif_make_builtin("bool", mbr) do
    "enif_make_atom(env, message_p->#{mbr} ? \"true\" : \"false\")"
  end

  defp enif_make_builtin("int64", mbr) do
    "enif_make_int64(env, message_p->#{mbr})"
  end

  defp enif_make_builtin("byte", mbr) do
    "enif_make_uint(env, message_p->#{mbr})"
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
    "enif_make_binary_wrapper(env, message_p->#{mbr}.data, message_p->#{mbr}.size)"
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
          %{type: type} = get_array_type(type)
          get_deps_types(type, MapSet.put(acc, type), ros2_message_type_map)

        _ ->
          acc
      end
    end)
  end

  defp get_fields(ros2_message_type, ros2_message_type_map) do
    Map.get(ros2_message_type_map, {:msg_type, ros2_message_type})
  end

  def get_array_type(type) do
    {:ok, acc, _rest, _context, _line, _column} = TypeParser.parse(type)

    case acc do
      [type, "[]"] -> %{type: type, kind: :unbounded_dynamic, size: :undefined}
      [type, "[", size, "]"] -> %{type: type, kind: :static, size: size}
      [type, "[<=", size, "]"] -> %{type: type, kind: :bounded_dynamic, size: size}
    end
  end

  defp rosidl_runtime_c_type_sequence(type) do
    case type do
      "string" -> "rosidl_runtime_c__String__Sequence"
      "wstring" -> "rosidl_runtime_c__U16String__Sequence"
      _ -> "rosidl_runtime_c__#{type}__Sequence"
    end
  end
end
