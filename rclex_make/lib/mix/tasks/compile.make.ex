defmodule Mix.Tasks.Compile.PutPkglist do
  use Mix.Task

  def run(_) do
    packages =
      Application.fetch_env!(:rclex, :message_packages)
      |> Enum.join(" ")
    pkgtxt = File.read!("packages.txt")
    unless pkgtxt == packages do
      File.write!("packages.txt", packages)
    end
    :ok
  end
end
