defmodule Rclex.Parsers.Helpers do
  @moduledoc """
  The ROS 2 .msg specification URL is as follows,
  https://docs.ros.org/en/humble/Concepts/Basic/About-Interfaces.html
  """

  import NimbleParsec

  def parse_message(combinator \\ empty()) do
    combinator
    |> choice([
      field_line(),
      ignore(constant_line()),
      ignore(comment_line()),
      ignore(empty_line())
    ])
    |> wrap()
    |> times(min: 1)
  end

  def field_line(combinator \\ empty()) do
    combinator
    |> optional(whitespace())
    |> field_type()
    |> ignore(whitespace())
    |> field_name()
    |> ignore(optional(whitespace()))
    |> optional(field_default_value())
    |> ignore(optional(whitespace()))
    |> ignore(optional(comment()))
    |> ignore(new_line())
  end

  def constant_line(combinator \\ empty()) do
    combinator
    |> optional(whitespace())
    |> field_type()
    |> ignore(whitespace())
    |> ascii_string([?A..?Z, ?_, ?0..?9], min: 1)
    |> ignore(optional(whitespace()))
    |> string("=")
    |> ignore(optional(whitespace()))
    |> choice([value_float(), value_integer(), value_string()])
    |> ignore(optional(whitespace()))
    |> ignore(optional(comment()))
    |> ignore(new_line())
  end

  defp comment_line(combinator \\ empty()) do
    combinator
    |> optional(whitespace())
    |> comment()
    |> new_line()
  end

  defp empty_line(combinator \\ empty()) do
    combinator
    |> optional(whitespace())
    |> new_line()
  end

  defp field_type(combinator) do
    combinator
    |> choice([
      built_in_type_array() |> unwrap_and_tag(:built_in_type_array),
      msg_type_array() |> unwrap_and_tag(:msg_type_array),
      built_in_type() |> unwrap_and_tag(:built_in_type),
      msg_type() |> unwrap_and_tag(:msg_type)
    ])
  end

  defp field_name(combinator) do
    combinator |> ascii_string([?a..?z, ?0..?9, ?_], min: 1)
  end

  defp field_default_value(combinator \\ empty()) do
    combinator
    |> choice([
      value_float(),
      value_integer(),
      value_string(),
      value_array()
    ])
  end

  defp bounded_string(combinator \\ empty()) do
    combinator
    |> string("string<=")
    |> integer(min: 1)
    |> reduce({Enum, :join, []})
  end

  defp built_in_type(combinator \\ empty()) do
    combinator
    |> choice([
      bounded_string(),
      string("bool"),
      string("byte"),
      string("char"),
      string("float32"),
      string("float64"),
      string("int8"),
      string("uint8"),
      string("int16"),
      string("uint16"),
      string("int32"),
      string("uint32"),
      string("int64"),
      string("uint64"),
      string("string"),
      string("wstring")
    ])
  end

  defp msg_type(combinator \\ empty()) do
    combinator
    |> ascii_string([?a..?z, ?A..?Z, ?0..?9, ?_, ?/], min: 1)
  end

  defp built_in_type_array(combinator \\ empty()) do
    combinator
    |> built_in_type()
    |> choice([
      static_array(),
      unbounded_dynamic_array(),
      bounded_dynamic_array()
    ])
    |> reduce({Enum, :join, []})
  end

  defp msg_type_array(combinator \\ empty()) do
    combinator
    |> msg_type()
    |> choice([
      static_array(),
      unbounded_dynamic_array(),
      bounded_dynamic_array()
    ])
    |> reduce({Enum, :join, []})
  end

  defp static_array(combinator \\ empty()) do
    combinator
    |> string("[")
    |> ascii_string([?0..?9], min: 1)
    |> string("]")
  end

  defp unbounded_dynamic_array(combinator \\ empty()) do
    combinator
    |> string("[]")
  end

  defp bounded_dynamic_array(combinator \\ empty()) do
    combinator
    |> string("[<=")
    |> integer(min: 1)
    |> string("]")
  end

  defp value_integer(combinator \\ empty()) do
    combinator
    |> optional(ascii_string([?-, ?+], 1))
    |> ascii_string([?0..?9], min: 1)
    |> reduce({Enum, :join, []})
    |> map({String, :to_integer, []})
  end

  defp value_float(combinator \\ empty()) do
    combinator
    |> optional(ascii_string([?-, ?+], 1))
    |> ascii_string([?0..?9], min: 1)
    |> string(".")
    |> ascii_string([?0..?9], min: 1)
    |> reduce({Enum, :join, []})
    |> map({String, :to_float, []})
  end

  defp value_string(combinator \\ empty()) do
    combinator
    |> ignore(ascii_string([?", ?'], 1))
    |> ascii_string([?\s, ?!, ?#..?&, ?(..?~], min: 1)
    |> ignore(ascii_string([?", ?'], 1))
  end

  defp value_array(combinator \\ empty()) do
    combinator
    |> ignore(string("["))
    |> times(
      choice([value_float(), value_integer(), value_string()])
      |> ignore(optional(whitespace()))
      |> ignore(optional(string(",")))
      |> ignore(optional(whitespace())),
      min: 1
    )
    |> ignore(string("]"))
    |> wrap()
  end

  defp comment(combinator \\ empty()) do
    combinator
    |> string("#")
    |> optional(ascii_string([?\s..?~, ?\t], min: 1))
  end

  defp whitespace(combinator \\ empty()) do
    combinator |> ascii_string([?\s, ?\t], min: 1)
  end

  defp new_line(combinator \\ empty()) do
    combinator |> choice([string("\n"), string("\r\n")])
  end
end
