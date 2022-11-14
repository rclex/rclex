defmodule Mix.Tasks.Rclex.Gen.Msgs do
  @shortdoc "Generate codes of ROS 2 message type"
  @moduledoc """
  #{@shortdoc}

  Before generating, we have to specify message types in config.exs.

  ex. config :rclex, ros2_message_types: ["std_msgs/msg/String"]

  Be careful, ros2 message type is case sensitive.

  ## How to generate

    $ mix rclex.gen.msgs

    This task assumes that the environment variable ROS_DISTRO is set
    and refers to the message types from "/opt/ros/ROS_DISTRO/share".

    We can also specify directly as follows

    $ mix rclex.gen.msgs --from /opt/ros/foxy/share

  ## How to clean

    $ mix rclex.gen.msgs --clean
  """

  use Mix.Task

  @ros2_elixir_type_map %{
    "bool" => "boolean",
    "byte" => "integer",
    "char" => "integer",
    "float32" => "float",
    "float64" => "float",
    "int8" => "integer",
    "uint8" => "integer",
    "int16" => "integer",
    "uint16" => "integer",
    "int32" => "integer",
    "uint32" => "integer",
    "int64" => "integer",
    "uint64" => "integer",
    "string" => "[integer]",
    "wstring" => "[integer]"
  }

  @ros2_built_in_types Map.keys(@ros2_elixir_type_map)

  def run(args) do
    {valid_options, _, _} =
      OptionParser.parse(args, strict: [from: :string, clean: :boolean, show_types: :boolean])

    case valid_options do
      [] -> generate(rclex_dir_path!())
      [from: from] -> generate(from, rclex_dir_path!())
      [clean: true] -> clean()
      [show_types: true] -> show_types()
      _ -> Mix.shell().info(@moduledoc)
    end
  end

  def generate(to) do
    ros_distro = System.get_env("ROS_DISTRO")

    if is_nil(ros_distro) do
      Mix.raise("Please set ROS_DISTRO.")
    end

    ros_directory_path =
      if Mix.target() == :host do
        "/opt/ros/#{ros_distro}"
      else
        Path.join(File.cwd!(), "rootfs_overlay/opt/ros/#{ros_distro}")
      end

    if not File.exists?(ros_directory_path) do
      Mix.raise("#{ros_directory_path} does not exist.")
    end

    generate(Path.join(ros_directory_path, "share"), to)
  end

  def generate(from, to) do
    types = Application.get_env(:rclex, :ros2_message_types, [])

    if Enum.empty?(types) do
      Mix.raise("ros2_message_types is not specified in config.")
    end

    ros2_message_type_map =
      Enum.reduce(types, %{}, fn type, acc ->
        get_ros2_message_type_map(type, from, acc)
      end)

    types = Map.keys(ros2_message_type_map)

    for type <- types do
      [package_name, "msg", type_name] = String.split(type, "/")
      type_name = to_down_snake(type_name)

      dir_path_ex = Path.join(to, "lib/rclex/pkgs/#{package_name}/msg")
      dir_path_c = Path.join(to, "src/pkgs/#{package_name}/msg")

      File.mkdir_p!(dir_path_ex)
      File.mkdir_p!(dir_path_c)

      for {dir_path, file_name, binary} <- [
            {dir_path_ex, "#{type_name}_impl.ex", generate_msg_prot(type, ros2_message_type_map)},
            {dir_path_ex, "#{type_name}.ex", generate_msg_mod(type, ros2_message_type_map)},
            {dir_path_c, "#{type_name}_nif.c", generate_msg_nif_c(type, ros2_message_type_map)},
            {dir_path_c, "#{type_name}_nif.h", generate_msg_nif_h(type, ros2_message_type_map)}
          ] do
        File.write!(Path.join(dir_path, file_name), binary)
      end
    end

    File.write!(Path.join(to, "lib/rclex/msg_types_nif.ex"), generate_msg_types_ex(types))
    File.write!(Path.join(to, "src/msg_types_nif.h"), generate_msg_types_h(types))
    File.write!(Path.join(to, "src/msg_types_nif.ec"), generate_msg_types_c(types))

    recompile!()
  end

  def clean() do
    dir_path = rclex_dir_path!()

    for file_path <- ["lib/rclex/pkgs", "src/pkgs"] do
      File.rm_rf!(Path.join(dir_path, file_path))
    end

    for file_path <- ["lib/rclex/msg_types_nif.ex", "src/msg_types_nif.h", "src/msg_types_nif.ec"] do
      File.rm_rf!(Path.join(dir_path, file_path))
    end
  end

  def show_types() do
    types = Application.get_env(:rclex, :ros2_message_types, [])

    if Enum.empty?(types) do
      Mix.raise("ros2_message_types is not specified in config.")
    end

    Mix.shell().info(Enum.join(types, " "))
  end

  def generate_msg_types_ex(types) do
    statements =
      Enum.map_join(types, fn type ->
        function_name = get_function_name_from_type(type)

        """
        def readdata_#{function_name}(_), do: raise \"NIF readdata_#{function_name}/1 is not implemented\"
        def setdata_#{function_name}(_,_), do: raise \"NIF setdata_#{function_name}/2 is not implemented\"
        def init_msg_#{function_name}(_), do: raise \"NIF init_msg_#{function_name}/1 is not implemented\"
        def create_empty_msg_#{function_name}, do: raise \"NIF create_empty_msg_#{function_name}/0 is not implemented\"
        def get_typesupport_#{function_name}, do: raise \"NIF get_typesupport_#{function_name}/0 is not implemented\"
        """
      end)

    EEx.eval_file("#{templates_dir_path()}/msg_types_nif.eex", statements: statements)
  end

  def generate_msg_types_h(types) do
    Enum.map_join(types, fn type ->
      """
      #include "pkgs/#{get_file_name_from_type(type)}_nif.h"
      """
    end)
  end

  def generate_msg_types_c(types) do
    Enum.map_join(types, fn type ->
      function_name = get_function_name_from_type(type)

      """
      {"get_typesupport_#{function_name}",0,nif_get_typesupport_#{function_name},0},
      {"create_empty_msg_#{function_name}",0,nif_create_empty_msg_#{function_name},0},
      {"init_msg_#{function_name}",1,nif_init_msg_#{function_name},0},
      {"setdata_#{function_name}",2,nif_setdata_#{function_name},0},
      {"readdata_#{function_name}",1,nif_readdata_#{function_name},0},
      """
    end)
  end

  def generate_msg_prot(type, ros2_message_type_map) do
    EEx.eval_file("#{templates_dir_path()}/msg_prot_impl.eex",
      module_name: get_module_name_from_type(type),
      function_name: get_function_name_from_type(type),
      nifs_readdata_return_fields:
        create_fields_for_nifs_readdata_return(type, ros2_message_type_map),
      read_return_module_fields: create_fields_for_read(type, ros2_message_type_map),
      setdata_arg_fields: create_fields_for_nifs_setdata_arg(type, ros2_message_type_map)
    )
  end

  def generate_msg_mod(type, ros2_message_type_map) do
    EEx.eval_file("#{templates_dir_path()}/msg_mod.eex",
      module_name: get_module_name_from_type(type),
      defstruct_fields: create_fields_for_defstruct(type, ros2_message_type_map),
      type_fields: create_fields_for_type(type, ros2_message_type_map)
    )
  end

  def generate_msg_nif_c(type, ros2_message_type_map) do
    EEx.eval_file("#{templates_dir_path()}/msg_nif_c.eex",
      function_name: get_function_name_from_type(type),
      file_name: get_file_name_from_type(type),
      rosidl_get_msg_type_support: String.replace(type, "/", ","),
      struct_name: get_struct_name_from_type(type),
      readdata_statements: create_readdata_statements(type, ros2_message_type_map),
      setdata_statements: create_setdata_statements(type, ros2_message_type_map)
    )
  end

  def generate_msg_nif_h(type, _ros2_message_type_map) do
    EEx.eval_file("#{templates_dir_path()}/msg_nif_h.eex",
      function_name: get_function_name_from_type(type)
    )
  end

  @spec get_ros2_message_type_map(String.t(), String.t(), map()) :: map()
  # credo:disable-for-next-line
  def get_ros2_message_type_map(ros2_message_type, from, acc \\ %{}) do
    [package_name, "msg", _type_name] = String.split(ros2_message_type, "/")

    rows =
      "#{Path.join(from, ros2_message_type)}.msg"
      |> File.read!()
      |> String.split(["\n"], trim: true)
      |> remove_comment_from_rows()
      |> remove_constants_from_rows()

    type_variable_tuples =
      Enum.map(rows, fn row ->
        [type, variable] =
          row
          # remove comment in row
          |> String.replace(~r/#.*$/, "")
          |> String.split([" "], trim: true)
          # NOTE: currently we do not support default value
          |> Enum.take(2)

        cond do
          type in @ros2_built_in_types -> {type, variable}
          is_ros2_built_in_list(type) -> {type, variable}
          String.contains?(type, "/") -> {type, variable}
          true -> {Path.join("#{package_name}/msg", type), variable}
        end
      end)

    type_map = Map.put(acc, ros2_message_type, type_variable_tuples)

    Enum.reduce(type_variable_tuples, type_map, fn {type, _variable}, acc ->
      cond do
        type in @ros2_built_in_types -> acc
        Map.has_key?(type_map, type) -> acc
        is_ros2_built_in_list(type) -> acc
        is_ros2_list(type) -> get_ros2_message_type_map(list_type(type), from, acc)
        true -> get_ros2_message_type_map(type, from, acc)
      end
    end)
  end

  defp remove_comment_from_rows(rows) do
    Enum.reject(rows, fn row ->
      row
      |> String.trim()
      |> String.starts_with?("#")
    end)
  end

  defp remove_constants_from_rows(rows) do
    Enum.reject(rows, fn row -> String.contains?(row, "=") end)
  end

  @doc """
  iex> #{__MODULE__}.get_module_name_from_path("std_msgs/msg/String")
  "StdMsgs.Msg.String"
  """
  @spec get_module_name_from_path(String.t()) :: String.t()
  def get_module_name_from_path(path) do
    get_module_name_impl(String.split(path, "/"))
  end

  @doc """
  iex> #{__MODULE__}.get_module_name_from_type("std_msgs/msg/String")
  "Rclex.StdMsgs.Msg.String"
  iex> #{__MODULE__}.get_module_name_from_type("geometry_msgs/msg/TwistWithCovariance")
  "Rclex.GeometryMsgs.Msg.TwistWithCovariance"
  """
  def get_module_name_from_type(type) do
    if not String.contains?(type, "/") do
      Mix.raise("""
      type must contain ROS 2 package name,
      ex) "std_msgs/msg/String", "geometry_msgs/msg/Twist"
      """)
    end

    String.split(type, "/")
    |> get_module_name_impl()
    |> then(&"Rclex.#{&1}")
  end

  @doc """
  iex> #{__MODULE__}.get_function_name_from_type("std_msgs/msg/String")
  "std_msgs_msg_string"
  iex> #{__MODULE__}.get_function_name_from_type("geometry_msgs/msg/TwistWithCovariance")
  "geometry_msgs_msg_twist_with_covariance"
  """
  def get_function_name_from_type(type) do
    [pkg, "msg", type] = String.split(type, "/")
    Enum.join([pkg, "msg", to_down_snake(type)], "_")
  end

  @doc """
  iex> #{__MODULE__}.get_file_name_from_type("std_msgs/msg/String")
  "std_msgs/msg/string"
  iex> #{__MODULE__}.get_file_name_from_type("geometry_msgs/msg/TwistWithCovariance")
  "geometry_msgs/msg/twist_with_covariance"
  """
  def get_file_name_from_type(type) do
    [pkg, "msg", type] = String.split(type, "/")
    Enum.join([pkg, "msg", to_down_snake(type)], "/")
  end

  @doc """
  iex> #{__MODULE__}.get_struct_name_from_type("std_msgs/msg/String")
  "std_msgs__msg__String"
  iex> #{__MODULE__}.get_struct_name_from_type("geometry_msgs/msg/TwistWithCovariance")
  "geometry_msgs__msg__TwistWithCovariance"
  """
  def get_struct_name_from_type(type) do
    [pkg, "msg", type] = String.split(type, "/")
    Enum.join([pkg, "_msg_", type], "_")
  end

  def create_fields_for_nifs_setdata_arg(type, ros2_message_type_map, var \\ "data") do
    Map.get(ros2_message_type_map, type)
    |> Enum.map_join(", ", fn {type, variable} ->
      if type in @ros2_built_in_types or is_ros2_list(type) do
        "#{var}.#{variable}"
      else
        var = "#{var}.#{variable}"
        fields = create_fields_for_nifs_setdata_arg(type, ros2_message_type_map, var)

        "{#{fields}}"
      end
    end)
  end

  def create_fields_for_nifs_readdata_return(type, ros2_message_type_map, var \\ "data") do
    Map.get(ros2_message_type_map, type)
    |> Enum.with_index()
    |> Enum.map_join(", ", fn {{type, _variable}, index} ->
      if type in @ros2_built_in_types or
           is_ros2_list(type) do
        "#{var}_#{to_string(index)}"
      else
        var = "#{var}_#{to_string(index)}"
        fields = create_fields_for_nifs_readdata_return(type, ros2_message_type_map, var)

        "{#{fields}}"
      end
    end)
  end

  def create_fields_for_read(type, ros2_message_type_map, var \\ "data") do
    Map.get(ros2_message_type_map, type)
    |> Enum.with_index()
    |> Enum.map_join(", ", fn
      {{type, variable}, index} ->
        if type in @ros2_built_in_types or is_ros2_list(type) do
          var = "#{var}_#{to_string(index)}"
          "#{variable}: #{var}"
        else
          var = "#{var}_#{to_string(index)}"
          module_name = get_module_name_from_type(type)
          fields = create_fields_for_read(type, ros2_message_type_map, var)

          "#{variable}: %#{module_name}{#{fields}}"
        end
    end)
  end

  def create_fields_for_defstruct(type, ros2_message_type_map) do
    Map.get(ros2_message_type_map, type)
    |> Enum.map_join(", ", fn {type, variable} ->
      if type in @ros2_built_in_types or is_ros2_list(type) do
        "#{variable}: nil"
      else
        module_name = get_module_name_from_type(type)
        fields = create_fields_for_defstruct(type, ros2_message_type_map)

        "#{variable}: %#{module_name}{#{fields}}"
      end
    end)
  end

  def create_fields_for_type(type, ros2_message_type_map) do
    Map.get(ros2_message_type_map, type)
    |> Enum.map_join(", ", fn {type, variable} ->
      cond do
        type in @ros2_built_in_types ->
          "#{variable}: #{@ros2_elixir_type_map[type]}"

        is_ros2_list(type) ->
          "#{variable}: [#{@ros2_elixir_type_map[list_type(type)]}]"

        {type, variable} ->
          module_name = get_module_name_from_type(type)
          fields = create_fields_for_type(type, ros2_message_type_map)

          "#{variable}: %#{module_name}{#{fields}}"
      end
    end)
  end

  @spec create_readdata_statements(String.t(), map()) :: String.t()
  def create_readdata_statements(type, ros2_message_type_map) do
    type_var_list = Map.get(ros2_message_type_map, type)

    statements =
      type_var_list
      |> Enum.map_join(",\n  ", fn {type, var} ->
        create_readdata_statements_impl(type, ros2_message_type_map, var)
      end)

    "enif_make_tuple(env,#{Enum.count(type_var_list)},\n  #{statements})"
  end

  # credo:disable-for-next-line
  def create_readdata_statements_impl(type, ros2_message_type_map, var)
      when type in @ros2_built_in_types and is_map(ros2_message_type_map) do
    case type do
      "bool" ->
        "enif_make_atom(env,(res->#{var}?\"true\":\"false\"))"

      "int64" ->
        "enif_make_int64(env,res->#{var})"

      "int" <> _ ->
        "enif_make_int(env,res->#{var})"

      "uint64" ->
        "enif_make_uint64(env,res->#{var})"

      "uint" <> _ ->
        "enif_make_uint(env,res->#{var})"

      "float" <> _ ->
        "enif_make_double(env,res->#{var})"

      "string" ->
        "enif_make_string(env,res->#{var}.data,ERL_NIF_LATIN1)"

      "wstring" ->
        "enif_make_string(env,(char*)(res->#{var}.data),ERL_NIF_LATIN1)"
    end
  end

  def create_readdata_statements_impl(type, ros2_message_type_map, var)
      when is_map(ros2_message_type_map) do
    if is_ros2_list(type) do
      create_readdata_statements_impl_for_list(type, ros2_message_type_map, var)
    else
      create_readdata_statements_impl_for_tuple(type, ros2_message_type_map, var)
    end
  end

  def create_readdata_statements_impl_for_list(type, ros2_message_type_map, var)
      when is_map(ros2_message_type_map) do
    [_, list_type, list_length] = Regex.run(~r/^(.+)\[([0-9]+)\]$/, type)
    list_length = String.to_integer(list_length)

    statements =
      0..(list_length - 1)
      |> Enum.map_join(",\n  ", fn idx ->
        create_readdata_statements_impl(list_type, ros2_message_type_map, "#{var}[#{idx}]")
      end)

    "enif_make_list(env,#{list_length},\n  #{statements})"
  end

  def create_readdata_statements_impl_for_tuple(type, ros2_message_type_map, var)
      when is_map(ros2_message_type_map) do
    type_var_list = Map.get(ros2_message_type_map, type)

    statements =
      Enum.map_join(type_var_list, ",\n  ", fn {t, v} ->
        create_readdata_statements_impl(t, ros2_message_type_map, "#{var}.#{v}")
      end)

    "enif_make_tuple(env,#{Enum.count(type_var_list)},\n  #{statements})"
  end

  def create_setdata_statements(type, ros2_message_type_map) do
    type_var_list = Map.get(ros2_message_type_map, type)

    statements =
      type_var_list
      |> Enum.with_index()
      |> Enum.map_join(fn {{type, var}, index} ->
        create_setdata_statements_impl(
          type,
          ros2_message_type_map,
          var,
          "data[#{index}]",
          "data_#{index}"
        )
      end)

    """
    int data_arity;
    const ERL_NIF_TERM* data;
    if(!enif_get_tuple(env,argv[1],&data_arity,&data)) {
      return enif_make_badarg(env);
    }
    if(data_arity != #{Enum.count(type_var_list)}) {
      return enif_make_badarg(env);
    }
    """ <> "#{statements}"
  end

  # credo:disable-for-next-line
  def create_setdata_statements_impl(type, ros2_message_type_map, var_res, var_term, var_local)
      when type in @ros2_built_in_types and is_map(ros2_message_type_map) do
    case type do
      "bool" ->
        """
        unsigned #{var_local};
        if(!enif_get_atom_length(env,#{var_term}},&#{var_local},ERL_NIF_LATIN1)) {
          return enif_make_badarg(env);
        }
        if(#{var_local} == 4) res->#{var_res} = true;
        else if(#{var_local} == 5) res->#{var_res} = false;
        """

      "int64" ->
        """
        int64_t #{var_local};
        if(!enif_get_int64(env,#{var_term},&#{var_local})) {
          return enif_make_badarg(env);
        }
        res->#{var_res} = #{var_local};
        """

      "int" <> _ ->
        """
        int #{var_local};
        if(!enif_get_int(env,#{var_term},&#{var_local})) {
          return enif_make_badarg(env);
        }
        res->#{var_res} = #{var_local};
        """

      "uint64" ->
        """
        uint64_t #{var_local};
        if(!enif_get_uint64(env,#{var_term},&#{var_local})) {
          return enif_make_badarg(env);
        }
        res->#{var_res} = #{var_local};
        """

      "uint" <> _ ->
        """
        uint #{var_local};
        if(!enif_get_uint(env,#{var_term},&#{var_local})) {
          return enif_make_badarg(env);
        }
        res->#{var_res} = #{var_local};
        """

      "float" <> _ ->
        """
        double #{var_local};
        if(!enif_get_double(env,#{var_term},&#{var_local})) {
          return enif_make_badarg(env);
        }
        res->#{var_res} = #{var_local};
        """

      "string" ->
        """
        unsigned #{var_local}_length;
        if(!enif_get_list_length(env,#{var_term},&#{var_local}_length)) {
          return enif_make_badarg(env);
        }
        char* #{var_local} = (char*) malloc(#{var_local}_length + 1);
        if(!enif_get_string(env,#{var_term},#{var_local},#{var_local}_length + 1,ERL_NIF_LATIN1)) {
          return enif_make_badarg(env);
        }
        __STRING__ASSIGN(&(res->#{var_res}),#{var_local});
        free(#{var_local});
        """

      "wstring" ->
        """
        unsigned #{var_local}_length;
        if(!enif_get_list_length(env,#{var_term},&#{var_local}_length)) {
        return enif_make_badarg(env);
        }
        char* #{var_local} = (char*) malloc(#{var_local}_length + 1);
        if(!enif_get_string(env,#{var_term},#{var_local},#{var_local}_length + 1,ERL_NIF_LATIN1)) {
        return enif_make_badarg(env);
        }
        __U16STRING__ASSIGN(&(#{var_term}),#{var_local});
        free(#{var_local});
        """
    end
  end

  def create_setdata_statements_impl(type, ros2_message_type_map, var, var_term, var_local) do
    if is_ros2_list(type) do
      create_setdata_statements_impl_for_list(
        type,
        ros2_message_type_map,
        var,
        var_term,
        var_local
      )
    else
      create_setdata_statements_impl_for_tuple(
        type,
        ros2_message_type_map,
        var,
        var_term,
        var_local
      )
    end
  end

  def create_setdata_statements_impl_for_list(
        type,
        ros2_message_type_map,
        var,
        var_term,
        var_local
      )
      when is_map(ros2_message_type_map) do
    [_, list_type, list_length] = Regex.run(~r/^(.+)\[([0-9]+)\]$/, type)
    list_length = String.to_integer(list_length)

    statements =
      for idx <- 0..(list_length - 1) do
        """
        if(!enif_get_list_cell(env,#{var_local}_list,&#{var_local}_head,&#{var_local}_tail)) {
          return enif_make_badarg(env);
        }
        #{var_local}_list = #{var_local}_tail;
        """ <>
          create_setdata_statements_impl(
            list_type,
            ros2_message_type_map,
            "#{var}[#{idx}]",
            "#{var_local}_head",
            "#{var_local}_#{idx}"
          )
      end

    """
    unsigned #{var_local}_length;
    if(!enif_get_list_length(env,#{var_term},&#{var_local}_length) || #{var_local}_length != #{list_length}) {
      return enif_make_badarg(env);
    }
    ERL_NIF_TERM #{var_local}_list = #{var_term};
    ERL_NIF_TERM #{var_local}_head;
    ERL_NIF_TERM #{var_local}_tail;
    """ <> "#{statements}"
  end

  def create_setdata_statements_impl_for_tuple(
        type,
        ros2_message_type_map,
        var,
        var_term,
        var_local
      )
      when is_map(ros2_message_type_map) do
    type_var_list = Map.get(ros2_message_type_map, type)

    statements =
      type_var_list
      |> Enum.with_index()
      |> Enum.map_join(fn {{t, v}, idx} ->
        create_setdata_statements_impl(
          t,
          ros2_message_type_map,
          "#{var}.#{v}",
          "#{var_local}[#{idx}]",
          "#{var_local}_#{idx}"
        )
      end)

    """
    int #{var_local}_arity;
    const ERL_NIF_TERM* #{var_local};
    if(!enif_get_tuple(env,#{var_term},&#{var_local}_arity,&#{var_local})) {
      return enif_make_badarg(env);
    }
    if(#{var_local}_arity != #{Enum.count(type_var_list)}) {
      return enif_make_badarg(env);
    }
    """ <> "#{statements}"
  end

  @doc """
  iex> #{__MODULE__}.get_module_name_impl(["std_msgs", "msg", "String"])
  "StdMsgs.Msg.String"
  iex> #{__MODULE__}.get_module_name_impl(["geometry_msgs", "msg", "TwistWithCovariance"])
  "GeometryMsgs.Msg.TwistWithCovariance"
  """
  def get_module_name_impl([pkg, msg = "msg", type]) do
    Enum.join([convert_package_name_to_capitalized(pkg), String.capitalize(msg), type], ".")
  end

  @doc """
  iex> #{__MODULE__}.convert_package_name_to_capitalized("std_msgs")
  "StdMsgs"
  """
  def convert_package_name_to_capitalized(binary) do
    String.split(binary, "_")
    |> Enum.map_join(&String.capitalize(&1))
  end

  @doc """
  iex> #{__MODULE__}.to_down_snake("Vector3")
  "vector3"
  iex> #{__MODULE__}.to_down_snake("TwistWithCovariance")
  "twist_with_covariance"
  """
  def to_down_snake(type_name) do
    String.split(type_name, ~r/[A-Z][a-z0-9]+/, include_captures: true, trim: true)
    |> Enum.map_join("_", &String.downcase(&1))
  end

  defp rclex_dir_path!() do
    if Mix.Project.config()[:app] == :rclex do
      File.cwd!()
    else
      Path.join(File.cwd!(), "deps/rclex")
    end
  end

  defp recompile!() do
    if Mix.Project.config()[:app] == :rclex do
      Mix.Task.rerun("compile.elixir_make")
    else
      Mix.Task.rerun("deps.compile", ["rclex", "--force"])
    end
  end

  defp is_ros2_built_in_list(type) do
    is_ros2_list(type) and list_type(type) in @ros2_built_in_types
  end

  defp is_ros2_list(type) when is_binary(type) do
    String.match?(type, ~r/.+\[[0-9]+\]/)
  end

  defp list_type(type) do
    String.split(type, "[") |> List.first()
  end

  defp templates_dir_path() do
    Path.join(Application.app_dir(:rclex), "priv/templates/rclex.gen.msgs")
  end
end
