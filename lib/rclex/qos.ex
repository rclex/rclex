defmodule Rclex.Qos do
  @type t() :: %__MODULE__{
          history: :system_default | :keep_last | :keep_all | :unknown,
          depth: non_neg_integer(),
          reliability: :system_default | :reliable | :best_effort | :unknown,
          durability: :system_default | :transient_local | :volatile | :unknown,
          deadline: float(),
          lifespan: float(),
          liveliness:
            :system_default
            | :automatic
            | :deprecated
            | :manual_by_topic
            | :unknown,
          liveliness_lease_duration: float(),
          avoid_ros_namespace_conventions: boolean()
        }

  defstruct [
    :history,
    :depth,
    :reliability,
    :durability,
    :deadline,
    :lifespan,
    :liveliness,
    :liveliness_lease_duration,
    avoid_ros_namespace_conventions: false
  ]

  # ref. /opt/ros/humble/rmw/rmw/types.h
  # #define RMW_QOS_DEADLINE_DEFAULT RMW_DURATION_UNSPECIFIED
  # #define RMW_QOS_LIFESPAN_DEFAULT RMW_DURATION_UNSPECIFIED
  # #define RMW_QOS_LIVELINESS_LEASE_DURATION_DEFAULT RMW_DURATION_UNSPECIFIED

  # ref. /opt/ros/humble/rmw/rmw/time.h
  # #define RMW_DURATION_INFINITE {9223372036LL, 854775807LL}
  # #define RMW_DURATION_UNSPECIFIED {0LL, 0LL}
  @duration_unspecified 0.0
  @deadline_default @duration_unspecified
  @lifespan_default @duration_unspecified
  @liveliness_lease_duration_default @duration_unspecified

  # ref. /opt/ros/humble/rmw/rmw/qos_profiles.h
  # enum {RMW_QOS_POLICY_DEPTH_SYSTEM_DEFAULT = 0};
  @depth_system_default 0

  # ref. /opt/ros/humble/rmw/rmw/qos_profiles.h
  def profile_sensor_data() do
    %__MODULE__{
      history: :keep_last,
      depth: 5,
      reliability: :best_effort,
      durability: :volatile,
      deadline: @deadline_default,
      lifespan: @lifespan_default,
      liveliness: :system_default,
      liveliness_lease_duration: @liveliness_lease_duration_default,
      avoid_ros_namespace_conventions: false
    }
  end

  def profile_parameters() do
    %__MODULE__{
      history: :keep_last,
      depth: 1000,
      reliability: :reliable,
      durability: :volatile,
      deadline: @deadline_default,
      lifespan: @lifespan_default,
      liveliness: :system_default,
      liveliness_lease_duration: @liveliness_lease_duration_default,
      avoid_ros_namespace_conventions: false
    }
  end

  def profile_default() do
    %__MODULE__{
      history: :keep_last,
      depth: 10,
      reliability: :reliable,
      durability: :volatile,
      deadline: @deadline_default,
      lifespan: @lifespan_default,
      liveliness: :system_default,
      liveliness_lease_duration: @liveliness_lease_duration_default,
      avoid_ros_namespace_conventions: false
    }
  end

  def profile_services_default() do
    %__MODULE__{
      history: :keep_last,
      depth: 10,
      reliability: :reliable,
      durability: :volatile,
      deadline: @deadline_default,
      lifespan: @lifespan_default,
      liveliness: :system_default,
      liveliness_lease_duration: @liveliness_lease_duration_default,
      avoid_ros_namespace_conventions: false
    }
  end

  def profile_parameters_events() do
    %__MODULE__{
      history: :keep_last,
      depth: 1000,
      reliability: :reliable,
      durability: :volatile,
      deadline: @deadline_default,
      lifespan: @lifespan_default,
      liveliness: :system_default,
      liveliness_lease_duration: @liveliness_lease_duration_default,
      avoid_ros_namespace_conventions: false
    }
  end

  def profile_system_default() do
    %__MODULE__{
      history: :system_default,
      depth: @depth_system_default,
      reliability: :system_default,
      durability: :system_default,
      deadline: @deadline_default,
      lifespan: @lifespan_default,
      liveliness: :system_default,
      liveliness_lease_duration: @liveliness_lease_duration_default,
      avoid_ros_namespace_conventions: false
    }
  end
end
