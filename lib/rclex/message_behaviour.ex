defmodule Rclex.MessageBehaviour do
  @moduledoc false

  @callback type_support!() :: reference()
  @callback create!() :: reference()
  @callback destroy!(message :: reference()) :: :ok
  @callback set!(message :: reference(), data :: any()) :: :ok
  @callback get!(message :: reference()) :: data :: any()
end
