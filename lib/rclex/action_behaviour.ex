defmodule Rclex.ActionBehaviour do
  @moduledoc false

  @callback type_support!() :: reference()
  @callback feedback_type() :: atom()
  @callback goal_type() :: atom()
  @callback result_type() :: atom()
  @callback get_result_request_type() :: atom()
  @callback get_result_response_type() :: atom()
  @callback send_goal_request_type() :: atom()
  @callback send_goal_response_type() :: atom()
end
