defmodule Mix.Tasks.Rclex.Gen.Msgs do
  @moduledoc false

  use Mix.Task

  alias Rclex.Parsers.MessageParser

  @ros2_elixir_type_map %{
    "bool" => "boolean()",
    "byte" => "0..255",
    "char" => "-128..127",
    "float32" => "float()",
    "float64" => "float()",
    "int8" => "-128..127",
    "uint8" => "0..255",
    "int16" => "integer()",
    "uint16" => "non_neg_integer()",
    "int32" => "integer()",
    "uint32" => "non_neg_integer()",
    "int64" => "integer()",
    "uint64" => "non_neg_integer()",
    "string" => "String.t()",
    "wstring" => "String.t()"
  }

  def run(_args) do
  end

  def generate_msg_ex(type, ros2_message_type_map) do
    EEx.eval_file(Path.join(templates_dir_path(), "msg_ex.eex"),
      module_name: module_name(type),
      defstruct_fields: defstruct_fields(type, ros2_message_type_map),
      type_fields: type_fields(type, ros2_message_type_map),
      function_id: function_id(type),
      to_tuple_args_fields: to_tuple_args_fields(type, ros2_message_type_map),
      to_struct_args_fields: to_struct_args_fields(type, ros2_message_type_map),
      to_tuple_return_fields: to_tuple_return_fields(type, ros2_message_type_map),
      to_struct_return_fields: to_struct_return_fields(type, ros2_message_type_map)
    )
  end

  def get_ros2_message_type_map(ros2_message_type, from, acc \\ %{}) do
    {:ok, fields, _rest, _context, _line, _column} =
      Path.join(from, [ros2_message_type, ".msg"])
      |> File.read!()
      |> MessageParser.parse()

    fields = to_abs_fields(fields, ros2_message_type)
    type_map = Map.put(acc, ros2_message_type, fields)

    Enum.reduce(fields, type_map, fn [head | _], acc ->
      case head do
        {:built_in_type, _type} ->
          acc

        {:built_in_type_array, _type} ->
          acc

        {:msg_type, type} ->
          get_ros2_message_type_map(type, from, acc)

        {:msg_type_array, type} ->
          get_ros2_message_type_map(get_array_type(type), from, acc)
      end
    end)
  end

  def defstruct_fields(ros2_message_type, ros2_message_type_map) do
    Map.get(ros2_message_type_map, ros2_message_type)
    |> Enum.map_join(", ", fn field ->
      case field do
        [{:built_in_type, _type}, name] ->
          "#{name}: nil"

        [{:built_in_type, _type}, name, default] ->
          "#{name}: #{inspect(default)}"

        [{:built_in_type_array, _type}, name] ->
          "#{name}: []"

        [{:built_in_type_array, _type}, name, default] ->
          "#{name}: #{inspect(default)}"

        [{:msg_type, type}, name] ->
          module_name = module_name(type)
          "#{name}: %Rclex.Pkgs.#{module_name}{}"

        [{:msg_type_array, _type}, name] ->
          "#{name}: []"
      end
    end)
  end

  def type_fields(ros2_message_type, ros2_message_type_map) do
    indent = String.duplicate(" ", 10)

    Map.get(ros2_message_type_map, ros2_message_type)
    |> Enum.map_join(",\n", fn field ->
      [type_tuple, name | _] = field

      case [type_tuple, name] do
        [{:built_in_type, type}, name] ->
          "#{name}: #{@ros2_elixir_type_map[type]}"

        [{:built_in_type_array, type}, name] ->
          "#{name}: list(#{@ros2_elixir_type_map[get_array_type(type)]})"

        [{:msg_type, type}, name] ->
          module_name = module_name(type)
          "#{name}: %Rclex.Pkgs.#{module_name}{}"

        [{:msg_type_array, type}, name] ->
          module_name = type |> get_array_type() |> module_name()
          "#{name}: list(%Rclex.Pkgs.#{module_name}{})"
      end
    end)
    |> String.split("\n")
    |> Enum.map_join("\n", &Kernel.<>(indent, &1))
  end

  def to_tuple_args_fields(ros2_message_type, ros2_message_type_map) do
    Map.get(ros2_message_type_map, ros2_message_type)
    |> Enum.map_join(", ", fn field ->
      [_type_tuple, name | _] = field
      "#{name}: #{name}"
    end)
  end

  def to_struct_args_fields(ros2_message_type, ros2_message_type_map) do
    Map.get(ros2_message_type_map, ros2_message_type)
    |> Enum.map_join(", ", fn field ->
      [_type_tuple, name | _] = field
      "#{name}"
    end)
  end

  def to_tuple_return_fields(ros2_message_type, ros2_message_type_map) do
    indent = String.duplicate(" ", 6)

    Map.get(ros2_message_type_map, ros2_message_type)
    |> Enum.map_join(",\n", fn field ->
      [type_tuple, name | _] = field

      case [type_tuple, name] do
        [{:built_in_type, "string" <> _}, name] ->
          ~s/~c"\#{#{name}}"/

        [{:built_in_type, _type}, name] ->
          "#{name}"

        [{:built_in_type_array, _type}, name] ->
          "#{name}"

        [{:msg_type, type}, name] ->
          module_name = module_name(type)
          "Rclex.Pkgs.#{module_name}.to_tuple(#{name})"

        [{:msg_type_array, type}, name] ->
          module_name = type |> get_array_type() |> module_name()

          """
          for struct <- #{name} do
            Rclex.Pkgs.#{module_name}.to_tuple(struct)
          end
          """
          |> String.replace_suffix("\n", "")
      end
    end)
    |> String.split("\n")
    |> Enum.map_join("\n", &Kernel.<>(indent, &1))
  end

  def to_struct_return_fields(ros2_message_type, ros2_message_type_map) do
    indent = String.duplicate(" ", 6)

    Map.get(ros2_message_type_map, ros2_message_type)
    |> Enum.map_join(",\n", fn field ->
      [type_tuple, name | _] = field

      case [type_tuple, name] do
        [{:built_in_type, "string" <> _}, name] ->
          ~s/#{name}: "\#{#{name}}"/

        [{:built_in_type, _type}, name] ->
          "#{name}: #{name}"

        [{:built_in_type_array, _type}, name] ->
          "#{name}: #{name}"

        [{:msg_type, type}, name] ->
          module_name = module_name(type)
          "#{name}: Rclex.Pkgs.#{module_name}.to_struct(#{name})"

        [{:msg_type_array, type}, name] ->
          module_name = type |> get_array_type() |> module_name()

          """
          #{name}:
            for tuple <- #{name} do
              Rclex.Pkgs.#{module_name}.to_tuple(tuple)
            end
          """
          |> String.replace_suffix("\n", "")
      end
    end)
    |> String.split("\n")
    |> Enum.map_join("\n", &Kernel.<>(indent, &1))
  end

  @doc """
  iex> Mix.Tasks.Rclex.Gen.Msgs.module_name("std_msgs/msg/String")
  "StdMsgs.Msg.String"
  """
  def module_name(ros2_message_type) do
    [pkg, msg = "msg", type] = String.split(ros2_message_type, "/")

    pkg =
      pkg
      |> String.replace("/", "_")
      |> String.split("_")
      |> Enum.map_join(&String.capitalize(&1))

    Enum.join([pkg, String.capitalize(msg), type], ".")
  end

  @doc """
  iex> Mix.Tasks.Rclex.Gen.Msgs.function_id("std_msgs/msg/String")
  "std_msgs_msg_string"

  iex> Mix.Tasks.Rclex.Gen.Msgs.function_id("std_msgs/msg/UInt32MultiArray")
  "std_msgs_msg_u_int32_multi_array"
  """
  def function_id(ros2_message_type) do
    [package, "msg" = msg, type] = ros2_message_type |> String.split("/")
    [package, msg, to_down_snake(type)] |> Enum.join("_")
  end

  @doc """
  iex> Mix.Tasks.Rclex.Gen.Msgs.to_down_snake("Vector3")
  "vector3"

  iex> Mix.Tasks.Rclex.Gen.Msgs.to_down_snake("TwistWithCovariance")
  "twist_with_covariance" 

  iex> Mix.Tasks.Rclex.Gen.Msgs.to_down_snake("UInt32MultiArray")
  "u_int32_multi_array" 
  """
  def to_down_snake(type_name) do
    String.split(type_name, ~r/[A-Z][a-z0-9]+/, include_captures: true, trim: true)
    |> Enum.map_join("_", &String.downcase(&1))
  end

  defp to_abs_fields(fields, ros2_message_type) do
    Enum.map(fields, fn field ->
      [head | tail] = field

      case head do
        {:msg_type, type} ->
          type = to_abs_type(type, ros2_message_type)
          [{:msg_type, type} | tail]

        {:msg_type_array, type} ->
          type = to_abs_type(type, ros2_message_type)
          [{:msg_type_array, type} | tail]

        _ ->
          field
      end
    end)
  end

  defp to_abs_type(type, ros2_message_type) do
    if String.contains?(type, "/") do
      [package, type] = String.split("/")
      [package, "msg", type]
    else
      [package, "msg", _] = String.split(ros2_message_type, "/")
      [package, "msg", type]
    end
    |> Path.join()
  end

  defp get_array_type(type) do
    String.replace(type, ~r/\[.*\]$/, "")
  end

  defp templates_dir_path() do
    Path.join(Application.app_dir(:rclex), "priv/templates/rclex.gen.msgs")
  end
end
