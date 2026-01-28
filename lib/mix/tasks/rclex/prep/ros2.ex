defmodule Mix.Tasks.Rclex.Prep.Ros2 do
  @shortdoc "Prepare ROS 2 resources under .ros2 directory."
  @moduledoc """
  #{@shortdoc}

  ```
  mix rclex.prep.ros2 --arch ARCH
  ```

  ROS 2 resources will be prepared under .ros2.

  An `--arch` option should be specified, option value is `arm64v8`, currently only supported.

  ## Examples

  specify arch explicitly with `--arch` option

  ```
  mix rclex.prep.ros2 --arch arm64v8
  ```

  For Nerves, `export MIX_TARGET=[TARGET]` is invoked properly, `--arch` option is not needed.

  ```
  mix rclex.prep.ros2
  ```
  """

  use Mix.Task

  @arm64v8_ros_distros ["humble", "jazzy"]
  @amd64_ros_distros ["humble", "jazzy"]
  @arm32v7_ros_distros ["humble"]
  @supported_ros_distros %{
    "arm64v8" => @arm64v8_ros_distros,
    "amd64" => @amd64_ros_distros,
    "arm32v7" => @arm32v7_ros_distros
  }
  @supported_arch Map.keys(@supported_ros_distros)

  @nerves_target_arch_map %{"rpi4" => "arm64v8", "rpi3" => "arm32v7"}

  @switches [arch: :string]

  @doc false
  def run(args) do
    if is_nil(System.find_executable("docker")) do
      Mix.raise("""
      Please install docker command first, we need it.
      """)
    end

    parsed_args = parse_args(args)

    arch =
      Keyword.get(
        parsed_args,
        :arch,
        Map.get(@nerves_target_arch_map, System.get_env("MIX_TARGET"))
      )

    if arch not in @supported_arch do
      Mix.raise("""
      Please select and specify the appropriate --arch from the following.
      #{Enum.join(@supported_arch, ", ")}
      """)
    end

    ros_distro = System.get_env("ROS_DISTRO")
    supported_ros_distros = Map.get(@supported_ros_distros, arch, [])

    if ros_distro not in supported_ros_distros do
      Mix.raise("""
      Please set the appropriate ROS_DISTRO from the following.
      #{Enum.join(supported_ros_distros, ", ")}
      """)
    end

    # NOTE: If you implement the copy destination option, pass the path here.
    dest_dir_path = copy_dest_dir_path(arch, ros_distro)

    message = """
    Are you sure to copy ROS 2 resources to following directory?
    path: #{dest_dir_path}
    """

    if Mix.shell().yes?(String.trim_trailing(message)) do
      copy_from_docker!(dest_dir_path, arch, ros_distro)
    end
  end

  @doc false
  def parse_args(args) do
    {parsed_args, _remaining_args, _invalid} = OptionParser.parse(args, strict: @switches)

    parsed_args
  end

  @doc false
  def copy_from_docker!(dest_dir_path, arch, ros_distro) do
    dest_path = Path.join(dest_dir_path, "/opt/ros/#{ros_distro}")
    create_resources_directory!(dest_path, _git_ignore = true)
    copy_ros_resources_from_docker!(dest_path, arch, ros_distro)

    dest_path = Path.join(dest_dir_path, "/opt/ros/#{ros_distro}/lib")
    create_resources_directory!(dest_path, _git_ignore = false)
    copy_vendor_resources_from_docker!(dest_path, arch, ros_distro)
  end

  defp copy_ros_resources_from_docker!(dest_path, arch, ros_distro)
       when arch in ["arm64v8", "amd64"] do
    [
      "/opt/ros/#{ros_distro}/include",
      "/opt/ros/#{ros_distro}/lib",
      "/opt/ros/#{ros_distro}/share"
    ]
    |> Enum.map(fn src_path -> copy_from_docker_impl!(arch, ros_distro, src_path, dest_path) end)
  end

  defp copy_ros_resources_from_docker!(dest_path, arch, ros_distro)
       when arch in ["arm32v7"] do
    [
      "/root/ros2_ws/install/*/include",
      "/root/ros2_ws/install/*/lib",
      "/root/ros2_ws/install/*/share"
    ]
    |> Enum.map(fn src_path -> copy_from_docker_impl!(arch, ros_distro, src_path, dest_path) end)
  end

  defp copy_vendor_resources_from_docker!(dest_path, arch, ros_distro)
       when arch in ["arm64v8", "amd64", "arm32v7"] do
    vendor_resources(arch, ros_distro)
    |> Enum.map(fn src_path -> copy_from_docker_impl!(arch, ros_distro, src_path, dest_path) end)
  end

  defp vendor_resources(arch, "humble") do
    dir_name = arch_dir_name(arch)

    [
      "/lib/#{dir_name}/libspdlog.so*",
      "/lib/#{dir_name}/libtinyxml2.so*",
      "/lib/#{dir_name}/libfmt.so*",
      # humble needs OpenSSL 3.x which Nerves doesn't have
      "/lib/#{dir_name}/libssl.so*",
      "/lib/#{dir_name}/libcrypto.so*"
    ]
  end

  defp copy_from_docker_impl!(arch, ros_distro, src_path, dest_path) do
    with true <- File.exists?(dest_path) do
      docker_tag = ros_docker_image_tag(arch, ros_distro)

      docker_command_args = [
        "run",
        "--rm",
        "--platform",
        "#{platform(arch)}",
        "-v",
        "#{dest_path}:/mnt",
        docker_tag
      ]

      copy_command = ["bash", "-c", "for s in #{src_path}; do cp -rf $s /mnt; done"]

      {_, 0} = System.cmd("docker", docker_command_args ++ copy_command)
    end
  end

  @doc false
  def ros_docker_image_tag(arch, ros_distro)

  # refs. https://hub.docker.com/r/arm64v8/ros
  def ros_docker_image_tag("arm64v8", ros_distro) when ros_distro in @arm64v8_ros_distros do
    "arm64v8/ros:#{ros_distro}-ros-core"
  end

  # refs. https://hub.docker.com/r/amd64/ros
  def ros_docker_image_tag("amd64", ros_distro) when ros_distro in @amd64_ros_distros do
    "amd64/ros:#{ros_distro}-ros-core"
  end

  def ros_docker_image_tag("arm32v7", ros_distro) when ros_distro in @arm32v7_ros_distros do
    "rclex/arm32v7_ros_docker_with_vendor_resources:#{ros_distro}"
  end

  defp arch_dir_name("amd64"), do: "x86_64-linux-gnu"
  defp arch_dir_name("arm64v8"), do: "aarch64-linux-gnu"
  defp arch_dir_name("arm32v7"), do: "arm-linux-gnueabihf"

  defp platform("amd64"), do: "linux/amd64"
  defp platform("arm64v8"), do: "linux/arm64/v8"
  defp platform("arm32v7"), do: "linux/arm/v7"

  @doc false
  @spec create_resources_directory!(directory_path :: String.t(), gitignore :: boolean()) :: :ok
  def create_resources_directory!(directory_path, git_ignore) do
    File.mkdir_p!(directory_path)

    if git_ignore do
      gitignore_content = """
      # generated by `mix rclex.prep.ros2`
      *
      !.gitignore
      """

      File.write!(Path.join(directory_path, ".gitignore"), gitignore_content)
    end
  end

  defp copy_dest_dir_path(path \\ File.cwd!(), arch, ros_distro) do
    if Mix.target() == :host do
      Path.join(path, ".ros2/resources/from-docker/#{arch}/#{ros_distro}")
    else
      Path.join(path, "rootfs_overlay")
    end
  end
end
