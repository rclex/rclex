defmodule Mix.Tasks.Rclex.Gen.Msgs do
  @moduledoc false

  use Mix.Task

  alias Rclex.Parsers.MessageParser

  def run(_args) do
  end

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

  @doc """
  iex> Mix.Tasks.Rclex.Gen.Msgs.type_down_snake("std_msgs/msg/String")
  "std_msgs_msg_string"

  iex> Mix.Tasks.Rclex.Gen.Msgs.type_down_snake("std_msgs/msg/UInt32MultiArray")
  "std_msgs_msg_u_int32_multi_array"
  """
  def type_down_snake(ros2_message_type) do
    [interfaces, "msg" = msg, type] = ros2_message_type |> String.split("/")
    [interfaces, msg, to_down_snake(type)] |> Enum.join("_")
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
