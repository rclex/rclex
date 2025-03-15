defmodule Mix.Tasks.Rclex.Gen.Msgs do
  @shortdoc "Generate codes of ROS 2 msg type"
  @moduledoc """
  #{@shortdoc}

  Before generating, specify msg types in config.exs is needed.

  ```
  config :rclex, ros2_message_types: ["std_msgs/msg/String"]
  ```

  > #### Info {: .info }
  > Be careful, ros2 msg type is case sensitive.

  ## How to generate

  ```
  mix rclex.gen.msgs
  ```

  This task assumes that the environment variable `ROS_DISTRO` is set
  and refers to the msg types from `/opt/ros/[ROS_DISTRO]/share`.

  We can also specify explicitly as follows

  ```
  mix rclex.gen.msgs --from /opt/ros/humble/share
  ```

  ## How to clean

  ```
  mix rclex.gen.msgs --clean
  ```
  """

  use Mix.Task

  alias Rclex.Parsers.MessageParser
  alias Rclex.Generators.MsgEx
  alias Rclex.Generators.MsgH
  alias Rclex.Generators.MsgC
  alias Rclex.Generators.Util

  @doc false
  def run(args) do
    {valid_options, _, _} =
      OptionParser.parse(args, strict: [from: :string, clean: :boolean, show_types: :boolean])

    case valid_options do
      [] ->
        clean()
        generate(rclex_dir_path!())
        recompile!()

      [from: from] ->
        clean()
        generate(from, rclex_dir_path!())
        recompile!()

      [clean: true] ->
        clean()

      [show_types: true] ->
        show_types()

      _ ->
        Mix.shell().info(@moduledoc)
    end
  end

  @doc false
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

  @doc false
  def generate(from, to) do
    types = Application.get_env(:rclex, :ros2_message_types, [])

    if Enum.empty?(types) do
      Mix.raise("ros2_message_types is not specified in config.")
    end

    ros2_message_type_map =
      Enum.reduce(types, %{}, fn type, acc -> get_ros2_message_type_map(type, from, acc) end)

    types = Map.keys(ros2_message_type_map)

    for {:msg_type, type} <- types do
      [interfaces, "msg", type_name] = String.split(type, "/")
      type_name = Util.to_down_snake(type_name)

      dir_path_ex = Path.join(to, "lib/rclex/pkgs/#{interfaces}/msg")
      dir_path_c = Path.join(to, "src/pkgs/#{interfaces}/msg")

      File.mkdir_p!(dir_path_ex)
      File.mkdir_p!(dir_path_c)

      for {dir_path, file_name, binary} <- [
            {dir_path_ex, "#{type_name}.ex", MsgEx.generate(type, ros2_message_type_map)},
            {dir_path_c, "#{type_name}.h", MsgH.generate(type, ros2_message_type_map)},
            {dir_path_c, "#{type_name}.c", MsgC.generate(type, ros2_message_type_map)}
          ] do
        File.write!(Path.join(dir_path, file_name), binary)
      end
    end

    File.write!(Path.join(to, "lib/rclex/msg_funcs.ex"), generate_msg_funcs_ex(types))
    File.write!(Path.join(to, "src/msg_funcs.h"), generate_msg_funcs_h(types))
    File.write!(Path.join(to, "src/msg_funcs.ec"), generate_msg_funcs_c(types))
  end

  @doc false
  def clean() do
    dir_path = rclex_dir_path!()

    for file_path <- ["lib/rclex/pkgs", "src/pkgs"] do
      File.rm_rf!(Path.join(dir_path, file_path))
    end

    for file_path <- ["lib/rclex/msg_funcs.ex", "src/msg_funcs.h", "src/msg_funcs.ec"] do
      File.rm_rf!(Path.join(dir_path, file_path))
    end
  end

  @doc false
  def show_types() do
    types = Application.get_env(:rclex, :ros2_message_types, [])

    if Enum.empty?(types) do
      Mix.raise("ros2_message_types is not specified in config.")
    end

    Mix.shell().info(Enum.join(types, " "))
  end

  @doc false
  def generate_msg_funcs_c(types) do
    Enum.map_join(types, fn {:msg_type, type} ->
      function_prefix = Util.type_down_snake(type)

      # WHY: Use ERL_NIF_DIRTY_JOB_IO_BOUND for destroy!, set!, and get!
      #      These functions (de)allocate memory, and the size depends on the payload.
      #      Therefore, the time required for the operations is unpredictable.
      """
      {"#{function_prefix}_type_support!", 0, nif_#{function_prefix}_type_support, REGULAR_NIF},
      {"#{function_prefix}_create!", 0, nif_#{function_prefix}_create, REGULAR_NIF},
      {"#{function_prefix}_destroy!", 1, nif_#{function_prefix}_destroy, ERL_NIF_DIRTY_JOB_IO_BOUND},
      {"#{function_prefix}_set!", 2, nif_#{function_prefix}_set, ERL_NIF_DIRTY_JOB_IO_BOUND},
      {"#{function_prefix}_get!", 1, nif_#{function_prefix}_get, ERL_NIF_DIRTY_JOB_IO_BOUND},
      {"#{function_prefix}_publish!", 2, nif_#{function_prefix}_publish, ERL_NIF_DIRTY_JOB_IO_BOUND},
      {"#{function_prefix}_take!", 1, nif_#{function_prefix}_take, ERL_NIF_DIRTY_JOB_IO_BOUND},
      """
    end)
  end

  @doc false
  def generate_msg_funcs_h(types) do
    Enum.map_join(types, fn {:msg_type, type} ->
      [interfaces, "msg", type] = String.split(type, "/")
      file_path = Path.join([interfaces, "msg", Util.to_down_snake(type)]) <> ".h"

      """
      #include "pkgs/#{file_path}"
      """
    end)
  end

  @doc false
  def generate_msg_funcs_ex(types) do
    suffix_args_list = [
      {"type_support!", ""},
      {"create!", ""},
      {"destroy!", "_msg"},
      {"set!", "_msg, _data"},
      {"get!", "_msg"},
      {"publish!", "_publisher, _data"},
      {"take!", "_subscription"}
    ]

    msg_funcs =
      for {:msg_type, type} <- types, {suffix, args} <- suffix_args_list do
        prefix = Util.type_down_snake(type)

        """
        def #{prefix}_#{suffix}(#{args}) do
          :erlang.nif_error(:nif_not_loaded)
        end
        """
      end
      |> Enum.join()

    EEx.eval_file(Path.join(Util.templates_dir_path(), "msg_funcs.eex"), msg_funcs: msg_funcs)
    |> Code.format_string!()
    |> IO.iodata_to_binary()
    |> then(&"#{&1}\n")
  end

  @doc false
  def get_ros2_message_type_map(ros2_message_type, from, acc \\ %{}) do
    {:ok, fields, _rest, _context, _line, _column} =
      Path.join(from, [ros2_message_type, ".msg"])
      |> File.read!()
      |> MessageParser.parse()

    fields = to_complete_fields(fields, ros2_message_type)
    type_map = Map.put(acc, {:msg_type, ros2_message_type}, fields)

    Enum.reduce(fields, type_map, fn [head | _], acc ->
      case head do
        {:builtin_type, _type} ->
          acc

        {:builtin_type_array, _type} ->
          acc

        {:msg_type, type} ->
          get_ros2_message_type_map(type, from, acc)

        {:msg_type_array, type} ->
          get_ros2_message_type_map(get_array_type(type), from, acc)
      end
    end)
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

  defp to_complete_fields(fields, ros2_message_type) do
    Enum.map(fields, fn field ->
      [head | tail] = field

      case head do
        {:msg_type, type} ->
          type = to_complete_type(type, ros2_message_type)
          [{:msg_type, type} | tail]

        {:msg_type_array, type} ->
          type = to_complete_type(type, ros2_message_type)
          [{:msg_type_array, type} | tail]

        _ ->
          field
      end
    end)
  end

  defp to_complete_type(type, ros2_message_type) do
    if String.contains?(type, "/") do
      [interfaces, type] = String.split(type, "/")
      [interfaces, "msg", type]
    else
      [interfaces, "msg", _] = String.split(ros2_message_type, "/")
      [interfaces, "msg", type]
    end
    |> Path.join()
  end

  defp get_array_type(type) do
    String.replace(type, ~r/\[.*\]$/, "")
  end
end
