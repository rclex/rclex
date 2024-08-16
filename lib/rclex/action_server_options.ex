defmodule Rclex.ActionServerOptions do
  @moduledoc """
  Documentation for `#{__MODULE__}`.

  See also [Action server options](https://docs.ros.org/en/rolling/p/rcl_action/generated/structrcl__action__server__options__s.html) on ROS 2 Documentation.

   - goal_service_qos: Middleware quality of service settings for the action client. Goal service quality of service
   - result_service_qos: Result service quality of service.
   - cancel_service_qos: Cancel service quality of service.
   - feedback_topic_qos: Feedback topic quality of service.
   - status_topic_qos: Status topic quality of service.
   - result_timeout: Goal handles that have results longer than this time are deallocated. It is defined in seconds as float value.
  """

  alias Rclex.QoS

  @typedoc """
  - Quality of service is defined by using rclex.QoS structs.
  - `result_timeout` should be specified by float seconds.
  """
  @type t() :: %__MODULE__{
          goal_service_qos: QoS.t(),
          result_service_qos: QoS.t(),
          cancel_service_qos: QoS.t(),
          feedback_topic_qos: QoS.t(),
          status_topic_qos: QoS.t(),
          result_timeout: float(),
          clock_type: :steady_time | :ros_time | :system_time
        }

  defstruct [
    :goal_service_qos,
    :result_service_qos,
    :cancel_service_qos,
    :feedback_topic_qos,
    :status_topic_qos,
    :result_timeout,
    :clock_type
  ]

  def default(),
    do: %__MODULE__{
      goal_service_qos: QoS.profile_services_default(),
      result_service_qos: QoS.profile_services_default(),
      cancel_service_qos: QoS.profile_services_default(),
      feedback_topic_qos: QoS.profile_default(),
      status_topic_qos: QoS.profile_status_default(),
      result_timeout: 10.0,
      clock_type: :steady_time
    }
end
