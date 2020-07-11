defmodule Rclex.MixProject do
  use Mix.Project

  @description """
  ROS 2 Client Library for Elixir.
  """

  @version "0.3.1"
  @source_url "https://github.com/tlk-emb/rclex"

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
      compilers: [:elixir_make | Mix.compilers()],
      make_targets: ["all"],
      make_clean: ["clean"]
    ]
  end

  defp package do
    %{
      name: "rclex",
      maintainers: ["hiroiimanishi", "takasehideki"],
      files: [
        "lib",
        "src/*.[ch]",
        "mix.exs",
        "README.md",
        "README_ja.md",
        "LICENSE",
        "Makefile"
      ],
      licenses: ["Apache-2.0"],
      links: %{"Github" => "https://github.com/tlk-emb/rclex"}
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
      {:ex_doc, "~> 0.22", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      extras: ["README.md", "README_ja.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end
end
