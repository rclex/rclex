defmodule Rclex.QoS do
  @moduledoc false

  @type t() :: %__MODULE__{
          history: :system_default | :keep_last | :keep_all | :unknown,
          depth: non_neg_integer(),
          reliability: :system_default | :reliable | :best_effort | :unknown,
          durability: :system_default | :transient_local | :volatile | :unknown,
          deadline: float(),
          lifespan: float(),
          liveliness: :system_default | :automatic | :manual_by_topic | :unknown,
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

  defdelegate profile_sensor_data(), to: Rclex.Nif, as: :rmw_qos_profile_sensor_data!
  defdelegate profile_parameters(), to: Rclex.Nif, as: :rmw_qos_profile_parameters!
  defdelegate profile_default(), to: Rclex.Nif, as: :rmw_qos_profile_default!
  defdelegate profile_services_default(), to: Rclex.Nif, as: :rmw_qos_profile_services_default!
  defdelegate profile_parameter_events(), to: Rclex.Nif, as: :rmw_qos_profile_parameter_events!
  defdelegate profile_system_default(), to: Rclex.Nif, as: :rmw_qos_profile_system_default!
end
