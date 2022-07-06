import Config

config :rclex, :message_packages, [
  "std_msgs/msg/String",
  "geometry_msgs/msg/Twist"
]

import_config "#{config_env()}.exs"
