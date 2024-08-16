# credo:disable-for-this-file
defmodule Rclex.ActionFuncs do
  defmacro __before_compile__(_env) do
    quote do
      # This file is necessary for `mix compile` which is invoked
      # before `mix rclex.gen.action`
    end
  end
end
