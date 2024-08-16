defmodule Rclex.QoS do
  @moduledoc """
  Documentation for `#{__MODULE__}`.

  See also [Quality of Service settings](https://docs.ros.org/en/humble/Concepts/Intermediate/About-Quality-of-Service-Settings.html) on ROS 2 Documentation.
  """

  @typedoc """
  - `deadline`, `lifespan`, `liveliness_lease_duration` should be specified by float seconds.
  """
  @type t() :: %__MODULE__{
          history: :system_default | :keep_last | :keep_all,
          depth: non_neg_integer(),
          reliability: :system_default | :reliable | :best_effort,
          durability: :system_default | :transient_local | :volatile,
          deadline: float(),
          lifespan: float(),
          liveliness: :system_default | :automatic | :manual_by_topic,
          liveliness_lease_duration: float(),
          avoid_ros_namespace_conventions: boolean()
        }

  defstruct history: :keep_last,
            depth: 10,
            reliability: :reliable,
            durability: :volatile,
            deadline: 0.0,
            lifespan: 0.0,
            liveliness: :system_default,
            liveliness_lease_duration: 0.0,
            avoid_ros_namespace_conventions: false

  @doc "For sensor data, in most cases it’s more important to receive readings in a timely fashion, rather than ensuring that all of them arrive. That is, developers want the latest samples as soon as they are captured, at the expense of maybe losing some. For that reason the sensor data profile uses best effort reliability and a smaller queue size."
  @spec profile_sensor_data() :: t()
  defdelegate profile_sensor_data(), to: Rclex.Nif, as: :rmw_qos_profile_sensor_data!

  @doc "Parameters in ROS 2 are based on services, and as such have a similar profile. The difference is that parameters use a much larger queue depth so that requests do not get lost when, for example, the parameter client is unable to reach the parameter service server"
  @spec profile_parameters() :: t()
  defdelegate profile_parameters(), to: Rclex.Nif, as: :rmw_qos_profile_parameters!

  @doc "Default QoS settings for publishers and subscriptions"
  @spec profile_default() :: t()
  defdelegate profile_default(), to: Rclex.Nif, as: :rmw_qos_profile_default!

  @doc "In the same vein as publishers and subscriptions, services are reliable. It is especially important for services to use volatile durability, as otherwise service servers that re-start may receive outdated requests. While the client is protected from receiving multiple responses, the server is not protected from side-effects of receiving the outdated requests."
  @spec profile_services_default() :: t()
  defdelegate profile_services_default(), to: Rclex.Nif, as: :rmw_qos_profile_services_default!

  @doc false
  @spec profile_parameter_events() :: t()
  defdelegate profile_parameter_events(), to: Rclex.Nif, as: :rmw_qos_profile_parameter_events!

  @doc "This uses the RMW implementation’s default values for all of the policies. Different RMW implementations may have different defaults."
  @spec profile_system_default() :: t()
  defdelegate profile_system_default(), to: Rclex.Nif, as: :rmw_qos_profile_system_default!

  @doc "This uses rcl_action default values for status service calls - reliable with a history depth of 1."
  @spec profile_status_default() :: t()
  defdelegate profile_status_default(), to: Rclex.Nif, as: :rcl_action_qos_profile_status_default!
end
