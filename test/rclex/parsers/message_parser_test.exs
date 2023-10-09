defmodule Rclex.Parsers.MessageParserTest do
  use ExUnit.Case

  import NimbleParsec

  with ros_distro <- System.get_env("ROS_DISTRO"),
       true <- File.exists?("/opt/ros/#{ros_distro}") do
    @ros_share_path "/opt/ros/#{ros_distro}/share"
  else
    _ ->
      @moduletag :skip
  end

  alias Rclex.Parsers.MessageParser

  for {msg, expected} <- [
        {"std_msgs/msg/String", [[{:built_in_type, "string"}, "data"]]},
        {"geometry_msgs/msg/Vector3",
         [
           [{:built_in_type, "float64"}, "x"],
           [{:built_in_type, "float64"}, "y"],
           [{:built_in_type, "float64"}, "z"]
         ]},
        {"geometry_msgs/msg/Twist",
         [[{:msg_type, "Vector3"}, "linear"], [{:msg_type, "Vector3"}, "angular"]]},
        {"unique_identifier_msgs/msg/UUID", [[{:built_in_type_array, "uint8[16]"}, "uuid"]]},
        {"geometry_msgs/msg/Quaternion",
         [
           [{:built_in_type, "float64"}, "x", 0],
           [{:built_in_type, "float64"}, "y", 0],
           [{:built_in_type, "float64"}, "z", 0],
           [{:built_in_type, "float64"}, "w", 1]
         ]}
      ] do
    test "#{msg}" do
      {:ok, acc, _rest, _context, _line, _column} =
        Path.join(@ros_share_path, [unquote(msg), ".msg"])
        |> File.read!()
        |> MessageParser.parse()

      assert acc == unquote(expected)
    end
  end

  describe "field_line/1" do
    defparsecp(:field_line, Rclex.Parsers.Helpers.field_line())
    defparsecp(:constant_line, Rclex.Parsers.Helpers.constant_line())

    for {text, expected} <- [
          {"int32[] array", [{:built_in_type_array, "int32[]"}, "array"]},
          {"int32[5] array", [{:built_in_type_array, "int32[5]"}, "array"]},
          {"int32[<=5] array", [{:built_in_type_array, "int32[<=5]"}, "array"]},
          {"string string", [{:built_in_type, "string"}, "string"]},
          {"string<=10 bounded_string", [{:built_in_type, "string<=10"}, "bounded_string"]},
          {"string[<=5] string_array", [{:built_in_type_array, "string[<=5]"}, "string_array"]},
          {"string<=10[] bounded_string_array",
           [{:built_in_type_array, "string<=10[]"}, "bounded_string_array"]},
          {"string<=10[<=5] bounded_string_array",
           [{:built_in_type_array, "string<=10[<=5]"}, "bounded_string_array"]}
        ] do
      test "#{text}" do
        text = unquote(text)
        expected = unquote(expected)

        {:ok, acc, _rest, _context, _line, _column} = field_line("#{text}\n")
        assert acc == expected
      end
    end

    for {text, expected} <- [
          {"uint8 x 42", [{:built_in_type, "uint8"}, "x", 42]},
          {"int16 y -2000", [{:built_in_type, "int16"}, "y", -2000]},
          {"float32 a 0.2", [{:built_in_type, "float32"}, "a", 0.2]},
          {"float64 b -0.3", [{:built_in_type, "float64"}, "b", -0.3]},
          {"string full_name \"John Doe\"",
           [{:built_in_type, "string"}, "full_name", "John Doe"]},
          {"int32[] samples [-100]", [{:built_in_type_array, "int32[]"}, "samples", [-100]]},
          {"int32[] samples [-100, 0, 100]",
           [{:built_in_type_array, "int32[]"}, "samples", [-100, 0, 100]]},
          {"float32[] samples [-0.1, 0.0, 0.1]",
           [{:built_in_type_array, "float32[]"}, "samples", [-0.1, 0.0, 0.1]]},
          {"string[] samples [\"a\", \"b\", \"c\"]",
           [{:built_in_type_array, "string[]"}, "samples", ["a", "b", "c"]]}
        ] do
      test "#{text}" do
        text = unquote(text)
        expected = unquote(expected)

        {:ok, acc, _rest, _context, _line, _column} = field_line("#{text}\n")
        assert acc == expected
      end
    end

    for {text, expected} <- [
          {"int32 X=123", [{:built_in_type, "int32"}, "X", "=", 123]},
          {"int32 Y=-123", [{:built_in_type, "int32"}, "Y", "=", -123]},
          {"string FOO=\"foo\"", [{:built_in_type, "string"}, "FOO", "=", "foo"]},
          {"string EXAMPLE='bar'", [{:built_in_type, "string"}, "EXAMPLE", "=", "bar"]}
        ] do
      test "#{text}" do
        text = unquote(text)
        expected = unquote(expected)

        {:ok, acc, _rest, _context, _line, _column} = constant_line("#{text}\n")
        assert acc == expected
      end
    end
  end
end
