defmodule Mix.Tasks.Rclex.Gen.Msgs do
  @moduledoc false

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

  def run(_) do
  end

  def generate_msg_mod() do
    type = "std_msgs/String"

    EEx.eval_file("lib/mix/tasks/rclex/gen/msg_mod.eex",
      module_name: get_rclex_module_name_from_type(type),
      fields: create_fields(type, "/opt/ros/foxy/share"),
      struct_type: create_struct_type(type, "/opt/ros/foxy/share")
    )
  end

  def generate_msg_nif_h() do
    type = "std_msgs/String"

    EEx.eval_file("lib/mix/tasks/rclex/gen/msg_nif_h.eex",
      function_name: get_function_name_from_type(type)
    )
  end

  def get_type_variable_tuples(ros2_message_type, from) when is_binary(ros2_message_type) do
    [package_name, type_name] = String.split(ros2_message_type, "/")
    relative_msg_file_path = relative_msg_file_path(package_name, type_name)

    Path.join(from, relative_msg_file_path)
    |> File.read!()
    |> String.split(["\n"], trim: true)
    |> remove_comment_from_rows()
    |> remove_constants_from_rows()
    |> Enum.map(fn row ->
      [type, variable] =
        row
        # remove comment in row
        |> String.replace(~r/#.*$/, "")
        |> String.split([" "], trim: true)
        # NOTE: currently we do not support default value
        |> Enum.take(2)

      cond do
        type in @ros2_built_in_types ->
          {type, variable}

        String.contains?(type, "/") ->
          {type, variable}

        true ->
          # NOTE: 同じパッケージ内の別のメッセージ型を利用している場合はパッケージ名を補う
          {Path.join(package_name, type), variable}
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
  iex> #{__MODULE__}.get_module_name_from_type("std_msgs/String")
  "StdMsgs.Msg.String"
  """
  def get_module_name_from_type(type) do
    if not String.contains?(type, "/") do
      raise RuntimeError, "type must contain ROS2 package name"
    end

    [package_name, type_name] = String.split(type, "/")
    get_module_name_impl([package_name, "msg", type_name])
  end

  @doc """
  iex> #{__MODULE__}.get_rclex_module_name_from_type("std_msgs/String")
  "Rclex.StdMsgs.Msg.String"
  """
  def get_rclex_module_name_from_type(type) do
    "Rclex.#{get_module_name_from_type(type)}"
  end

  @doc """
  iex> #{__MODULE__}.get_function_name_from_type("std_msgs/String")
  "std_msgs_msg_string"
  """
  def get_function_name_from_type(type) do
    [package_name, type_name] = String.split(type, "/")

    [package_name, "msg", type_name]
    |> Enum.map_join("_", &String.downcase(&1))
  end

  def create_fields(ros2_msg_type, from) do
    get_type_variable_tuples(ros2_msg_type, from)
    |> Enum.map_join(", ", fn
      {type, variable} when type in @ros2_built_in_types ->
        "#{variable}: nil"

      {type, variable} ->
        "#{variable}: %#{get_rclex_module_name_from_type(type)}{#{create_fields(type, from)}}"
    end)
  end

  def create_struct_type(ros2_msg_type, from) do
    module_name = get_rclex_module_name_from_type(ros2_msg_type)
    fields = create_struct_type_impl(ros2_msg_type, from)

    "%#{module_name}{#{fields}}"
  end

  def create_struct_type_impl(ros2_msg_type, from) do
    get_type_variable_tuples(ros2_msg_type, from)
    |> Enum.map_join(", ", fn
      {type, variable} when type in @ros2_built_in_types ->
        "#{variable}: #{@ros2_elixir_type_map[type]}"

      {type, variable} ->
        "#{variable}: %#{get_rclex_module_name_from_type(type)}{#{create_struct_type_impl(type, from)}}"
    end)
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
