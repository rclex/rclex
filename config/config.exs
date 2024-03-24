import Config

config :rclex,
  ros2_message_types: [
    "raspimouse_msgs/msg/Leds",
    "raspimouse_msgs/msg/LightSensors",
    "raspimouse_msgs/msg/Switches",
    "std_msgs/msg/String",
    "std_msgs/msg/UInt32MultiArray",
    "geometry_msgs/msg/Twist",
    "sensor_msgs/msg/PointCloud",
    "diagnostic_msgs/msg/DiagnosticStatus"
  ],
  ros2_directories: []
