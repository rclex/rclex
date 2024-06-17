import Config

config :rclex,
  ros2_message_types: [
    "std_msgs/msg/Empty",
    "std_msgs/msg/String",
    "std_msgs/msg/UInt32MultiArray",
    "geometry_msgs/msg/Twist",
    "sensor_msgs/msg/PointCloud",
    "diagnostic_msgs/msg/DiagnosticStatus"
  ],
  ros2_directories: [],
  ros2_service_types: [
    "std_srvs/srv/SetBool",
    "rcl_interfaces/srv/GetParameterTypes"
    # "action_msgs/srv/CancelGoal"
  ]
