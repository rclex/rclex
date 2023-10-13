defmodule Rclex.Parsers.TypeParserTest do
  use ExUnit.Case

  alias Rclex.Parsers.TypeParser

  for {text, expected} <- [
        {"int32[]", ["int32", "[]"]},
        {"int32[5]", ["int32", "[", 5, "]"]},
        {"int32[<=5]", ["int32", "[<=", 5, "]"]},
        {"string", ["string"]},
        {"string<=10", ["string<=10"]},
        {"string[<=5]", ["string", "[<=", 5, "]"]},
        {"string<=10[]", ["string<=10", "[]"]},
        {"string<=10[<=5]", ["string<=10", "[<=", 5, "]"]}
      ] do
    test "#{text}" do
      text = unquote(text)
      expected = unquote(expected)

      {:ok, acc, _rest, _context, _line, _column} = TypeParser.parse("#{text}")
      assert acc == expected
    end
  end
end
