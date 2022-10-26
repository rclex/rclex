defmodule Mix.Tasks.Rclex.Prep.Ros2 do
  use Mix.Task

  @arm64v8_ros2_distros ["foxy", "galactic", "humble"]
  @supported_arch ["arm64v8"]
  @supported_ros2_distros %{"arm64v8" => @arm64v8_ros2_distros}

  @shortdoc "Prepare ROS 2 resources under .ros2 directory."
  @moduledoc """
  #{@shortdoc}

      mix rclex.prep.ros2 --arch ARCH --ros2-distro DISTRO

  ROS 2 resources will be prepared under .ros2.

  An `--arch` option should be specified, option value is `arm64v8`, currently only supported.

  A `--ros2-distro` option should be specified, option values are #{Enum.join(@arm64v8_ros2_distros, "/")}.

  ## Examples

      mix rclex.prep.ros2 --arch arm64v8 --ros2-distro foxy
  """

  @switches [arch: :string, nerves_system: :string, ros2_distro: :string]

  def run(args) do
    if not command_exists?("docker") do
      Mix.raise("""
      Please install docker command first, we need it.
      """)
    end

    parsed_args = parse_args(args)

    arch = Keyword.get(parsed_args, :arch)

    if arch not in @supported_arch do
      Mix.raise("""
      Please select and specify the appropriate arch from the following.
      #{Enum.join(@supported_arch, ", ")}
      """)
    end

    supported_ros2_distros = Map.get(@supported_ros2_distros, arch, [])
    ros2_distro = Keyword.get(parsed_args, :ros2_distro)

    if ros2_distro not in supported_ros2_distros do
      Mix.raise("""
      Please select and specify the appropriate ros2 distro from the following.
      #{Enum.join(supported_ros2_distros, ", ")}
      """)
    end

    directory_path = create_resources_directory!(File.cwd!(), arch, ros2_distro)
    copy_ros2_resources!(directory_path, arch, ros2_distro)
  end

  def command_exists?(command) when is_binary(command) do
    {_, exit_status} = System.cmd("sh", ["-c", "command -v #{command}"])
    exit_status == 0
  end

  def copy_ros2_resources!(dest_path, arch, ros2_distro) do
    tag = ros2_docker_image_tag(arch, ros2_distro)

    [
      "/opt/ros/#{ros2_distro}/include",
      "/opt/ros/#{ros2_distro}/lib",
      "/opt/ros/#{ros2_distro}/share"
    ]
    |> Enum.map(&copy_ros2_impl!(tag, &1, dest_path))
  end

  def copy_ros2_impl!(docker_tag, src_path, dest_path) do
    with true <- File.exists?(src_path),
         true <- File.exists?(dest_path) do
      docker_command_args = ["run", "--rm", "-v", "#{dest_path}:/root", docker_tag]
      copy_command = ["cp", "-rf", src_path, "/root"]

      {_, 0} = System.cmd("docker", docker_command_args ++ copy_command)
    end
  end

  def ros2_docker_image_tag("arm64v8", ros2_distro) when ros2_distro in @arm64v8_ros2_distros do
    "arm64v8/ros:#{ros2_distro}-ros-core"
  end

  def parse_args(args) do
    {parsed_args, _remaining_args, _invalid} = OptionParser.parse(args, strict: @switches)

    parsed_args
  end

  @spec create_resources_directory!(
          base_path :: String.t(),
          arch :: String.t(),
          ros2_distro :: String.t()
        ) ::
          directory_path :: String.t()
  def create_resources_directory!(base_path, arch, ros2_distro) do
    directory_path = Path.join(base_path, ".ros2/resources/from-docker/#{arch}/#{ros2_distro}")
    File.mkdir_p!(directory_path)
    File.write!(Path.join(directory_path, ".gitignore"), "*")

    directory_path
  end
end
