defmodule Rclex.ActionHelpers do
  @moduledoc false

  def get_uuid(goal_info) when is_struct(goal_info, Rclex.Pkgs.ActionMsgs.Msg.GoalInfo) do
    goal_info.goal_id.uuid
  end

  def uuid_pretty(goal_info) when is_struct(goal_info, Rclex.Pkgs.ActionMsgs.Msg.GoalInfo) do
    uuid_pretty(goal_info.goal_id.uuid)
  end

  def uuid_pretty(uuid) do
    "[uuid: #{Base.encode16(uuid)}]"
  end

  ### Struct generation helper functions

  def gen_result_request_struct(request_type, uuid) do
    request_struct = struct(request_type)
    %{request_struct | goal_id: gen_uuid_struct(uuid)}
  end

  def gen_result_response_struct(response_type, status, result)
      when is_atom(response_type) and is_integer(status) and is_map(result) do
    response_struct = struct(response_type)
    %{response_struct | :status => status, :result => result}
  end

  def gen_time_struct(time_ns) do
    time_struct = struct(Rclex.Pkgs.BuiltinInterfaces.Msg.Time)
    %{time_struct | sec: div(time_ns, 1_000_000_000), nanosec: rem(time_ns, 1_000_000_000)}
  end

  def gen_goal_request_struct(request_type, goal_struct, uuid) do
    request_struct = struct(request_type)
    %{request_struct | goal: goal_struct, goal_id: gen_uuid_struct(uuid)}
  end

  def gen_goal_response_struct(response_type, accepted, time) do
    time_struct = gen_time_struct(time)
    response_struct = struct(response_type)
    %{response_struct | accepted: accepted, stamp: time_struct}
  end

  def gen_goal_info_struct(goal_id) do
    goal_info_struct = struct(Rclex.Pkgs.ActionMsgs.Msg.GoalInfo)
    %{goal_info_struct | goal_id: goal_id}
  end

  def gen_goal_info_struct(goal_id, time_ns) do
    goal_info_struct = struct(Rclex.Pkgs.ActionMsgs.Msg.GoalInfo)
    %{goal_info_struct | goal_id: goal_id, stamp: gen_time_struct(time_ns)}
  end

  def goal_status(status)
      when status in [
             :status_unknown,
             :status_accepted,
             :status_executing,
             :status_canceling,
             :status_succeeded,
             :status_canceled,
             :status_aborted
           ] do
    apply(Rclex.Pkgs.ActionMsgs.Msg.GoalStatus, status, [])
  end

  def gen_goal_status_array_struct(goals) do
    goal_status_array = struct(Rclex.Pkgs.ActionMsgs.Msg.GoalStatusArray)

    status_list =
      for {_, goal} <- goals do
        goal.goal_status
      end

    %{goal_status_array | status_list: status_list}
  end

  def gen_feedback_message_struct(feedback_message_type, goal_id, feedback) do
    feedback_message_struct = struct(feedback_message_type)
    %{feedback_message_struct | goal_id: goal_id, feedback: feedback}
  end

  def gen_goal_status_struct(goal_info, status) do
    goal_status = struct(Rclex.Pkgs.ActionMsgs.Msg.GoalStatus)
    %{goal_status | goal_info: goal_info, status: status}
  end

  def gen_cancel_goal_request_struct(uuid) do
    request_struct = struct(Rclex.Pkgs.ActionMsgs.Srv.CancelGoal.Request)
    goal_id_struct = struct(Rclex.Pkgs.UniqueIdentifierMsgs.Msg.UUID)

    %{request_struct | goal_info: gen_goal_info_struct(%{goal_id_struct | uuid: uuid})}
  end

  def gen_uuid() do
    unix_time = DateTime.utc_now() |> DateTime.to_unix()
    <<_r0::32, r1::16, _r2::4, r3::12, _r4::2, r5::62>> = :crypto.strong_rand_bytes(16)
    <<unix_time::32, r1::16, 4::4, r3::12, 2::2, r5::62>>
  end

  def gen_time_struct() do
    time_struct = struct(Rclex.Pkgs.BuiltinInterfaces.Msg.Time)
    %{time_struct | sec: 0, nanosec: 0}
  end

  def gen_uuid_struct(uuid) do
    uuid_struct = struct(Rclex.Pkgs.UniqueIdentifierMsgs.Msg.UUID)
    %{uuid_struct | uuid: uuid}
  end
end
