defmodule Rclex.Parsers.MessageParser do
  @moduledoc false

  import NimbleParsec
  import Rclex.Parsers.Helpers

  defparsec(:parse, parse_message() |> post_traverse({:wrap_up, []}))

  defp wrap_up(rest, args, context, _line, _offset) do
    args
    |> Enum.reject(&Kernel.==(&1, []))
    |> then(&{rest, &1, context})
  end
end
