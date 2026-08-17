defmodule Rclex.MixProject do
  use Mix.Project

  @description """
  ROS 2 Client Library for Elixir.
  """

  @app :rclex
  @version "0.13.2"
  @source_url "https://github.com/rclex/rclex"

  def project do
    [
      app: @app,
      version: @version,
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      make_clean: ["clean"],
      compilers: compilers(),
      aliases: [
        compile: [&copy_templates/1, "compile"],
        format: [&format_c/1, "format"],
        iwyu: [&iwyu/1]
      ],
      test_ignore_filters: [&String.starts_with?(&1, "test/expected_files/")],
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

  defp compilers do
    ros_distro = System.get_env("ROS_DISTRO")
    argv = System.argv()
    # Skip NIF build (:elixir_make):
    #   - when ROS_DISTRO is not set
    #   - when running rclex Mix tasks that prepare ROS 2 resources or message packages
    cond do
      is_nil(ros_distro) -> []
      "rclex.prep.ros2" in argv -> []
      "rclex.gen.msgs" in argv -> []
      true -> [:elixir_make]
    end ++ Mix.compilers()
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:elixir_make, "~> 0.7", runtime: false},
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.3", only: [:dev], runtime: false},
      {:benchee, "~> 1.0", only: :dev},
      {:nimble_parsec, "~> 1.0"},
      {:git_hooks, "~> 0.9.0", only: [:dev], runtime: false},
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
      extras: [
        "README.md",
        "README_ja.md",
        "USE_ON_NERVES.md",
        "USE_ON_NO_ROS2_LINUX.md",
        "CHANGELOG.md"
      ],
      main: "readme",
      source_ref: "v#{@version}",
      source_url: @source_url
    ]
  end

  defp copy_templates(_args) do
    project_dir =
      Mix.Project.project_file()
      |> Path.dirname()

    ["lib/rclex/msg_funcs.ex", "src/msg_funcs.h", "src/msg_funcs.ec"]
    |> Enum.each(fn path ->
      source_file_path = Path.join(project_dir, "priv/templates/rclex.gen.msgs/#{path}")
      destination_file_path = Path.join(project_dir, path)

      if not File.exists?(destination_file_path) do
        File.cp!(source_file_path, destination_file_path)
      end
    end)
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
      summary: [
        # Remove when https://github.com/rclex/rclex/issues/349 is resolved.
        threshold: 80
      ],
      ignore_modules: [
        Rclex.Nif,
        Rclex.Generators.MsgC.Acc,
        ~r/Rclex\.Pkgs.+/,
        ~r/Mix\.Tasks\.Rclex.+/
      ]
    ]
  end
end
