defmodule Rclex.ReturnCode do
  @moduledoc """
  Defines rcl return code macros.

  To use, `require Rclex.ReturnCode` first.
  """
  defmacro rcl_ret_ok, do: 0
  defmacro rcl_ret_error, do: 1
  defmacro rcl_ret_timeout, do: 2
  defmacro rcl_ret_bad_alloc, do: 10
  defmacro rmw_ret_invalid_argument, do: 11
  defmacro rcl_ret_publisher_invalid, do: 300
  defmacro rcl_ret_subscription_invalid, do: 400
  defmacro rcl_ret_subscription_take_failed, do: 401
end
