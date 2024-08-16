defmodule Rclex.ActionClientOptions do
  @moduledoc """
  Documentation for `#{__MODULE__}`.

  See also [Action client options](https://docs.ros.org/en/rolling/p/rcl_action/generated/structrcl__action__client__options__s.html) on ROS 2 Documentation.

   - goal_service_qos: Middleware quality of service settings for the action client. Goal service quality of service
   - result_service_qos: Result service quality of service.
   - cancel_service_qos: Cancel service quality of service.
   - feedback_topic_qos: Feedback topic quality of service.
   - status_topic_qos: Status topic quality of service.
  """

  alias Rclex.QoS

  @typedoc """
  - Quality of service is defined by using rclex.QoS structs.
  - `deadline`, `lifespan`, `liveliness_lease_duration` should be specified by float seconds.
  """
  @type t() :: %__MODULE__{
          goal_service_qos: QoS.t(),
          result_service_qos: QoS.t(),
          cancel_service_qos: QoS.t(),
          feedback_topic_qos: QoS.t(),
          status_topic_qos: QoS.t()
        }

  defstruct [
    :goal_service_qos,
    :result_service_qos,
    :cancel_service_qos,
    :feedback_topic_qos,
    :status_topic_qos
  ]

  def default(),
    do: %__MODULE__{
      goal_service_qos: QoS.profile_services_default(),
      result_service_qos: QoS.profile_services_default(),
      cancel_service_qos: QoS.profile_services_default(),
      feedback_topic_qos: QoS.profile_default(),
      status_topic_qos: QoS.profile_status_default()
    }
end
