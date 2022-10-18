defmodule Mix.Tasks.Rclex.Gen.Msgs do
  @shortdoc "Generate codes of ROS2 message type"
  @moduledoc """
  #{@shortdoc}

  Before generating, we have to specify message types in config.exs.

  ex. config :rclex, ros2_message_types ["std_msgs/msg/String"]

  Be careful, ros2 message type is case sensitive.

  ## How to generate

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
      [from: from] -> generate(from, File.cwd!())
      [clean: true] -> clean()
      [show_types: true] -> show_types()
      _ -> Mix.shell().info(@moduledoc)
    end
  end

  def generate(from, to) do
    types = Application.get_env(:rclex, :ros2_message_types, [])

    if Enum.empty?(types) do
      raise RuntimeError, "ros2_message_types is not specified in config"
    end

    ros2_message_type_map =
      Enum.reduce(types, %{}, fn type, acc ->
        get_ros2_message_type_map(type, from, acc)
      end)

    types = Map.keys(ros2_message_type_map)

    Enum.map(types, fn type ->
      [package_name, "msg", type_name] = String.split(type, "/")
      type_name = String.downcase(type_name)

      dir_path_ex = Path.join(to, "lib/rclex/#{package_name}/msg")
      dir_path_c = Path.join(to, "src/#{package_name}/msg")

      File.mkdir_p!(dir_path_ex)
      File.mkdir_p!(dir_path_c)

      [
        {dir_path_ex, "#{type_name}_impl.ex", generate_msg_prot(type, ros2_message_type_map)},
        {dir_path_ex, "#{type_name}.ex", generate_msg_mod(type, ros2_message_type_map)},
        {dir_path_c, "#{type_name}_nif.c", generate_msg_nif_c(type, ros2_message_type_map)},
        {dir_path_c, "#{type_name}_nif.h", generate_msg_nif_h(type, ros2_message_type_map)}
      ]
      |> Enum.map(fn {dir_path, file_name, binary} ->
        File.write!(Path.join(dir_path, file_name), binary)
      end)
    end)
  end

  def clean() do
    raise RuntimeError, "not implemented"
  end

  def show_types() do
    types = Application.get_env(:rclex, :ros2_message_types, [])

    if Enum.empty?(types) do
      raise RuntimeError, "ros2_message_types is not specified in config"
    end

    Mix.shell().info(Enum.join(types, " "))
  end

  def generate_msg_prot(type, ros2_message_type_map) do
    EEx.eval_file("lib/mix/tasks/rclex/gen/msg_prot_impl.eex",
      module_name: get_module_name_from_type(type),
      function_name: get_function_name_from_type(type),
      nifs_readdata_return_fields:
        create_fields_for_nifs_readdata_return(type, ros2_message_type_map),
      read_return_module_fields: create_fields_for_read(type, ros2_message_type_map),
      setdata_arg_fields: create_fields_for_nifs_setdata_arg(type, ros2_message_type_map)
    )
  end

  def generate_msg_mod(type, ros2_message_type_map) do
    module_name = get_module_name_from_type(type)

    EEx.eval_file("lib/mix/tasks/rclex/gen/msg_mod.eex",
      module_name: module_name,
      defstruct_fields: create_fields_for_defstruct(type, ros2_message_type_map),
      type_fields: create_fields_for_type(type, ros2_message_type_map)
    )
  end

  def generate_msg_nif_c(type, ros2_message_type_map) do
    [package_name, "msg", type_name] = String.split(type, "/")

    EEx.eval_file("lib/mix/tasks/rclex/gen/msg_nif_c.eex",
      function_name: get_function_name_from_type(type),
      file_name: String.downcase(type),
      package_name: package_name,
      type_name: type_name,
      struct_name: "#{package_name}__msg__#{type_name}",
      readdata_statements: create_readdata_statements(type, ros2_message_type_map),
      setdata_statements: create_setdata_statements(type, ros2_message_type_map)
    )
  end

  def generate_msg_nif_h(type, _ros2_message_type_map) do
    EEx.eval_file("lib/mix/tasks/rclex/gen/msg_nif_h.eex",
      function_name: get_function_name_from_type(type)
    )
  end

  @spec get_ros2_message_type_map(String.t(), String.t(), map()) :: map()
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
          String.contains?(type, "/") -> {type, variable}
          true -> {Path.join("#{package_name}/msg", type), variable}
        end
      end)

    type_map = Map.put(acc, ros2_message_type, type_variable_tuples)

    Enum.reduce(type_variable_tuples, type_map, fn {type, _variable}, acc ->
      cond do
        type in @ros2_built_in_types -> acc
        Map.has_key?(type_map, type) -> acc
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
  """
  def get_module_name_from_type(type) do
    if not String.contains?(type, "/") do
      raise RuntimeError, "type must contain ROS2 package name"
    end

    String.split(type, "/")
    |> get_module_name_impl()
    |> then(&"Rclex.#{&1}")
  end

  @doc """
  iex> #{__MODULE__}.get_function_name_from_type("std_msgs/msg/String")
  "std_msgs_msg_string"
  """
  def get_function_name_from_type(type) do
    String.split(type, "/")
    |> Enum.map_join("_", &String.downcase(&1))
  end

  @doc """
  iex> #{__MODULE__}.get_file_name_from_type("std_msgs/String")
  "std_msgs/msg/string"
  """
  def get_file_name_from_type(type) do
    [package_name, type_name] = String.split(type, "/")

    [package_name, "msg", type_name]
    |> Enum.map_join("/", &String.downcase(&1))
  end

  def create_fields_for_nifs_setdata_arg(type, ros2_message_type_map, vars \\ ["data"]) do
    Map.get(ros2_message_type_map, type)
    |> Enum.map_join(", ", fn
      {type, variable} when type in @ros2_built_in_types ->
        var_name = [variable | vars] |> Enum.reverse() |> Enum.join(".")

        "#{var_name}"

      {type, variable} ->
        vars = [variable | vars]

        "{#{create_fields_for_nifs_setdata_arg(type, ros2_message_type_map, vars)}}"
    end)
  end

  def create_fields_for_nifs_readdata_return(type, ros2_message_type_map, vars \\ ["data"]) do
    Map.get(ros2_message_type_map, type)
    |> Enum.with_index()
    |> Enum.map_join(", ", fn
      {{type, _variable}, index} when type in @ros2_built_in_types ->
        var_name = [to_string(index) | vars] |> Enum.reverse() |> Enum.join("_")

        "#{var_name}"

      {{type, _variable}, index} ->
        vars = [to_string(index) | vars]

        "{#{create_fields_for_nifs_readdata_return(type, ros2_message_type_map, vars)}}"
    end)
  end

  def create_fields_for_read(type, ros2_message_type_map, vars \\ ["data"]) do
    Map.get(ros2_message_type_map, type)
    |> Enum.with_index()
    |> Enum.map_join(", ", fn
      {{type, variable}, index} when type in @ros2_built_in_types ->
        var_name = [to_string(index) | vars] |> Enum.reverse() |> Enum.join("_")

        "#{variable}: #{var_name}"

      {{type, variable}, index} ->
        vars = [to_string(index) | vars]

        "#{variable}: %#{get_module_name_from_type(type)}{#{create_fields_for_read(type, ros2_message_type_map, vars)}}"
    end)
  end

  def create_fields_for_defstruct(type, ros2_message_type_map) do
    Map.get(ros2_message_type_map, type)
    |> Enum.map_join(", ", fn
      {type, variable} when type in @ros2_built_in_types ->
        "#{variable}: nil"

      {type, variable} ->
        "#{variable}: %#{get_module_name_from_type(type)}{#{create_fields_for_defstruct(type, ros2_message_type_map)}}"
    end)
  end

  def create_fields_for_type(type, ros2_message_type_map) do
    Map.get(ros2_message_type_map, type)
    |> Enum.map_join(", ", fn
      {type, variable} when type in @ros2_built_in_types ->
        "#{variable}: #{@ros2_elixir_type_map[type]}"

      {type, variable} ->
        "#{variable}: %#{get_module_name_from_type(type)}{#{create_fields_for_type(type, ros2_message_type_map)}}"
    end)
  end

  @spec create_readdata_statements(Stiring.t(), map()) :: String.t()
  def create_readdata_statements(type, ros2_message_type_map) do
    create_readdata_statements_impl(type, ros2_message_type_map, [])
  end

  def create_readdata_statements_impl(type, ros2_message_type_map, vars)
      when type in @ros2_built_in_types and is_map(ros2_message_type_map) do
    var = vars |> Enum.reverse() |> Enum.join(".")

    case type do
      "float64" ->
        "enif_make_double(env,res->#{var})"

      "string" ->
        "enif_make_string(env,res->#{var}.data,ERL_NIF_LATIN1)"
    end
  end

  def create_readdata_statements_impl(type, ros2_message_type_map, vars)
      when is_map(ros2_message_type_map) do
    type_var_list = Map.get(ros2_message_type_map, type)

    statements =
      Enum.map_join(type_var_list, ",\n  ", fn {type, var} ->
        create_readdata_statements_impl(type, ros2_message_type_map, [var | vars])
      end)

    "enif_make_tuple(env,#{Enum.count(type_var_list)},\n  #{statements})"
  end

  def create_setdata_statements(type, ros2_message_type_map) do
    type_var_list = Map.get(ros2_message_type_map, type)

    statements =
      type_var_list
      |> Enum.with_index()
      |> Enum.map(fn {{type, var}, index} ->
        create_setdata_statements_impl(type, ros2_message_type_map, [var], "data", index)
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

  def create_setdata_statements_impl(type, ros2_message_type_map, vars, var_caller, index)
      when type in @ros2_built_in_types and is_map(ros2_message_type_map) do
    var = vars |> Enum.reverse() |> Enum.join(".")
    var_local = "#{var_caller}_#{index}"

    case type do
      "float64" ->
        """
        double #{var_local};
        if(!enif_get_double(env,#{var_caller}[#{index}],&#{var_local})) {
          return enif_make_badarg(env);
        }
        res->#{var} = #{var_local};
        """

      "string" ->
        """
        unsigned #{var_local}_length;
        if(!enif_get_list_length(env,#{var_caller}[#{index}],&#{var_local}_length)) {
          return enif_make_badarg(env);
        }
        char* #{var_local} = (char*) malloc(#{var_local}_length + 1);
        if(!enif_get_string(env,#{var_caller}[#{index}],#{var_local},#{var_local}_length + 1,ERL_NIF_LATIN1)) {
          return enif_make_badarg(env);
        }
        __STRING__ASSIGN(&(res->#{var}),#{var_local});
        free(#{var_local});
        """
    end
  end

  def create_setdata_statements_impl(type, ros2_message_type_map, vars, var_prefix, index)
      when is_map(ros2_message_type_map) do
    type_var_list = Map.get(ros2_message_type_map, type)

    statements =
      type_var_list
      |> Enum.with_index()
      |> Enum.map_join(fn {{type, var}, idx} ->
        create_setdata_statements_impl(
          type,
          ros2_message_type_map,
          [var | vars],
          "#{var_prefix}_#{index}",
          idx
        )
      end)

    """
    int #{var_prefix}_#{index}_arity;
    const ERL_NIF_TERM* #{var_prefix}_#{index};
    if(!enif_get_tuple(env,#{var_prefix}[#{index}],&#{var_prefix}_#{index}_arity,&#{var_prefix}_#{index})) {
      return enif_make_badarg(env);
    }
    if(#{var_prefix}_#{index}_arity != #{Enum.count(type_var_list)}) {
      return enif_make_badarg(env);
    }
    """ <> "#{statements}"
  end

  @doc """
  iex> #{__MODULE__}.get_module_name_impl(["std_msgs", "msg", "String"])
  "StdMsgs.Msg.String"
  """
  def get_module_name_impl(list) when is_list(list) do
    list
    |> Enum.map_join(".", fn binary ->
      if String.contains?(binary, "_") do
        convert_package_name_to_capitalized_binary(binary)
      else
        String.capitalize(binary)
      end
    end)
  end

  @doc """
  iex> #{__MODULE__}.convert_package_name_to_capitalized_binary("std_msgs")
  "StdMsgs"
  """
  def convert_package_name_to_capitalized_binary(binary) do
    String.split(binary, "_")
    |> Enum.map_join(&String.capitalize(&1))
  end

  @doc """
  iex> #{__MODULE__}.relative_msg_file_path("std_msgs", "String")
  "std_msgs/msg/String.msg"
  """
  def relative_msg_file_path(package_name, type_name) do
    Enum.join([package_name, "msg", type_name], "/") <> ".msg"
  end
end