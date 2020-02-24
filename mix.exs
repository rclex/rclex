defmodule Rclex.MixProject do
  use Mix.Project

  @description """
   ROS 2 Client Library written in Elixir.
  """
  def project do
    [
      app: :rclex,
      version: "0.2.0",
      elixir: "~> 1.9",
      description: @description,
      package: package,
      name: "RclEx",
      source_url: "https://github.com/tlk-emb/rclex",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      build_embedded: true,
      compilers: [:elixir_make | Mix.compilers()],
      make_targets: ["all"],
      make_clean: ["clean"],
    ]
  end

  defp package do
    [
      name: "rclex",
      maintainers: ["hiroiimanishi", "takasehideki"],
      licenses: ["Apache-2.0"],
      links: %{"Github" => "https://github.com/tlk-emb/rclex"}
    ]
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
      #{:timex, "~>3.5"}
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end

end
