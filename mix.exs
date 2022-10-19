defmodule Rclex.MixProject do
  use Mix.Project

  @description """
  ROS 2 Client Library for Elixir.
  """

  @version "0.7.2"
  @source_url "https://github.com/rclex/rclex"

  def project do
    [
      app: :rclex,
      version: @version,
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      description: @description,
      package: package(),
      name: "Rclex",
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      build_embedded: true,
      compilers: [:elixir_make] ++ Mix.compilers(),
      make_targets: ["all"],
      make_clean: ["clean"],
      make_error_message: """
      If the error message above says that rcl/rcl.h can't be found,
      then the fix is to setup the ROS 2 environment. If you have
      already installed ROS 2 environment, run the following command.
      `. /opt/ros/${ROS_DISTRO}/setup.bash`
      """,
      aliases: [format: [&format_c/1, "format"]],
      dialyzer: dialyzer()
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    %{
      name: "rclex",
      files: [
        "lib",
        "src",
        "mix.exs",
        "README.md",
        "README_ja.md",
        "LICENSE",
        "CHANGELOG.md",
        "Makefile",
        "packages.txt"
      ],
      licenses: ["Apache-2.0"],
      links: %{"Github" => @source_url}
    }
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.4", runtime: false},
      {:credo, "~> 1.5", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.0", only: [:dev], runtime: false},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      # lock git_hooks version to avoid https://github.com/qgadrian/elixir_git_hooks/issues/123
      {:git_hooks, "== 0.6.5", only: [:dev], runtime: false},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test]}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "README_ja.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp format_c([]) do
    case System.find_executable("astyle") do
      nil ->
        Mix.Shell.IO.info("Install astyle to format C code.")

      astyle ->
        System.cmd(astyle, ["-n", "--style=1tbs", "-s2", "src/*.c"],
          into: IO.stream(:stdio, :line)
        )
    end
  end

  defp format_c(_args), do: true

  defp dialyzer do
    [
      plt_add_apps: [:eex, :mix],
      plt_core_path: "priv/plts",
      plt_file: {:no_warn, "priv/plts/dialyzer.plt"}
    ]
  end
end
