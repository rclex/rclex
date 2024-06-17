# credo:disable-for-this-file
defmodule Rclex.SrvFuncs do
  defmacro __before_compile__(_env) do
    quote do
      # This file is necessary for `mix compile` which is invoked
      # before `mix rclex.gen.srvs`
    end
  end
end
