defmodule Rclex.ActionServer do
  @moduledoc false

  use GenServer, restart: :temporary

  require Logger

  alias Rclex.Pkgs.ActionMsgs.Msg.GoalInfo
  alias Rclex.Nif

  import Rclex.ActionHelpers

  def start_link(args) do
    action_type = Keyword.fetch!(args, :action_type)
    action_name = Keyword.fetch!(args, :action_name)
    name = Keyword.fetch!(args, :name)
    ns = Keyword.fetch!(args, :namespace)

    GenServer.start_link(__MODULE__, args, name: name(action_type, action_name, name, ns))
  end

  def name(action_type, action_name, name, namespace \\ "/") do
    {:global, {:action_server, action_type, action_name, name, namespace}}
  end

  def execute_goal(goal_info, action_type, action_name, name, namespace) do
    case GenServer.whereis(name(action_type, action_name, name, namespace)) do
      nil -> {:error, :not_found}
      {_atom, _node} -> raise("should not happen")
      pid -> GenServer.call(pid, {:execute_goal, goal_info})
    end
  end

  def publish_feedback(goal_id, feedback, action_type, action_name, name, namespace \\ "/") do
    case GenServer.whereis(name(action_type, action_name, name, namespace)) do
      nil -> {:error, :not_found}
      {_atom, _node} -> raise("should not happen")
      pid -> GenServer.cast(pid, {:publish_feedback, goal_id, feedback})
    end
  end

  ### callbacks

  def init(args) do
    Process.flag(:trap_exit, true)

    context = Keyword.fetch!(args, :context)
    node = Keyword.fetch!(args, :node)
    action_type = Keyword.fetch!(args, :action_type)
    action_name = Keyword.fetch!(args, :action_name)
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)
    execute_callback = Keyword.fetch!(args, :execute_callback)
    goal_callback = Keyword.fetch!(args, :goal_callback)

    handle_accepted_callback =
      Keyword.get(args, :handle_accepted_callback, fn goal_info_struct,
                                                      action_type,
                                                      action_name,
                                                      name,
                                                      namespace ->
        Rclex.ActionServer.execute_goal(goal_info_struct, action_type, action_name, name,
          namespace: namespace
        )
      end)

    cancel_callback = Keyword.get(args, :cancel_callback, fn _req -> false end)

    options = Keyword.get(args, :options, Rclex.ActionServerOptions.default())
    goal_service_qos = options.goal_service_qos
    result_service_qos = options.result_service_qos
    cancel_service_qos = options.cancel_service_qos
    feedback_topic_qos = options.feedback_topic_qos
    status_topic_qos = options.status_topic_qos
    result_timeout = options.result_timeout
    clock = Nif.rcl_clock_init!(options.clock_type)

    2 = :erlang.fun_info(execute_callback)[:arity]
    1 = :erlang.fun_info(goal_callback)[:arity]
    5 = :erlang.fun_info(handle_accepted_callback)[:arity]
    1 = :erlang.fun_info(cancel_callback)[:arity]

    type_support = apply(action_type, :type_support!, [])

    action_server =
      Nif.rcl_action_server_init!(
        node,
        type_support,
        ~c"#{action_name}",
        clock,
        {goal_service_qos, result_service_qos, cancel_service_qos, feedback_topic_qos,
         status_topic_qos},
        result_timeout
      )

    {:ok,
     %{
       node: node,
       context: context,
       action_server: action_server,
       action_type: action_type,
       action_name: action_name,
       clock: clock,
       execute_callback: execute_callback,
       goal_callback: goal_callback,
       handle_accepted_callback: handle_accepted_callback,
       cancel_callback: cancel_callback,
       name: name,
       namespace: namespace,
       cancel_service_callback_resource: nil,
       goal_service_callback_resource: nil,
       result_service_callback_resource: nil,
       goals: %{}
     }, {:continue, nil}}
  end

  def terminate(
        reason,
        %{
          node: node,
          action_server: action_server,
          clock: clock,
          cancel_service_callback_resource: cancel_service_cr,
          goal_service_callback_resource: goal_service_cr,
          result_service_callback_resource: result_service_cr
        } = state
      ) do
    Nif.rcl_action_server_clear_cancel_service_callback!(action_server, cancel_service_cr)
    Nif.rcl_action_server_clear_goal_service_callback!(action_server, goal_service_cr)
    Nif.rcl_action_server_clear_result_service_callback!(action_server, result_service_cr)
    Nif.rcl_action_server_fini!(action_server, node)
    Nif.rcl_clock_fini!(clock)

    Logger.debug("#{__MODULE__}: #{inspect(reason)} #{Path.join(state.namespace, state.name)}")
  end

  def handle_continue(nil, %{action_server: action_server} = state) do
    goal_service_cr = Nif.rcl_action_server_set_goal_service_callback!(action_server)
    cancel_service_cr = Nif.rcl_action_server_set_cancel_service_callback!(action_server)
    result_service_cr = Nif.rcl_action_server_set_result_service_callback!(action_server)

    {:noreply,
     %{
       state
       | cancel_service_callback_resource: cancel_service_cr,
         goal_service_callback_resource: goal_service_cr,
         result_service_callback_resource: result_service_cr
     }}
  end

  def set_goals_result_and_reset_task(result, goal_info, action_server, action_type, goals) do
    uuid = get_uuid(goal_info)
    goal = Map.fetch!(goals, uuid)
    status = Nif.rcl_action_goal_handle_get_status!(goal.goal_handle)
    response_type = apply(action_type, :get_result_response_type, [])

    result_response =
      if result do
        gen_result_response_struct(
          response_type,
          status,
          result
        )
      else
        gen_result_response_struct(
          response_type,
          status,
          struct(apply(action_type, :result_type, []))
        )
      end

    {goal_with_waiting, goals} =
      goals
      |> Map.get_and_update!(uuid, fn goal ->
        {goal, %{goal | result_response: result_response, waiting_result_requests: [], task: nil}}
      end)

    {:ok, expired_goal_infos} = Nif.rcl_action_expire_goals!(action_server, 100)

    expired_uuids =
      expired_goal_infos
      |> Enum.map(fn goal_info_msg ->
        goal_info_struct = apply(Rclex.Pkgs.ActionMsgs.Msg.GoalInfo, :get!, [goal_info_msg])
        apply(Rclex.Pkgs.ActionMsgs.Msg.GoalInfo, :destroy!, [goal_info_msg])
        goal_info_struct.goal_id.uuid
      end)

    if length(expired_uuids) > 0 do
      Logger.debug(
        "#{__MODULE__}: expire goals #{inspect(Enum.map(expired_uuids, fn uuid -> uuid_pretty(uuid) end))}"
      )
    end

    goals = Map.drop(goals, expired_uuids)

    send_result_response(
      uuid,
      action_server,
      goal_with_waiting.waiting_result_requests,
      response_type,
      result_response
    )

    goals
  end

  def handle_cast({:publish_feedback, goal_id, feedback}, state) do
    publish_feedback(goal_id, feedback, state)
    {:noreply, state}
  end

  def handle_call({:execute_goal, goal_info}, _from, %{task: task} = state)
      when is_struct(task, Task) do
    Logger.error("#{__MODULE__}: #{uuid_pretty(goal_info)} Goal was already executed.")

    {:reply, :ok, state}
  end

  def handle_call(
        {:execute_goal, goal_info},
        _from,
        %{
          goals: goals,
          action_server: action_server,
          action_type: action_type,
          action_name: action_name,
          name: name,
          namespace: namespace,
          execute_callback: execute_callback
        } = state
      ) do
    uuid = get_uuid(goal_info)

    {ret, goals} =
      case Map.fetch(goals, uuid) do
        {:ok, goal} ->
          goals = update_goals_state(:goal_event_execute, goal_info, goals, action_server)

          publish_feedback = fn feedback ->
            Rclex.ActionServer.publish_feedback(
              goal_info.goal_id,
              feedback,
              action_type,
              action_name,
              name,
              namespace
            )
          end

          task =
            Task.Supervisor.async_nolink(
              {:via, PartitionSupervisor, {Rclex.TaskSupervisors, self()}},
              fn ->
                # return a result using handle_info({_task_ref, result}, ...)
                execute_callback.(goal.goal, publish_feedback)
              end
            )

          {:ok, Map.update!(goals, uuid, fn goal -> %{goal | task: task} end)}

        :error ->
          {:error, goals}
      end

    {:reply, ret, %{state | goals: goals}}
  end

  def cancel_goal(goals, goal_info, action_server, action_type) do
    {ret, goals} =
      case Map.fetch(goals, get_uuid(goal_info)) do
        {:ok, goal} ->
          goals = update_goals_state(:goal_event_cancel_goal, goal_info, goals, action_server)

          Logger.debug("#{__MODULE__}: Cancel goal #{uuid_pretty(goal_info)}.")

          ret = Task.shutdown(goal.task, 100)
          goals = update_goals_state(:goal_event_canceled, goal_info, goals, action_server)

          goals =
            set_goals_result_and_reset_task(nil, goal_info, action_server, action_type, goals)

          {ret, goals}

        :error ->
          Logger.error("#{__MODULE__}: #{uuid_pretty(goal_info)} Goal to cancel not found")

          {:not_found, goals}
      end

    {ret, goals}
  end

  def handle_info(
        {:new_goal_request, number_of_events},
        %{
          action_name: action_name,
          name: name,
          namespace: namespace,
          action_server: action_server,
          action_type: action_type,
          goal_callback: goal_callback,
          handle_accepted_callback: handle_accepted_callback,
          clock: clock,
          goals: goals
        } = state
      )
      when number_of_events > 0 do
    goal_list =
      for _ <- 1..number_of_events do
        request_type = apply(action_type, :send_goal_request_type, [])
        response_type = apply(action_type, :send_goal_response_type, [])
        request_message = apply(request_type, :create!, [])

        try do
          case Nif.rcl_action_take_goal_request!(action_server, request_message) do
            {:ok, request_header} ->
              request_message_struct = apply(request_type, :get!, [request_message])
              goal_id = Map.fetch!(request_message_struct, :goal_id)
              goal = Map.fetch!(request_message_struct, :goal)

              goal_info_struct = gen_goal_info_struct(goal_id)

              goal_info_msg = apply(GoalInfo, :create!, [])

              try do
                :ok = apply(GoalInfo, :set!, [goal_info_msg, goal_info_struct])

                if Nif.rcl_action_server_goal_exists!(action_server, goal_info_msg) do
                  raise "#{uuid_pretty(goal_id.uuid)} goal id exists"
                end
              after
                :ok = apply(GoalInfo, :destroy!, [goal_info_msg])
              end

              accepted = goal_callback.(goal) == :accept
              time = now(clock)

              goal_info_struct = gen_goal_info_struct(goal_id, time)

              goal_handle =
                if accepted do
                  accept_new_goal(action_server, goal_info_struct)
                end

              send_goal_response(action_server, request_header, response_type, accepted, time)

              if accepted do
                Logger.debug(
                  "#{__MODULE__}: #{uuid_pretty(goal_id.uuid)} Goal accepted: #{inspect(goal)}"
                )

                Task.Supervisor.start_child(
                  {:via, PartitionSupervisor, {Rclex.TaskSupervisors, self()}},
                  fn ->
                    handle_accepted_callback.(
                      goal_info_struct,
                      action_type,
                      action_name,
                      name,
                      namespace
                    )
                  end
                )

                {goal_id.uuid,
                 %{
                   goal: goal,
                   goal_info: goal_info_struct,
                   goal_handle: goal_handle,
                   result_response: nil,
                   goal_status:
                     gen_goal_status_struct(
                       goal_info_struct,
                       goal_status(:status_unknown)
                     ),
                   waiting_result_requests: [],
                   task: nil
                 }}
              else
                Logger.debug(
                  "#{__MODULE__}: #{uuid_pretty(goal_id.uuid)} Goal rejected: #{inspect(goal)}"
                )

                nil
              end

            :action_server_take_failed ->
              Logger.debug(
                "#{__MODULE__}: take goal request failed but no error occurred in the middleware"
              )

              nil
          end
        after
          :ok = apply(request_type, :destroy!, [request_message])
        end
      end

    goals =
      goal_list
      |> Enum.reject(&is_nil/1)
      |> Enum.into(goals)

    {:noreply, %{state | goals: goals}}
  end

  def handle_info(
        {:new_cancel_request, number_of_events},
        %{
          action_server: action_server,
          action_type: action_type,
          goals: goals,
          cancel_callback: cancel_callback
        } = state
      )
      when number_of_events > 0 do
    new_goals =
      Enum.reduce(1..number_of_events, goals, fn _i, goals ->
        request_type = Rclex.Pkgs.ActionMsgs.Srv.CancelGoal.Request
        response_type = Rclex.Pkgs.ActionMsgs.Srv.CancelGoal.Response

        request_message = apply(request_type, :create!, [])

        try do
          case Nif.rcl_action_take_cancel_request!(action_server, request_message) do
            {:ok, request_header} ->
              response_message = apply(response_type, :create!, [])

              try do
                :ok =
                  Nif.rcl_action_process_cancel_request!(
                    action_server,
                    request_message,
                    response_message
                  )

                response_message_struct = apply(response_type, :get!, [response_message])

                Logger.debug(
                  "#{__MODULE__}: cancel request processing result: #{inspect(Enum.map(response_message_struct.goals_canceling, fn goal_info -> Base.encode16(goal_info.goal_id.uuid) end))}"
                )

                goals =
                  Enum.reduce(response_message_struct.goals_canceling, goals, fn goal_info_struct,
                                                                                 goals ->
                    uuid = goal_info_struct.goal_id.uuid

                    case Map.fetch(goals, uuid) do
                      {:ok, %{goal_info: goal_info}} ->
                        accepted = cancel_callback.(goal_info) == :accept

                        if accepted do
                          Logger.debug("#{__MODULE__}: #{uuid_pretty(uuid)} cancel goal handler")

                          {_ret, goals} =
                            cancel_goal(goals, goal_info_struct, action_server, action_type)

                          goals
                        else
                          goals
                        end

                      :error ->
                        Logger.error(
                          "#{__MODULE__}: #{uuid_pretty(uuid)} goal to cancel not found"
                        )

                        goals
                    end
                  end)

                :ok =
                  Nif.rcl_action_send_cancel_response!(
                    action_server,
                    request_header,
                    response_message
                  )

                goals
              rescue
                e -> Logger.error("Error while taking cancel request: #{inspect(e)}")
              after
                :ok = apply(response_type, :destroy!, [response_message])
              end

            :action_server_take_failed ->
              Logger.debug(
                "#{__MODULE__}: take cancel request failed but no error occurred in the middleware"
              )

              goals
          end
        after
          :ok = apply(request_type, :destroy!, [request_message])
        end
      end)

    {:noreply, %{state | goals: new_goals}}
  end

  def handle_info(
        {:new_result_request, number_of_events},
        %{
          action_server: action_server,
          action_type: action_type,
          goals: goals
        } = state
      )
      when number_of_events > 0 do
    new_goals =
      Enum.reduce(1..number_of_events, goals, fn _i, goals ->
        request_type = apply(action_type, :send_goal_request_type, [])
        response_type = apply(action_type, :get_result_response_type, [])
        result_type = apply(action_type, :result_type, [])

        request_message = apply(request_type, :create!, [])

        try do
          case Nif.rcl_action_take_result_request!(action_server, request_message) do
            {:ok, request_header} ->
              request_message_struct = apply(request_type, :get!, [request_message])
              goal_id = Map.fetch!(request_message_struct, :goal_id)
              uuid = goal_id.uuid

              Logger.debug(
                "#{__MODULE__}: #{uuid_pretty(uuid)} Result request for goal received."
              )

              case Map.fetch(goals, uuid) do
                {:ok, goal} ->
                  if goal.result_response do
                    send_result_response(
                      uuid,
                      action_server,
                      request_header,
                      response_type,
                      goal.result_response
                    )

                    goals
                  else
                    Logger.debug(
                      "#{__MODULE__}: #{uuid_pretty(uuid)} [req: #{inspect(request_header)}] Waiting for result"
                    )

                    waiting_result_requests = [request_header | goal.waiting_result_requests]

                    Map.put(goals, uuid, %{
                      goal
                      | waiting_result_requests: waiting_result_requests
                    })
                  end

                :error ->
                  Logger.debug(
                    "#{__MODULE__}: #{uuid_pretty(goal_id.uuid)} Goal in result request is unknown."
                  )

                  response_message_struct =
                    gen_result_response_struct(
                      response_type,
                      goal_status(:status_unknown),
                      struct(result_type)
                    )

                  send_result_response(
                    uuid,
                    action_server,
                    request_header,
                    response_type,
                    response_message_struct
                  )

                  goals
              end

            :action_server_take_failed ->
              Logger.debug(
                "#{__MODULE__}: take result request failed but no error occurred in the middleware"
              )

              goals
          end
        after
          :ok = apply(request_type, :destroy!, [request_message])
        end
      end)

    {:noreply, %{state | goals: new_goals}}
  end

  # The goal execution completed successfully
  def handle_info(
        {task_ref, result},
        %{
          goals: goals,
          action_server: action_server,
          action_type: action_type
        } = state
      ) do
    # We don't care about the DOWN message now, so let's demonitor and flush it
    Process.demonitor(task_ref, [:flush])

    goal = find_goal_for_task_ref(goals, task_ref)
    goal_info = goal.goal_info

    # Hand over the result to the action server
    goals = update_goals_state(:goal_event_succeed, goal_info, goals, action_server)
    goals = set_goals_result_and_reset_task(result, goal_info, action_server, action_type, goals)

    Logger.debug(
      "#{__MODULE__}: Goal #{uuid_pretty(goal_info)} execution completed with #{inspect(result)}."
    )

    {:noreply, %{state | goals: goals}}
  end

  # The goal execution failed
  def handle_info(
        {:DOWN, task_ref, :process, _pid, reason},
        %{goals: goals, action_server: action_server, action_type: action_type} = state
      ) do
    goal = find_goal_for_task_ref(goals, task_ref)
    goal_info = goal.goal_info

    goals = update_goals_state(:goal_event_abort, goal_info, goals, action_server)

    goals = set_goals_result_and_reset_task(nil, goal_info, action_server, action_type, goals)

    Logger.error(
      "#{__MODULE__}: Goal #{uuid_pretty(goal_info)} execution failed because of #{inspect(reason)}."
    )

    {:noreply, %{state | goals: goals}}
  end

  defp send_result_response(
         uuid,
         action_server,
         request_headers,
         response_type,
         response_message_struct
       )
       when is_list(request_headers) do
    response_message = apply(response_type, :create!, [])

    try do
      :ok =
        apply(response_type, :set!, [
          response_message,
          response_message_struct
        ])

      for request_header <- request_headers do
        :ok =
          Nif.rcl_action_send_result_response!(
            action_server,
            request_header,
            response_message
          )

        Logger.debug(
          "#{__MODULE__}: #{uuid_pretty(uuid)} [req: #{inspect(request_header)}] Send result response"
        )
      end
    after
      :ok = apply(response_type, :destroy!, [response_message])
    end
  end

  defp send_result_response(
         uuid,
         action_server,
         request_header,
         response_type,
         response_message_struct
       ) do
    response_message = apply(response_type, :create!, [])

    try do
      :ok =
        apply(response_type, :set!, [
          response_message,
          response_message_struct
        ])

      :ok =
        Nif.rcl_action_send_result_response!(
          action_server,
          request_header,
          response_message
        )

      Logger.debug(
        "#{__MODULE__}: #{uuid_pretty(uuid)} [req: #{inspect(request_header)}] Send result response"
      )
    after
      :ok = apply(response_type, :destroy!, [response_message])
    end
  end

  defp update_goals_state(event, goal_info, goals, action_server)
       when is_atom(event) and
              event in [
                :goal_event_execute,
                :goal_event_cancel_goal,
                :goal_event_succeed,
                :goal_event_abort,
                :goal_event_canceled
              ] do
    uuid = get_uuid(goal_info)
    goal = Map.fetch!(goals, uuid)
    :ok = Nif.rcl_action_update_goal_state!(goal.goal_handle, event)
    status = Nif.rcl_action_goal_handle_get_status!(goal.goal_handle)
    goal_status_struct = gen_goal_status_struct(goal_info, status)

    new_goals =
      Map.update!(goals, uuid, fn goal ->
        %{goal | goal_status: goal_status_struct}
      end)

    publish_status(action_server, new_goals)
    new_goals
  end

  ### ROS messages

  defp publish_status(action_server, goals) do
    status_array_struct = gen_goal_status_array_struct(goals)
    message_type = Rclex.Pkgs.ActionMsgs.Msg.GoalStatusArray
    message = apply(message_type, :create!, [])

    try do
      :ok =
        apply(message_type, :set!, [
          message,
          status_array_struct
        ])

      :ok = Nif.rcl_action_publish_status!(action_server, message)
    after
      :ok = apply(message_type, :destroy!, [message])
    end
  end

  defp publish_feedback(
         goal_id,
         feedback,
         %{action_server: action_server, action_type: action_type} = _state
       ) do
    feedback_message_type = apply(action_type, :feedback_message_type, [])

    feedback_message_struct =
      gen_feedback_message_struct(feedback_message_type, goal_id, feedback)

    message = apply(feedback_message_type, :create!, [])

    try do
      :ok =
        apply(feedback_message_type, :set!, [
          message,
          feedback_message_struct
        ])

      :ok = Nif.rcl_action_publish_feedback!(action_server, message)
    after
      :ok = apply(feedback_message_type, :destroy!, [message])
    end
  end

  defp accept_new_goal(action_server, goal_info_struct) do
    goal_info_msg = apply(Rclex.Pkgs.ActionMsgs.Msg.GoalInfo, :create!, [])

    try do
      :ok = apply(Rclex.Pkgs.ActionMsgs.Msg.GoalInfo, :set!, [goal_info_msg, goal_info_struct])
      {:ok, goal_handle} = Nif.rcl_action_accept_new_goal!(action_server, goal_info_msg)
      goal_handle
    after
      :ok = apply(Rclex.Pkgs.ActionMsgs.Msg.GoalInfo, :destroy!, [goal_info_msg])
    end
  end

  defp send_goal_response(action_server, request_header, response_type, accepted, time) do
    response_message_struct =
      gen_goal_response_struct(response_type, accepted, time)

    response_message = apply(response_type, :create!, [])

    try do
      :ok =
        apply(response_type, :set!, [
          response_message,
          response_message_struct
        ])

      :ok =
        Nif.rcl_action_send_goal_response!(
          action_server,
          request_header,
          response_message
        )
    rescue
      # client is gone...we need to survive this
      e ->
        Logger.error("#{__MODULE__}: Client gone while goal request: #{inspect(e)}")
    after
      :ok = apply(response_type, :destroy!, [response_message])
    end
  end

  ### Helpers

  defp now(clock) do
    Nif.rcl_clock_get_now!(clock)
  end

  defp find_goal_for_task_ref(goals, task_ref) do
    goals
    |> Enum.find(fn {_uuid, goal} ->
      if is_nil(goal[:task]) do
        false
      else
        goal.task.ref == task_ref
      end
    end)
    |> elem(1)
  end
end
