import Config

config :rclex, ros2_message_types: ["std_msgs/msg/String", "geometry_msgs/msg/Twist"]

import_config "#{config_env()}.exs"
