defmodule Rclex.MixProject do
  use Mix.Project

  @description """
  ROS 2 Client Library for Elixir.
  """

  @app :rclex
  @version "0.11.0"
  @source_url "https://github.com/rclex/rclex"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      make_clean: ["clean"],
      compilers: [:elixir_make] ++ Mix.compilers(),
      aliases: [format: [&format_c/1, "format"], iwyu: [&iwyu/1]],
      test_coverage: test_coverage(),
      dialyzer: dialyzer(),
      # for hex
      description: @description,
      package: package(),
      # for ex_doc
      name: "Rclex",
      docs: docs()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications:
        [:logger] ++
          case Mix.target() do
            :host -> [:runtime_tools, :wx, :observer]
            _ -> []
          end,
      mod: {Rclex.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.7", runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:benchee, "~> 1.0", only: :dev},
      {:nimble_parsec, "~> 1.0"},
      {:mix_test_watch, "~> 1.0", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.27", only: :dev, runtime: false}
    ]
  end

  defp package() do
    %{
      name: "#{@app}",
      files: [
        "lib",
        "priv",
        "src",
        "mix.exs",
        "README.md",
        "README_ja.md",
        "LICENSE",
        "CHANGELOG.md",
        "Makefile"
      ],
      licenses: ["Apache-2.0"],
      links: %{"Github" => @source_url}
    }
  end

  defp docs() do
    [
      extras: ["README.md", "README_ja.md", "USE_ON_NERVES.md", "CHANGELOG.md"],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp format_c(_args) do
    file_names = File.ls!("src") |> Enum.filter(&String.ends_with?(&1, [".c", ".h"]))
    [formatter | args] = ~w"clang-format -i --Werror" ++ file_names

    case System.find_executable(formatter) do
      nil ->
        Mix.Shell.IO.info("Install C code formatter: #{formatter}.")

      bin ->
        System.cmd(bin, args, into: IO.stream(:stdio, :line), cd: "src")
    end
  end

  defp iwyu(_args) do
    script_path = Path.join(File.cwd!(), "scripts/iwyu.sh")

    case System.find_executable("include-what-you-use") do
      nil ->
        Mix.Shell.IO.info("Install include-what-you-use.")

      _ ->
        Enum.each(
          c_src_paths(),
          fn file_path ->
            case System.cmd(script_path, [file_path], stderr_to_stdout: true) do
              {_, 2} -> nil
              {return, _} -> Mix.Shell.IO.error("#{return}")
            end
          end
        )
    end
  end

  defp c_src_paths() do
    File.ls!("src")
    |> Enum.map(&Path.join("src", &1))
    |> Enum.filter(&String.ends_with?(&1, ".c"))
  end

  defp dialyzer() do
    [
      plt_local_path: "priv/plts/rclex.plt",
      plt_core_path: "priv/plts/core.plt",
      plt_add_apps: [:mix, :eex]
    ]
  end

  defp test_coverage() do
    [
      ignore_modules: [
        Rclex.Nif,
        Rclex.Generators.MsgC.Acc,
        ~r/Rclex\.Pkgs.+/,
        ~r/Mix\.Tasks\.Rclex.+/
      ]
    ]
  end
end
