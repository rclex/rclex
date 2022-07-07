defmodule Rclex.MixProject do
  use Mix.Project

  @description """
  ROS 2 Client Library for Elixir.
  """

  @version "0.7.0"
  @source_url "https://github.com/rclex/rclex"

  def project do
    [
      app: :rclex,
      version: @version,
      elixir: "~> 1.9",
      description: @description,
      package: package(),
      name: "Rclex",
      docs: docs(),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      build_embedded: true,
      compilers: [:put_packages, :elixir_make] ++ Mix.compilers(),
      make_targets: ["all"],
      make_clean: ["clean"],
      make_error_message: """
      If the error message above says that rcl/rcl.h can't be found,
      then the fix is to setup the ROS 2 environment. If you have
      already installed ROS 2 environment, run the following command.
      `. /opt/ros/${ROS_DISTRO}/setup.bash`
      """,
      aliases: [format: [&format_c/1, "format"]],
      dialyzer: [plt_add_apps: [:mix]]
    ]
  end

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
      {:rclex_gen_msgs, "~> 0.1.0", runtime: false},
      {:git_hooks, "== 0.7.3", only: [:dev], runtime: false},
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
end
