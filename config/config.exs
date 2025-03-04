import Config

config :rclex,
  ros2_message_types: [
    "std_msgs/msg/Empty",
    "std_msgs/msg/String",
    "std_msgs/msg/UInt8MultiArray",
    "std_msgs/msg/UInt32MultiArray",
    "geometry_msgs/msg/Twist",
    "sensor_msgs/msg/Image",
    "sensor_msgs/msg/PointCloud",
    "diagnostic_msgs/msg/DiagnosticStatus",
    "action_msgs/msg/GoalInfo"
  ]

if config_env() == :dev do
  config :git_hooks,
    # WHY: auto_install: false
    # Allow developers to choose whether or not to use git_hooks.
    # If want to use, run `mix git_hooks.install`.
    auto_install: false,
    verbose: true,
    # WHY: add -T option, to avoid "the input device is not a TTY" error
    mix_path: "docker compose run --rm -w /root/rclex -T rclex_docker mix",
    hooks: [
      pre_push: [
        tasks: [
          {:cmd, "mix test"},
          {:cmd, "mix format --check-formatted"},
          {:cmd, "mix credo"}
        ]
      ]
    ]
end
