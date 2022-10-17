import Config

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

config :mix_test_watch,
  extra_extensions: [".c", ".h"],
  exclude: [~r/\.#/, ~r{priv/repo/migrations}, ~r{tmp}]
