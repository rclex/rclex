defmodule Rclex.Parsers.TypeParser do
  @moduledoc false

  import NimbleParsec
  import Rclex.Parsers.Helpers

  defparsec(:parse, parse_type())
end
