defmodule Rclex.Parsers.ConstantParser do
  @moduledoc false

  import NimbleParsec
  import Rclex.Parsers.Helpers

  defparsec(:parse, parse_constant() |> post_traverse({:wrap_up, []}))

  defp wrap_up(rest, args, context, _line, _offset) do
    args
    |> Enum.reject(&Kernel.==(&1, []))
    |> then(&{rest, &1, context})
  end
end
