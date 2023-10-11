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
end
