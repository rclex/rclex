defmodule Macro do
  defmacro rcl_ret_ok, do: 0
  defmacro rcl_ret_error, do: 1
  defmacro rcl_ret_timeout, do: 2
  defmacro rcl_ret_bad_alloc, do: 10
  defmacro rmw_ret_invalid_argument, do: 11
  defmacro rcl_ret_subscription_take_failed, do: 401
end