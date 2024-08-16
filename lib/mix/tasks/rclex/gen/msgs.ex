defmodule Mix.Tasks.Rclex.Gen.Msgs do
  @shortdoc "Generate codes of ROS 2 msg type"
  @moduledoc """
  #{@shortdoc}

  Before generating, specifying msg types in config.exs is needed.

  ```
  config :rclex, ros2_message_types: ["std_msgs/msg/String"]
  ```

  The task also generates the code for the request and response message types required by the services defined in

  ```
  config :rclex, ros2_service_types: ["std_srvs/srv/SetBool"]
  ```

  and the message types required for internal topics and services of actions defined in

  ```
  config :rclex, ros2_action_types: ["turtlesim/action/RotateAbsolute"]
  ```

  > #### Info {: .info }
  > Be careful, ros2 msg type is case sensitive.

  ## How to show message types

  ```
  mix rclex.gen.msgs --show-types
  ```

  ## How to generate

  ```
  mix rclex.gen.msgs
  ```

  This task assumes that the environment variable `ROS_DISTRO` is set
  and refers to the msg types from `/opt/ros/[ROS_DISTRO]/share`.
  In addition `AMENT_PREFIX_PATH` is considered to find msg types.

  We can also specify explicitly as follows

  ```
  mix rclex.gen.msgs --from /opt/ros/humble/share --from /home/ros/workspace/install
  ```

  or via configuration

  ```
  config :rclex, ros2_directories: ["/home/ros/workspace/install/example_msgs"]
  ```

  ## How to clean

  ```
  mix rclex.gen.msgs --clean
  ```
  """

  use Mix.Task

  alias Rclex.Parsers.MessageParser
  alias Rclex.Parsers.ConstantParser
  alias Rclex.Generators.MsgEx
  alias Rclex.Generators.MsgH
  alias Rclex.Generators.MsgC
  alias Rclex.Generators.Util
  alias Mix.Tasks.Rclex.Gen

  @doc false
  def run(args) do
    {valid_options, _, _} =
      OptionParser.parse(args, strict: [from: :keep, clean: :boolean, show_types: :boolean])

    {from, valid_options} = Keyword.pop_values(valid_options, :from)

    case valid_options do
      [] when from != [] ->
        clean()
        generate(from, Gen.rclex_dir_path!())
        Gen.recompile!()

      [] ->
        clean()
        generate(Gen.rclex_dir_path!())
        Gen.recompile!()

      [clean: true] when from == [] ->
        clean()

      [show_types: true] when from == [] ->
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

    ament_directories =
      Enum.map(String.split(System.get_env("AMENT_PREFIX_PATH", ""), [":", ";"]), fn d ->
        Path.join(d, "share")
      end)

    configured_directories =
      Enum.map(Application.get_env(:rclex, :ros2_directories, []), fn d ->
        Path.join(d, "share")
      end)

    ros_directories =
      if Mix.target() == :host do
        cond do
          configured_directories == [] and ament_directories == [] ->
            [Path.join("/opt/ros/#{ros_distro}", "share")]

          configured_directories != [] ->
            configured_directories ++ [Path.join("/opt/ros/#{ros_distro}", "share")]

          ament_directories != [] ->
            ament_directories
        end
      else
        configured_directories ++ [Path.join(File.cwd!(), "rootfs_overlay/opt/ros/#{ros_distro}")]
      end

    if Enum.any?(ros_directories, fn d -> not File.exists?(d) end) do
      Mix.raise("#{inspect(ros_directories)} does not exist.")
    end

    generate(ros_directories, to)
  end

  @doc false
  def generate(from, to) when is_list(from) and is_binary(to) do
    msg_types = Application.get_env(:rclex, :ros2_message_types, [])
    srv_types = Application.get_env(:rclex, :ros2_service_types, [])
    action_types = Application.get_env(:rclex, :ros2_action_types, [])

    if Enum.empty?(msg_types) do
      Mix.raise("ros2_message_types is not specified in config.")
    end

    msg_types =
      msg_types ++
        Enum.map(srv_types, fn type -> String.replace_suffix(type, "", "_Request") end) ++
        Enum.map(srv_types, fn type -> String.replace_suffix(type, "", "_Response") end)

    msg_types = msg_types ++ msg_types_for_actions(action_types)

    ros2_message_type_map =
      Enum.reduce(msg_types, %{}, fn type, acc ->
        get_ros2_message_type_map(type, from, acc)
      end)

    types = Map.keys(ros2_message_type_map)

    ros2_constant_type_map =
      Enum.reduce(types, %{}, fn {:msg_type, type}, acc ->
        get_ros2_constant_type_map(type, from, acc)
      end)

    for {:msg_type, type} <- types do
      [interfaces, interface_type, type_name] = String.split(type, "/")

      if interface_type != "msg" and interface_type != "srv" and interface_type != "action" do
        raise "unknown interface type #{interface_type}"
      end

      type_name = Util.to_down_snake(type_name)

      dir_path_ex = Path.join(to, "lib/rclex/pkgs/#{interfaces}/#{interface_type}")
      dir_path_c = Path.join(to, "src/pkgs/#{interfaces}/#{interface_type}")

      File.mkdir_p!(dir_path_ex)
      File.mkdir_p!(dir_path_c)

      for {dir_path, file_name, binary} <- [
            {dir_path_ex, "#{type_name}.ex",
             MsgEx.generate(type, ros2_message_type_map, ros2_constant_type_map)},
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
    dir_path = Gen.rclex_dir_path!()

    for file_path <-
          Path.wildcard(Path.join(dir_path, "lib/rclex/pkgs/*/msg/*.ex")) ++
            Path.wildcard(Path.join(dir_path, "src/pkgs/*/msg/*.{h,c}")) ++
            Path.wildcard(Path.join(dir_path, "src/pkgs/*/srv/*__request.{h,c}")) ++
            Path.wildcard(Path.join(dir_path, "lib/rclex/pkgs/*/srv/*__request.ex")) ++
            Path.wildcard(Path.join(dir_path, "src/pkgs/*/srv/*__response.{h,c}")) ++
            Path.wildcard(Path.join(dir_path, "lib/rclex/pkgs/*/srv/*__response.ex")) ++
            Path.wildcard(Path.join(dir_path, "lib/rclex/pkgs/*/action/*__response.ex")) ++
            Path.wildcard(Path.join(dir_path, "lib/rclex/pkgs/*/action/*__request.ex")) ++
            Path.wildcard(Path.join(dir_path, "lib/rclex/pkgs/*/action/*__feedback_message.ex")) ++
            Path.wildcard(Path.join(dir_path, "lib/rclex/pkgs/*/action/*__feedback.ex")) ++
            Path.wildcard(Path.join(dir_path, "lib/rclex/pkgs/*/action/*__goal.ex")) ++
            Path.wildcard(Path.join(dir_path, "lib/rclex/pkgs/*/action/*__result.ex")) ++
            Path.wildcard(Path.join(dir_path, "src/pkgs/*/action/*__response.{h,c}")) ++
            Path.wildcard(Path.join(dir_path, "src/pkgs/*/action/*__request.{h,c}")) ++
            Path.wildcard(Path.join(dir_path, "src/pkgs/*/action/*__feedback_message.{h,c}")) ++
            Path.wildcard(Path.join(dir_path, "src/pkgs/*/action/*__feedback.{h,c}")) ++
            Path.wildcard(Path.join(dir_path, "src/pkgs/*/action/*__goal.{h,c}")) ++
            Path.wildcard(Path.join(dir_path, "src/pkgs/*/action/*__result.{h,c}")) do
      File.rm!(file_path)
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

      """
      {"#{function_prefix}_type_support!", 0, nif_#{function_prefix}_type_support, REGULAR_NIF},
      {"#{function_prefix}_create!", 0, nif_#{function_prefix}_create, REGULAR_NIF},
      {"#{function_prefix}_destroy!", 1, nif_#{function_prefix}_destroy, REGULAR_NIF},
      {"#{function_prefix}_set!", 2, nif_#{function_prefix}_set, REGULAR_NIF},
      {"#{function_prefix}_get!", 1, nif_#{function_prefix}_get, REGULAR_NIF},
      """
    end)
  end

  @doc false
  def generate_msg_funcs_h(types) do
    Enum.map_join(types, fn {:msg_type, type} ->
      [interfaces, interface_type, type] = String.split(type, "/")
      file_path = Path.join([interfaces, interface_type, Util.to_down_snake(type)]) <> ".h"

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
      {"get!", "_msg"}
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
      |> Enum.join("\n")
      |> String.replace_suffix("\n", "")
      |> String.split("\n")
      |> Enum.map_join("\n", &Kernel.<>(String.duplicate(" ", 6), &1))

    EEx.eval_file(Path.join(Util.templates_dir_path(), "msg_funcs.eex"), msg_funcs: msg_funcs)
  end

  defp msg_types_for_actions([]) do
    []
  end

  defp msg_types_for_actions(action_types) do
    action_msg_suffixes =
      [
        "_Feedback",
        "_Goal",
        "_Result",
        "_FeedbackMessage",
        "_SendGoal_Request",
        "_SendGoal_Response",
        "_GetResult_Request",
        "_GetResult_Response"
      ]

    msgs =
      Enum.reduce(action_types, [], fn action, acc ->
        Enum.map(action_msg_suffixes, fn s -> action <> s end) ++ acc
      end)

    [
      "action_msgs/msg/GoalStatusArray",
      "action_msgs/srv/CancelGoal_Request",
      "action_msgs/srv/CancelGoal_Response"
    ] ++ msgs
  end

  defp get_msg_path(ros2_message_type, from) do
    [package, _, type_name] = String.split(ros2_message_type, "/")

    pathes =
      Enum.reduce(from, [], fn dir, acc ->
        Path.wildcard("#{dir}/#{package}/**/#{type_name}.msg") ++ acc
      end)

    if pathes == [] do
      raise "#{ros2_message_type}.msg not found"
    end

    # The first match wins, so the order of the defined directories is relevant.
    [ret | _] = pathes

    ret
  end

  defp get_srv_path(ros2_message_type, from) do
    [package, _, type_name] = String.split(ros2_message_type, "/")

    pathes =
      Enum.reduce(from, [], fn dir, acc ->
        Path.wildcard("#{dir}/#{package}/**/#{type_name}.srv") ++ acc
      end)

    if pathes == [] do
      raise "#{ros2_message_type}.srv not found"
    end

    # The first match wins, so the order of the defined directories is relevant.
    [ret | _] = pathes

    ret
  end

  defp get_action_path(ros2_message_type, from) do
    [package, "action", type_name] = String.split(ros2_message_type, "/")

    pathes =
      Enum.reduce(from, [], fn dir, acc ->
        Path.wildcard("#{dir}/#{package}/**/#{type_name}.action") ++ acc
      end)

    if pathes == [] do
      raise "#{ros2_message_type}.action not found"
    end

    # The first match wins, so the order of the defined directories is relevant.
    [ret | _] = pathes

    ret
  end

  defp service_response_message_type?(ros2_message_type) do
    [_, interface_type, type] = String.split(ros2_message_type, "/")
    interface_type == "srv" and String.ends_with?(type, "_Response")
  end

  defp service_request_message_type?(ros2_message_type) do
    [_, interface_type, type] = String.split(ros2_message_type, "/")
    interface_type == "srv" and String.ends_with?(type, "_Request")
  end

  defp action_subtype?(ros2_message_type) do
    [_, interface_type, _] = String.split(ros2_message_type, "/")
    interface_type == "action"
  end

  defp action_feedback_type?(ros2_message_type) do
    [_, interface_type, type] = String.split(ros2_message_type, "/")
    interface_type == "action" and String.ends_with?(type, "_Feedback")
  end

  defp action_feedback_message_type?(ros2_message_type) do
    [_, interface_type, type] = String.split(ros2_message_type, "/")
    interface_type == "action" and String.ends_with?(type, "_FeedbackMessage")
  end

  defp action_goal_type?(ros2_message_type) do
    [_, interface_type, type] = String.split(ros2_message_type, "/")
    interface_type == "action" and String.ends_with?(type, "_Goal")
  end

  defp action_result_type?(ros2_message_type) do
    [_, interface_type, type] = String.split(ros2_message_type, "/")
    interface_type == "action" and String.ends_with?(type, "_Result")
  end

  defp action_send_goal_request_type?(ros2_message_type) do
    [_, interface_type, type] = String.split(ros2_message_type, "/")
    interface_type == "action" and String.ends_with?(type, "_SendGoal_Request")
  end

  defp action_send_goal_response_type?(ros2_message_type) do
    [_, interface_type, type] = String.split(ros2_message_type, "/")
    interface_type == "action" and String.ends_with?(type, "_SendGoal_Response")
  end

  defp action_get_result_request_type?(ros2_message_type) do
    [_, interface_type, type] = String.split(ros2_message_type, "/")
    interface_type == "action" and String.ends_with?(type, "_GetResult_Request")
  end

  defp action_get_result_response_type?(ros2_message_type) do
    [_, interface_type, type] = String.split(ros2_message_type, "/")
    interface_type == "action" and String.ends_with?(type, "_GetResult_Response")
  end

  defp get_action_feedback_type_definition(ros2_message_type, from) do
    path = get_action_path(String.trim_trailing(ros2_message_type, "_Feedback"), from)
    [_goal_msg, _result_msg, feedback_msg] = Regex.split(~r/^---\n/m, File.read!(path))
    feedback_msg
  end

  defp get_action_feedback_message_type_definition(ros2_message_type, _from) do
    [_, "action", type] = String.split(ros2_message_type, "/")
    action_type = String.trim_trailing(type, "_FeedbackMessage")

    """
    unique_identifier_msgs/UUID goal_id
    #{action_type}_Feedback feedback
    """
  end

  defp get_action_goal_type_definition(ros2_message_type, from) do
    path = get_action_path(String.trim_trailing(ros2_message_type, "_Goal"), from)
    [goal_msg, _result_msg, _feedback_msg] = Regex.split(~r/^---\n/m, File.read!(path))
    goal_msg
  end

  defp get_action_send_goal_request_type_definition(ros2_message_type, _from) do
    [_, "action", type] = String.split(ros2_message_type, "/")
    action_type = String.trim_trailing(type, "_SendGoal_Request")

    """
    unique_identifier_msgs/UUID goal_id
    #{action_type}_Goal goal
    """
  end

  defp get_action_send_goal_response_type_definition(_ros2_message_type, _from) do
    """
    bool accepted
    builtin_interfaces/Time stamp
    """
  end

  defp get_action_get_result_request_type_definition(_ros2_message_type, _from) do
    """
    unique_identifier_msgs/UUID goal_id
    """
  end

  defp get_action_get_result_response_type_definition(ros2_message_type, _from) do
    [_, "action", type] = String.split(ros2_message_type, "/")
    action_type = String.trim_trailing(type, "_GetResult_Response")

    """
    uint8 status
    #{action_type}_Result result
    """
  end

  defp get_action_get_result_type_definition(ros2_message_type, from) do
    path = get_action_path(String.trim_trailing(ros2_message_type, "_Result"), from)
    [_goal_msg, result_msg, _feedback_msg] = Regex.split(~r/^---\n/m, File.read!(path))
    result_msg
  end

  defp get_service_response_message_type_definition(ros2_message_type, from) do
    path = get_srv_path(String.trim_trailing(ros2_message_type, "_Response"), from)
    [_request_msg, response_msg] = Regex.split(~r/^---\n/m, File.read!(path))
    response_msg
  end

  defp get_service_request_message_type_definition(ros2_message_type, from) do
    path = get_srv_path(String.trim_trailing(ros2_message_type, "_Request"), from)
    [request_msg, _reponse_msg] = Regex.split(~r/^---\n/m, File.read!(path))
    request_msg
  end

  defp get_action_msg_definition(ros2_message_type, from) do
    cond do
      action_feedback_type?(ros2_message_type) ->
        get_action_feedback_type_definition(ros2_message_type, from)

      action_feedback_message_type?(ros2_message_type) ->
        get_action_feedback_message_type_definition(ros2_message_type, from)

      action_goal_type?(ros2_message_type) ->
        get_action_goal_type_definition(ros2_message_type, from)

      action_send_goal_request_type?(ros2_message_type) ->
        get_action_send_goal_request_type_definition(ros2_message_type, from)

      action_send_goal_response_type?(ros2_message_type) ->
        get_action_send_goal_response_type_definition(ros2_message_type, from)

      action_get_result_request_type?(ros2_message_type) ->
        get_action_get_result_request_type_definition(ros2_message_type, from)

      action_get_result_response_type?(ros2_message_type) ->
        get_action_get_result_response_type_definition(ros2_message_type, from)

      action_result_type?(ros2_message_type) ->
        get_action_get_result_type_definition(ros2_message_type, from)
    end
  end

  defp get_msg_definition(ros2_message_type, from) do
    cond do
      action_subtype?(ros2_message_type) ->
        get_action_msg_definition(ros2_message_type, from)

      service_response_message_type?(ros2_message_type) ->
        get_service_response_message_type_definition(ros2_message_type, from)

      service_request_message_type?(ros2_message_type) ->
        get_service_request_message_type_definition(ros2_message_type, from)

      true ->
        path = get_msg_path(ros2_message_type, from)
        path |> File.read!()
    end
  end

  def get_ros2_constant_type_map(ros2_message_type, from, acc \\ %{}) do
    {:ok, constants, _rest, _context, _line, _column} =
      get_msg_definition(ros2_message_type, from)
      |> ConstantParser.parse()

    constants = Enum.map(constants, fn [type, name, "=", value] -> [type, name, value] end)

    Map.put(acc, {:msg_type, ros2_message_type}, constants)
  end

  @doc false
  def get_ros2_message_type_map(ros2_message_type, from, acc \\ %{}) do
    {:ok, fields, _rest, _context, _line, _column} =
      get_msg_definition(ros2_message_type, from)
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
      [interfaces, interface_type, _] = String.split(ros2_message_type, "/")

      cond do
        interface_type == "srv" and
            (String.ends_with?(type, "_Request") or String.ends_with?(type, "_Response")) ->
          [interfaces, "srv", type]

        interface_type == "action" ->
          [interfaces, "action", type]

        true ->
          [interfaces, "msg", type]
      end
    end
    |> Path.join()
  end

  defp get_array_type(type) do
    String.replace(type, ~r/\[.*\]$/, "")
  end
end
