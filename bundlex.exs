defmodule Rclex.BundlexProject do
  use Bundlex.Project

  def project do
    [
      nifs: nifs(Bundlex.platform())
    ]
  end

  defp nifs(_platform) do
    [
      rclex: [
        deps: [unifex: :unifex],
        src_base: "rclex",
        sources: ["_generated/rclex.c", "rclex.c"],
        lib_dirs: ["/opt/ros/dashing/lib"],
        libs: ["rcl","rmw","rcutils"] #<-みたいな?
      ]
    ]
  end
end
