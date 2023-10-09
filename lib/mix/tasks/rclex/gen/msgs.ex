defmodule Mix.Tasks.Rclex.Gen.Msgs do
  @moduledoc false

  use Mix.Task

  alias Rclex.Parsers.MessageParser

  def run(_args) do
  end

  def get_ros2_message_type_map(ros2_message_type, from, acc \\ %{}) do
    {:ok, result, _rest, _context, _line, _column} =
      Path.join(from, [ros2_message_type, ".msg"])
      |> File.read!()
      |> MessageParser.parse()

    type_map = Map.put(acc, ros2_message_type, result)

    Enum.reduce(result, type_map, fn field, acc ->
      case List.first(field) do
        {:built_in_type, _type} ->
          acc

        {:built_in_type_array, _type} ->
          acc

        {:msg_type, type} ->
          if Map.has_key?(type_map, type) do
            acc
          else
            # credo:disable-for-lines:7 Credo.Check.Refactor.Nesting
            type =
              if String.contains?(type, "/") do
                [package_name, type] = String.split(type, "/")
                "#{package_name}/msg/#{type}"
              else
                "#{Path.dirname(ros2_message_type)}/#{type}"
              end

            get_ros2_message_type_map(type, from, acc)
          end
      end
    end)
  end
end
