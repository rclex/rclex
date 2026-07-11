defmodule Mix.Tasks.Rclex.Prep.Ros2 do
  @shortdoc "Prepare ROS 2 resources for Nerves and hosts without a local ROS 2 installation."
  @moduledoc """
  #{@shortdoc}

  `mix rclex.prep.ros2` prepares the ROS 2 resources that Nerves targets and
  Linux hosts need when they run Rclex without a local ROS 2 installation.

  The task copies the required ROS 2 files from a Docker image into the target
  directory for the runtime environment. Before copying, it shows a confirmation
  prompt and proceeds only when you answer yes.

  ## Prerequisites

  - Docker must be available.
  - `ROS_DISTRO` must be set.
  - An `--arch` value must be provided, or it must be inferred from `MIX_TARGET`.
  - Supported architectures are `arm64v8`, `amd64`, and `arm32v7`.

  For Nerves, `MIX_TARGET=rpi4` is inferred as `arm64v8`, and `MIX_TARGET=rpi3`
  is inferred as `arm32v7`. For any other Nerves target, specify `--arch`
  explicitly.

  ## Basic Usage

  ### Nerves

  The following example uses `rpi4` and `jazzy`.

  Prepare ROS 2 resources.

  ```
  export MIX_TARGET=rpi4
  export ROS_DISTRO=jazzy
  mix rclex.prep.ros2 --arch arm64v8
  # ROS 2 resources are copied under `rootfs_overlay/opt/ros/jazzy`.
  # If `MIX_TARGET` is `rpi4` or `rpi3`, you can omit `--arch`.
  ```

  Write your application that uses Rclex.

  Generate the message definitions.

  ```
  mix rclex.gen.msgs --from rootfs_overlay/opt/ros/jazzy/share
  # The `--from` option is optional.
  ```

  Add `LD_LIBRARY_PATH` to `rootfs_overlay/etc/erlinit.config`.

  See `USE_ON_NERVES.md` for more details.

  ### Linux host without ROS 2

  The following example uses `amd64` and `jazzy`.

  Prepare ROS 2 resources.

  ```
  export ROS_DISTRO=jazzy
  mix rclex.prep.ros2 --arch amd64
  # ROS 2 resources are copied under `.ros2/resources/from-docker/amd64/jazzy/opt/ros/jazzy`.
  ```

  Write your application that uses Rclex.

  Generate the message definitions.

  ```
  mix rclex.gen.msgs --from .ros2/resources/from-docker/amd64/jazzy/opt/ros/jazzy/share
  ```

  Run the application with `LD_LIBRARY_PATH`.

  ```
  LD_LIBRARY_PATH=.ros2/resources/from-docker/amd64/jazzy/opt/ros/jazzy/lib run your app
  ```

  ## Usage

  ```
  mix rclex.prep.ros2 --arch ARCH
  ```

  ROS 2 resources are prepared under:

  - `.ros2/resources/from-docker/<arch>/<ros_distro>/opt/ros/<ros_distro>` on the host
  - `rootfs_overlay/opt/ros/<ros_distro>` on Nerves

  You can omit `--arch` on Nerves when it is inferred from `MIX_TARGET`.

  You can also customize the Docker image with `--dockerfile`. This option is
  supported for `arm64v8` and `amd64` only.

  - `--dockerfile PATH`: build the given Dockerfile and copy resources from the
    resulting image.

  ## Default Docker images

  - `arm64v8`, `amd64`: `ARCH/ros:ROS_DISTRO-ros-core`
  - `arm32v7`: `rclex/arm32v7_ros_docker_with_vendor_resources:ROS_DISTRO`

  ## Requirements for `--dockerfile`

  The built image must provide at least the following directories:

  - `/opt/ros/$ROS_DISTRO/include`
  - `/opt/ros/$ROS_DISTRO/lib`
  - `/opt/ros/$ROS_DISTRO/share`

  ## Notes

  - `--dockerfile` is not available for `arm32v7`.
  - The image architecture used by the Dockerfile must match the requested
    target architecture.

  ## Examples

  Specify the architecture explicitly with `--arch`.

  ```
  mix rclex.prep.ros2 --arch arm64v8
  ```

  For Nerves, if `MIX_TARGET` is `rpi4` or `rpi3`, `--arch` can be omitted.

  ```
  mix rclex.prep.ros2
  ```

  Build a custom image from an arbitrary Dockerfile.

  ```
  mix rclex.prep.ros2 --arch arm64v8 --dockerfile docker/ros2/Dockerfile
  ```

  In this example, `docker/ros2/Dockerfile` is just a sample path.

  A frequently used example for your own Dockerfile is when you want to use Zenoh as RMW (`rmw_zenoh_cpp`) on the Nerves system. In that case, a customized Dockerfile would be as follows:

  ```
  FROM arm64v8/ros:jazzy-ros-core

  RUN apt-get update \\
      && apt-get install -y --no-install-recommends \\
           ros-jazzy-rmw-zenoh-cpp \\
      && rm -rf /var/lib/apt/lists/*
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
  @supported_custom_docker_arch ["arm64v8", "amd64"]

  @nerves_target_arch_map %{"rpi4" => "arm64v8", "rpi3" => "arm32v7"}

  @switches [arch: :string, dockerfile: :string]

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

    docker_input_mode = docker_input_mode(parsed_args)
    validate_custom_docker_mode!(arch, docker_input_mode)
    docker_tag = resolve_copy_source_image!(arch, ros_distro, docker_input_mode)

    # NOTE: If you implement the copy destination option, pass the path here.
    dest_dir_path = copy_dest_dir_path(arch, ros_distro)

    message = """
    Are you sure to copy ROS 2 resources to following directory?
    path: #{dest_dir_path}
    image: #{docker_tag}
    """

    if Mix.shell().yes?(String.trim_trailing(message)) do
      copy_from_docker!(dest_dir_path, arch, ros_distro, docker_tag)
    end
  end

  @doc false
  def parse_args(args) do
    {parsed_args, _remaining_args, invalid} = OptionParser.parse(args, strict: @switches)

    if invalid != [] do
      invalid_options = Enum.map_join(invalid, ", ", fn {key, _value} -> to_string(key) end)
      Mix.raise("Unknown options: #{invalid_options}")
    end

    parsed_args
  end

  @doc false
  @spec docker_input_mode(keyword()) :: :default | {:dockerfile, String.t()}
  def docker_input_mode(parsed_args) do
    case Keyword.get(parsed_args, :dockerfile) do
      nil -> :default
      dockerfile -> {:dockerfile, dockerfile}
    end
  end

  @doc false
  def copy_from_docker!(dest_dir_path, arch, ros_distro, docker_tag) do
    Mix.shell().info("\nCopy from image: #{docker_tag}\n")

    dest_path = Path.join(dest_dir_path, "/opt/ros/#{ros_distro}")
    create_resources_directory!(dest_path, _git_ignore = true)
    copy_ros_resources_from_docker!(dest_path, arch, ros_distro, docker_tag)

    dest_path = Path.join(dest_dir_path, "/opt/ros/#{ros_distro}/lib")
    create_resources_directory!(dest_path, _git_ignore = false)
    copy_vendor_resources_from_docker!(dest_path, arch, ros_distro, docker_tag)
  end

  defp copy_ros_resources_from_docker!(dest_path, arch, ros_distro, docker_tag)
       when arch in ["arm64v8", "amd64"] do
    [
      "/opt/ros/#{ros_distro}/include",
      "/opt/ros/#{ros_distro}/lib",
      "/opt/ros/#{ros_distro}/share",
      # vendor's ex.) zenoh_cpp_vendor
      "/opt/ros/#{ros_distro}/opt"
    ]
    |> Enum.each(fn src_path -> copy_from_docker_impl!(docker_tag, arch, src_path, dest_path) end)
  end

  defp copy_ros_resources_from_docker!(dest_path, arch, _ros_distro, docker_tag)
       when arch in ["arm32v7"] do
    [
      "/root/ros2_ws/install/*/include",
      "/root/ros2_ws/install/*/lib",
      "/root/ros2_ws/install/*/share"
    ]
    |> Enum.each(fn src_path -> copy_from_docker_impl!(docker_tag, arch, src_path, dest_path) end)
  end

  defp copy_vendor_resources_from_docker!(dest_path, arch, ros_distro, docker_tag)
       when arch in ["arm64v8", "amd64", "arm32v7"] do
    vendor_resources(arch, ros_distro)
    |> Enum.each(fn src_path -> copy_from_docker_impl!(docker_tag, arch, src_path, dest_path) end)
  end

  defp vendor_resources(arch, "humble") do
    dir_name = arch_dir_name(arch)

    [
      "/lib/#{dir_name}/libspdlog.so*",
      "/lib/#{dir_name}/libtinyxml2.so*",
      "/lib/#{dir_name}/libfmt.so*"
    ]
  end

  defp vendor_resources(arch, "jazzy") do
    dir_name = arch_dir_name(arch)

    [
      "/lib/#{dir_name}/libspdlog.so*",
      "/lib/#{dir_name}/libtinyxml2.so*",
      "/lib/#{dir_name}/libfmt.so*",
      "/lib/#{dir_name}/libyaml*.so*",
      "/lib/#{dir_name}/liblttng-ust.so*",
      "/lib/#{dir_name}/libnuma.so*",
      "/lib/#{dir_name}/liblttng-ust-common.so*",
      "/lib/#{dir_name}/liblttng-ust-tracepoint.so*"
    ]
  end

  defp copy_from_docker_impl!(docker_tag, arch, src_path, dest_path) do
    with true <- File.exists?(dest_path) do
      docker_command_args = [
        "run",
        "--rm",
        "--platform",
        "#{platform(arch)}",
        "-v",
        "#{dest_path}:/mnt",
        docker_tag
      ]

      copy_command = [
        "bash",
        "-c",
        "for s in #{src_path}; do test -e $s || continue; cp -rf $s /mnt; done"
      ]

      {command_output, status} =
        System.cmd("docker", docker_command_args ++ copy_command, stderr_to_stdout: true)

      if status == 0 do
        message = "Copied from #{src_path} to #{Path.relative_to_cwd(dest_path)}"
        Mix.shell().info(message)
      else
        Mix.raise("""
        Failed to copy resources from Docker.
        src: #{src_path}
        dest: #{Path.relative_to_cwd(dest_path)}
        image: #{docker_tag}
        exit_status: #{status}
        output:
        #{command_output}
        """)
      end
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

  defp resolve_copy_source_image!(arch, ros_distro, :default) do
    ros_docker_image_tag(arch, ros_distro)
  end

  defp resolve_copy_source_image!(arch, ros_distro, {:dockerfile, input_path}) do
    prepare_custom_docker_image!(arch, ros_distro, input_path)
  end

  defp validate_custom_docker_mode!(_arch, :default) do
    :ok
  end

  defp validate_custom_docker_mode!(arch, {:dockerfile, _path})
       when arch in @supported_custom_docker_arch do
    :ok
  end

  defp validate_custom_docker_mode!(arch, {:dockerfile, _path}) do
    Mix.raise(
      "Custom Dockerfile support is available only for #{Enum.join(@supported_custom_docker_arch, ", ")}. Received: #{arch}"
    )
  end

  defp prepare_custom_docker_image!(arch, ros_distro, input_path) do
    input_path = validate_input_file!(input_path)
    spec = custom_docker_build_spec!(arch, ros_distro, input_path)

    build_custom_docker_image!(spec)
    validate_custom_docker_image!(spec)

    spec.image_tag
  end

  defp validate_input_file!(input_path) do
    expanded_path = Path.expand(input_path)

    cond do
      not File.exists?(expanded_path) ->
        Mix.raise("--dockerfile file does not exist: #{expanded_path}")

      not File.regular?(expanded_path) ->
        Mix.raise("--dockerfile path is not a regular file: #{expanded_path}")

      true ->
        expanded_path
    end
  end

  defp custom_docker_build_spec!(arch, ros_distro, input_path) do
    context_path = Path.dirname(input_path)

    %{
      arch: arch,
      ros_distro: ros_distro,
      image_tag: "rclex/prep_ros2:#{arch}-#{ros_distro}",
      source_path: input_path,
      # For the meaning of Docker build context, see:
      # https://docs.docker.com/build/concepts/context/#what-is-a-build-context
      build_context_path: context_path,
      build_dockerfile_path: input_path
    }
  end

  defp build_custom_docker_image!(spec) do
    Mix.shell().info("\nBuilding image: #{spec.image_tag}\n")

    build_args = [
      "build",
      "--progress=plain",
      "--platform",
      platform(spec.arch),
      "-t",
      spec.image_tag,
      "-f",
      spec.build_dockerfile_path,
      spec.build_context_path
    ]

    {command_output, status} = run_command_with_live_output!("docker", build_args)

    if status != 0 do
      Mix.raise("""
      Failed to build Docker image.
      mode: dockerfile
      dockerfile: #{spec.build_dockerfile_path}
      context: #{spec.build_context_path}
      image: #{spec.image_tag}
      exit_status: #{status}
      output:
      #{command_output}
      """)
    end
  end

  defp validate_custom_docker_image!(spec) do
    validation_paths = ros_resource_validation_paths(spec.arch, spec.ros_distro)
    validation_command = Enum.map_join(validation_paths, " && ", &"test -d #{&1}")

    validate_args = [
      "run",
      "--rm",
      "--platform",
      platform(spec.arch),
      spec.image_tag,
      "bash",
      "-c",
      validation_command
    ]

    {command_output, status} = run_command_with_live_output!("docker", validate_args)

    if status != 0 do
      Mix.raise("""
      Built image does not contain the required ROS 2 paths.
      image: #{spec.image_tag}
      required_paths: #{Enum.join(validation_paths, ", ")}
      exit_status: #{status}
      output:
      #{command_output}
      """)
    end
  end

  defp ros_resource_validation_paths(arch, ros_distro)
       when arch in @supported_custom_docker_arch do
    [
      "/opt/ros/#{ros_distro}/include",
      "/opt/ros/#{ros_distro}/lib",
      "/opt/ros/#{ros_distro}/share"
    ]
  end

  defp run_command_with_live_output!(command, args) do
    executable =
      System.find_executable(command) ||
        Mix.raise("Failed to find executable for command: #{command}")

    port =
      Port.open({:spawn_executable, executable}, [
        :binary,
        :exit_status,
        :use_stdio,
        :stderr_to_stdout,
        args: args
      ])

    collect_port_output(port, "")
  end

  defp collect_port_output(port, acc) do
    receive do
      {^port, {:data, data}} ->
        Mix.shell().info(data)
        collect_port_output(port, acc <> data)

      {^port, {:exit_status, status}} ->
        {acc, status}
    end
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
