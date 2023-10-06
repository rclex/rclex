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

  for {type, expected} <- [
        {"std_msgs/msg/String", [["string", "data"]]},
        {"geometry_msgs/msg/Vector3", [["float64", "x"], ["float64", "y"], ["float64", "z"]]},
        {"geometry_msgs/msg/Twist", [["Vector3", "linear"], ["Vector3", "angular"]]},
        {"unique_identifier_msgs/msg/UUID", [["uint8[16]", "uuid"]]},
        {"geometry_msgs/msg/Quaternion",
         [["float64", "x", 0], ["float64", "y", 0], ["float64", "z", 0], ["float64", "w", 1]]}
      ] do
    test "#{type}" do
      {:ok, acc, _rest, _context, _line, _column} =
        Path.join(@ros_share_path, [unquote(type), ".msg"])
        |> File.read!()
        |> MessageParser.parse()

      assert acc == unquote(expected)
    end
  end

  describe "field_line/1" do
    defparsecp(:field_line, Rclex.Parsers.Helpers.field_line())
    defparsecp(:constant_line, Rclex.Parsers.Helpers.constant_line())

    for {text, expected} <- [
          {"int32[] array", ["int32[]", "array"]},
          {"int32[5] array", ["int32[5]", "array"]},
          {"int32[<=5] array", ["int32[<=5]", "array"]},
          {"string string", ["string", "string"]},
          {"string<=10 bounded_string", ["string<=10", "bounded_string"]},
          {"string[<=5] string_array", ["string[<=5]", "string_array"]},
          {"string<=10[] bounded_string_array", ["string<=10[]", "bounded_string_array"]},
          {"string<=10[<=5] bounded_string_array", ["string<=10[<=5]", "bounded_string_array"]}
        ] do
      test "#{text}" do
        text = unquote(text)
        expected = unquote(expected)

        {:ok, acc, _rest, _context, _line, _column} = field_line("#{text}\n")
        assert acc == expected
      end
    end

    for {text, expected} <- [
          {"uint8 x 42", ["uint8", "x", 42]},
          {"int16 y -2000", ["int16", "y", -2000]},
          {"float32 a 0.2", ["float32", "a", 0.2]},
          {"float64 b -0.3", ["float64", "b", -0.3]},
          {"string full_name \"John Doe\"", ["string", "full_name", "John Doe"]},
          {"int32[] samples [-100]", ["int32[]", "samples", [-100]]},
          {"int32[] samples [-100, 0, 100]", ["int32[]", "samples", [-100, 0, 100]]},
          {"float32[] samples [-0.1, 0.0, 0.1]", ["float32[]", "samples", [-0.1, 0.0, 0.1]]},
          {"string[] samples [\"a\", \"b\", \"c\"]", ["string[]", "samples", ["a", "b", "c"]]}
        ] do
      test "#{text}" do
        text = unquote(text)
        expected = unquote(expected)

        {:ok, acc, _rest, _context, _line, _column} = field_line("#{text}\n")
        assert acc == expected
      end
    end

    for {text, expected} <- [
          {"int32 X=123", ["int32", "X", "=", 123]},
          {"int32 Y=-123", ["int32", "Y", "=", -123]},
          {"string FOO=\"foo\"", ["string", "FOO", "=", "foo"]},
          {"string EXAMPLE='bar'", ["string", "EXAMPLE", "=", "bar"]}
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
