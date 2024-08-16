defmodule Rclex.ActionClient do
  @moduledoc false

  use GenServer, restart: :temporary

  require Logger

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
    {:global, {:action_client, action_type, action_name, name, namespace}}
  end

  def send_goal_async(
        %request_type{} = goal,
        uuid,
        feedback_callback,
        action_name,
        name,
        namespace \\ "/"
      ) do
    action_type =
      String.to_existing_atom(String.trim_trailing(to_string(request_type), ".Goal"))

    if :erlang.fun_info(feedback_callback)[:arity] != 1 do
      raise("feedback_callback must expect feedback as parameters")
    end

    case GenServer.whereis(name(action_type, action_name, name, namespace)) do
      nil -> {:error, :not_found}
      {_atom, _node} -> raise("should not happen")
      pid -> GenServer.call(pid, {:send_goal_async, goal, uuid, feedback_callback})
    end
  end

  def cancel_goal_async(
        uuid,
        cancel_callback,
        action_type,
        action_name,
        name,
        namespace
      ) do
    if :erlang.fun_info(cancel_callback)[:arity] != 2 do
      raise("cancel_callback must expect return code and a list of goals canceling")
    end

    case GenServer.whereis(name(action_type, action_name, name, namespace)) do
      nil -> {:error, :not_found}
      {_atom, _node} -> raise("should not happen")
      pid -> GenServer.call(pid, {:cancel_goal_async, uuid, cancel_callback})
    end
  end

  def get_result_async(
        uuid,
        result_callback,
        action_type,
        action_name,
        name,
        namespace
      ) do
    if :erlang.fun_info(result_callback)[:arity] != 2 do
      raise("result_callback must expect status and result as parameters")
    end

    case GenServer.whereis(name(action_type, action_name, name, namespace)) do
      nil -> {:error, :not_found}
      {_atom, _node} -> raise("should not happen")
      pid -> GenServer.call(pid, {:get_result_async, uuid, result_callback})
    end
  end

  def action_server_available?(action_type, action_name, name, namespace \\ "/") do
    case GenServer.whereis(name(action_type, action_name, name, namespace)) do
      nil -> {:error, :not_found}
      {_atom, _node} -> raise("should not happen")
      pid -> GenServer.call(pid, {:action_server_available})
    end
  end

  # callbacks

  def init(args) do
    Process.flag(:trap_exit, true)

    context = Keyword.fetch!(args, :context)
    node = Keyword.fetch!(args, :node)
    action_type = Keyword.fetch!(args, :action_type)
    action_name = Keyword.fetch!(args, :action_name)
    name = Keyword.fetch!(args, :name)
    namespace = Keyword.fetch!(args, :namespace)

    options = Keyword.get(args, :options, Rclex.ActionClientOptions.default())
    goal_service_qos = options.goal_service_qos
    result_service_qos = options.result_service_qos
    cancel_service_qos = options.cancel_service_qos
    feedback_topic_qos = options.feedback_topic_qos
    status_topic_qos = options.status_topic_qos

    type_support = apply(action_type, :type_support!, [])

    action_client =
      Nif.rcl_action_client_init!(
        node,
        type_support,
        ~c"#{action_name}",
        {goal_service_qos, result_service_qos, cancel_service_qos, feedback_topic_qos,
         status_topic_qos}
      )

    {:ok,
     %{
       node: node,
       context: context,
       action_client: action_client,
       action_type: action_type,
       action_name: action_name,
       name: name,
       namespace: namespace,
       # request_type: apply(service_type, :request_type, []),
       # response_type: apply(service_type, :response_type, []),
       cancel_client_callback_resource: nil,
       feedback_subscription_callback_resource: nil,
       goal_client_callback_resource: nil,
       result_client_callback_resource: nil,
       status_subscription_callback_resource: nil,
       goal_requests: %{},
       result_requests: %{},
       cancel_requests: %{},
       goals: %{}
     }, {:continue, nil}}
  end

  def terminate(
        reason,
        %{
          node: node,
          action_client: ac,
          cancel_client_callback_resource: cancel_client_cr,
          feedback_subscription_callback_resource: feedback_subscription_cr,
          goal_client_callback_resource: goal_client_cr,
          result_client_callback_resource: result_client_cr,
          status_subscription_callback_resource: status_subscription_cr
        } = state
      ) do
    Nif.rcl_action_client_clear_cancel_client_callback!(ac, cancel_client_cr)
    Nif.rcl_action_client_clear_feedback_subscription_callback!(ac, feedback_subscription_cr)
    Nif.rcl_action_client_clear_goal_client_callback!(ac, goal_client_cr)
    Nif.rcl_action_client_clear_result_client_callback!(ac, result_client_cr)
    Nif.rcl_action_client_clear_status_subscription_callback!(ac, status_subscription_cr)
    Nif.rcl_action_client_fini!(ac, node)

    Logger.debug("#{__MODULE__}: #{inspect(reason)} #{Path.join(state.namespace, state.name)}")
  end

  def handle_continue(nil, %{action_client: action_client} = state) do
    cancel_client_callback_resource =
      Nif.rcl_action_client_set_cancel_client_callback!(action_client)

    feedback_subscription_callback_resource =
      Nif.rcl_action_client_set_feedback_subscription_callback!(action_client)

    goal_client_callback_resource = Nif.rcl_action_client_set_goal_client_callback!(action_client)

    result_client_callback_resource =
      Nif.rcl_action_client_set_result_client_callback!(action_client)

    status_subscription_callback_resource =
      Nif.rcl_action_client_set_status_subscription_callback!(action_client)

    {:noreply,
     %{
       state
       | cancel_client_callback_resource: cancel_client_callback_resource,
         feedback_subscription_callback_resource: feedback_subscription_callback_resource,
         goal_client_callback_resource: goal_client_callback_resource,
         result_client_callback_resource: result_client_callback_resource,
         status_subscription_callback_resource: status_subscription_callback_resource
     }}
  end

  def handle_call(
        {:send_goal_async, goal_struct, uuid, feedback_callback},
        _from,
        %{
          action_client: action_client,
          action_type: action_type,
          goal_requests: requests
        } = state
      ) do
    request_type = apply(action_type, :send_goal_request_type, [])
    request_struct = gen_goal_request_struct(request_type, goal_struct, uuid)
    request_message = apply(request_type, :create!, [])

    {:ok, sequence_number} =
      try do
        :ok = apply(request_type, :set!, [request_message, request_struct])
        Nif.rcl_action_send_goal_request!(action_client, request_message)
      after
        :ok = apply(request_type, :destroy!, [request_message])
      end

    Logger.debug(
      "#{__MODULE__}: [uuid: #{Base.encode16(uuid)}] send_goal_async(#{inspect(goal_struct)}) -> [seq: #{sequence_number}]"
    )

    requests =
      Map.put_new(requests, sequence_number, %{
        request_struct: request_struct,
        feedback_callback: feedback_callback
      })

    {:reply, {:ok, uuid}, Map.put(state, :goal_requests, requests)}
  end

  def handle_call(
        {:cancel_goal_async, uuid, cancel_callback},
        _from,
        %{
          action_client: action_client,
          cancel_requests: requests
        } = state
      ) do
    request_type = Rclex.Pkgs.ActionMsgs.Srv.CancelGoal.Request
    request_struct = gen_cancel_goal_request_struct(uuid)
    request_message = apply(request_type, :create!, [])

    {:ok, sequence_number} =
      try do
        :ok = apply(request_type, :set!, [request_message, request_struct])
        Nif.rcl_action_send_cancel_request!(action_client, request_message)
      after
        :ok = apply(request_type, :destroy!, [request_message])
      end

    Logger.debug(
      "#{__MODULE__}: [uuid: #{Base.encode16(uuid)}] cancel goal -> [seq: #{sequence_number}]"
    )

    requests =
      Map.put_new(requests, sequence_number, %{
        uuid: uuid,
        cancel_callback: cancel_callback
      })

    {:reply, :ok, Map.put(state, :cancel_requests, requests)}
  end

  def handle_call(
        {:get_result_async, uuid, result_callback},
        _from,
        %{
          action_client: action_client,
          action_type: action_type,
          result_requests: requests
        } = state
      ) do
    request_type = apply(action_type, :get_result_request_type, [])
    request_struct = gen_result_request_struct(request_type, uuid)
    request_message = apply(request_type, :create!, [])

    {:ok, sequence_number} =
      try do
        :ok = apply(request_type, :set!, [request_message, request_struct])
        Nif.rcl_action_send_result_request!(action_client, request_message)
      after
        :ok = apply(request_type, :destroy!, [request_message])
      end

    Logger.debug(
      "#{__MODULE__}: [uuid: #{Base.encode16(uuid)}] get_result_async -> [seq: #{sequence_number}]"
    )

    requests =
      Map.put_new(requests, sequence_number, %{
        uuid: uuid,
        result_callback: result_callback
      })

    {:reply, :ok, Map.put(state, :result_requests, requests)}
  end

  def handle_call(
        {:action_server_available},
        _from,
        %{
          node: node,
          action_client: action_client
        } = state
      ) do
    is_available = Nif.rcl_action_server_is_available!(node, action_client)
    {:reply, is_available, state}
  end

  def handle_info(
        {:new_goal_response, number_of_events},
        %{
          action_client: action_client,
          action_type: action_type,
          goal_requests: requests,
          goals: goals
        } = state
      )
      when number_of_events > 0 do
    response_type = apply(action_type, :send_goal_response_type, [])

    {requests, goals} =
      Enum.reduce(1..number_of_events, {requests, goals}, fn _i, {requests, goals} ->
        response_message = apply(response_type, :create!, [])

        try do
          {:ok, response_sequence_number} =
            Nif.rcl_action_take_goal_response!(action_client, response_message)

          response_struct = apply(response_type, :get!, [response_message])

          {%{request_struct: request_struct, feedback_callback: feedback_callback}, requests} =
            Map.pop(requests, response_sequence_number, %{
              request_struct: nil,
              feedback_callback: nil
            })

          uuid = request_struct.goal_id.uuid

          if request_struct do
            Logger.debug(
              "#{__MODULE__}: [seq: #{response_sequence_number}] -> [uuid: #{Base.encode16(request_struct.goal_id.uuid)}] goal #{if response_struct.accepted do
                "accepted"
              else
                "rejected"
              end} for #{inspect(request_struct.goal)}"
            )

            if response_struct.accepted do
              goals =
                Map.put(goals, uuid, %{
                  goal: request_struct.goal,
                  stamp: response_struct.stamp,
                  feedback_callback: feedback_callback
                })

              {requests, goals}
            else
              {requests, goals}
            end
          else
            {requests, goals}
          end
        after
          :ok = apply(response_type, :destroy!, [response_message])
        end
      end)

    {:noreply, %{state | goal_requests: requests, goals: goals}}
  end

  def handle_info(
        {:new_result_response, number_of_events},
        %{
          action_client: action_client,
          action_type: action_type,
          result_requests: requests
        } = state
      )
      when number_of_events > 0 do
    response_type = apply(action_type, :get_result_response_type, [])

    requests =
      Enum.reduce(1..number_of_events, requests, fn _i, requests ->
        response_message = apply(response_type, :create!, [])

        try do
          {:ok, response_sequence_number} =
            Nif.rcl_action_take_result_response!(action_client, response_message)

          response_struct = apply(response_type, :get!, [response_message])

          {%{uuid: uuid, result_callback: result_callback}, requests} =
            Map.pop(requests, response_sequence_number, %{
              uuid: nil,
              result_callback: nil
            })

          if uuid do
            Logger.debug(
              "#{__MODULE__}: [seq: #{response_sequence_number}] -> [uuid: #{Base.encode16(uuid)}] goal result (status: #{inspect(response_struct.status)}) #{inspect(response_struct.result)}"
            )

            {:ok, _pid} =
              Task.Supervisor.start_child(
                {:via, PartitionSupervisor, {Rclex.TaskSupervisors, self()}},
                fn -> result_callback.(response_struct.status, response_struct.result) end
              )
          end

          requests
        after
          :ok = apply(response_type, :destroy!, [response_message])
        end
      end)

    {:noreply, %{state | result_requests: requests}}
  end

  def handle_info(
        {:new_cancel_response, number_of_events},
        %{
          action_client: action_client,
          cancel_requests: requests
        } = state
      )
      when number_of_events > 0 do
    response_type = Rclex.Pkgs.ActionMsgs.Srv.CancelGoal.Response

    requests =
      Enum.reduce(1..number_of_events, requests, fn _i, requests ->
        response_message = apply(response_type, :create!, [])

        try do
          {:ok, response_sequence_number} =
            Nif.rcl_action_take_cancel_response!(action_client, response_message)

          response_struct = apply(response_type, :get!, [response_message])

          {%{uuid: uuid, cancel_callback: cancel_callback}, requests} =
            Map.pop(requests, response_sequence_number, %{
              uuid: nil,
              cancel_callback: nil
            })

          if uuid do
            Logger.debug(
              "#{__MODULE__}: [seq: #{response_sequence_number}] -> [uuid: #{Base.encode16(uuid)}] cancel goal result (return_code: #{inspect(response_struct.return_code)}) #{inspect(response_struct.goals_canceling)}"
            )

            {:ok, _pid} =
              Task.Supervisor.start_child(
                {:via, PartitionSupervisor, {Rclex.TaskSupervisors, self()}},
                fn ->
                  cancel_callback.(response_struct.return_code, response_struct.goals_canceling)
                end
              )
          end

          requests
        after
          :ok = apply(response_type, :destroy!, [response_message])
        end
      end)

    {:noreply, %{state | cancel_requests: requests}}
  end

  def handle_info(
        {:new_feedback, number_of_events},
        %{
          action_client: action_client,
          action_type: action_type,
          goals: goals
        } = state
      )
      when number_of_events > 0 do
    feedback_message_type = apply(action_type, :feedback_message_type, [])

    for _ <- 1..number_of_events do
      feedback_message = apply(feedback_message_type, :create!, [])

      try do
        :ok = Nif.rcl_action_take_feedback!(action_client, feedback_message)
        feedback_message_struct = apply(feedback_message_type, :get!, [feedback_message])
        uuid = feedback_message_struct.goal_id.uuid

        Logger.debug(
          "#{__MODULE__}: [uuid: #{Base.encode16(uuid)}] new feedback: #{inspect(feedback_message_struct.feedback)}"
        )

        goal = Map.get(goals, uuid)

        if goal do
          {:ok, _pid} =
            Task.Supervisor.start_child(
              {:via, PartitionSupervisor, {Rclex.TaskSupervisors, self()}},
              fn -> goal.feedback_callback.(feedback_message_struct.feedback) end
            )
        end
      rescue
        e -> Logger.error("#{inspect(e)}")
      after
        :ok = apply(feedback_message_type, :destroy!, [feedback_message])
      end
    end

    {:noreply, state}
  end

  def handle_info(
        {:new_status, number_of_events},
        %{
          action_client: action_client
        } = state
      )
      when number_of_events > 0 do
    status_type = Rclex.Pkgs.ActionMsgs.Msg.GoalStatusArray

    _status_list =
      for _ <- 1..number_of_events do
        status_message = apply(status_type, :create!, [])

        try do
          :ok = Nif.rcl_action_take_status!(action_client, status_message)
          status_struct = apply(status_type, :get!, [status_message])
          Logger.debug("#{__MODULE__}: status update: #{inspect(status_struct)}")
          status_struct
        rescue
          e -> Logger.error("#{inspect(e)}")
        after
          :ok = apply(status_type, :destroy!, [status_message])
        end
      end

    {:noreply, state}
  end
end
