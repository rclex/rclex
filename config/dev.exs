import Config

config :git_hooks,
  auto_install: true,
  verbose: true,
  # WHY: add -T option, to avoid "the input device is not a TTY" error
  mix_path: "docker compose run --rm -w /root/rclex -T rclex_docker mix",
  hooks: [
    pre_commit: [
      tasks: [
        {:cmd, "mix test"},
        {:cmd, "mix format --check-formatted"},
        {:cmd, "mix credo"}
      ]
    ]
  ]
