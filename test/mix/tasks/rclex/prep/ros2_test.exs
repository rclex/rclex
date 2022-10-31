defmodule Mix.Tasks.Rclex.Prep.Ros2Test do
  use ExUnit.Case

  test "command_exists?/1" do
    assert Mix.Tasks.Rclex.Prep.Ros2.command_exists?("ls")
    refute Mix.Tasks.Rclex.Prep.Ros2.command_exists?("non_existent_command")
  end

  @tag skip: "take time"
  @tag :tmp_dir
  test "copy_ros2_resources_from_docker!/3", %{tmp_dir: tmp_dir_path} do
    Mix.Tasks.Rclex.Prep.Ros2.copy_ros2_resources_from_docker!(tmp_dir_path, "arm64v8", "foxy")

    assert File.ls!(tmp_dir_path) |> Enum.count() > 0
  end

  @tag skip: "take time"
  @tag :tmp_dir
  test "copy_vendor_resources_from_docker!/3", %{tmp_dir: tmp_dir_path} do
    Mix.Tasks.Rclex.Prep.Ros2.copy_vendor_resources_from_docker!(tmp_dir_path, "arm64v8", "foxy")

    assert File.ls!(tmp_dir_path) |> Enum.count() > 0
  end

  test "ros2_docker_image_tag/2" do
    assert "arm64v8/ros:foxy-ros-core" =
             Mix.Tasks.Rclex.Prep.Ros2.ros2_docker_image_tag("arm64v8", "foxy")
  end

  test "parse_args/1" do
    assert [arch: "arm64v8", ros2_distro: "foxy"] =
             Mix.Tasks.Rclex.Prep.Ros2.parse_args(["--arch", "arm64v8", "--ros2-distro", "foxy"])

    assert [nerves_system: "rpi4", ros2_distro: "foxy"] =
             Mix.Tasks.Rclex.Prep.Ros2.parse_args([
               "--nerves-system",
               "rpi4",
               "--ros2-distro",
               "foxy"
             ])
  end

  @tag :tmp_dir
  test "create_resources_directory!/2", %{tmp_dir: tmp_dir_path} do
    arch = "arm64v8"
    ros2_distro = "foxy"

    directory_path = Path.join(tmp_dir_path, ".ros2/resources/from-docker/#{arch}/#{ros2_distro}")

    ^directory_path =
      Mix.Tasks.Rclex.Prep.Ros2.create_resources_directory!(tmp_dir_path, arch, ros2_distro)

    assert File.exists?(directory_path)
  end
end
