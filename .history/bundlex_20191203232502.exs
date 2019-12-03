defmodule Unifex.BundlexProject do
  use Bundlex.Project

  def project do
    [
      libs: libs()
    ]
  end

  defp libs do
    [
      unifex: [
        deps: [shmex: :lib_nif],
        sources: ["unifex.c", "payload.c"]
      ]
    ]
  end
end
