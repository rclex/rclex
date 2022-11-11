defmodule Mix.Tasks.Rclex.Prep.Ros2Test do
  use ExUnit.Case

  test "command_exists?/1" do
    assert Mix.Tasks.Rclex.Prep.Ros2.command_exists?("ls")
    refute Mix.Tasks.Rclex.Prep.Ros2.command_exists?("non_existent_command")
  end

  @tag skip: "take time"
  @tag :tmp_dir
  test "copy_from_docker!/2", %{tmp_dir: tmp_dir_path} do
    Mix.Tasks.Rclex.Prep.Ros2.copy_from_docker!(tmp_dir_path, "arm64v8", "foxy")

    assert File.exists?(Path.join(tmp_dir_path, ".gitignore"))
    assert File.ls!(tmp_dir_path) |> Enum.count() > 0
  end

  test "ros_docker_image_tag/2" do
    assert "arm64v8/ros:foxy-ros-core" =
             Mix.Tasks.Rclex.Prep.Ros2.ros_docker_image_tag("arm64v8", "foxy")

    assert "amd64/ros:humble-ros-core" =
             Mix.Tasks.Rclex.Prep.Ros2.ros_docker_image_tag("amd64", "humble")
  end

  test "parse_args/1" do
    assert [arch: "arm64v8"] = Mix.Tasks.Rclex.Prep.Ros2.parse_args(["--arch", "arm64v8"])
    assert [] = Mix.Tasks.Rclex.Prep.Ros2.parse_args([])
  end

  @tag :tmp_dir
  test "create_resources_directory!/1", %{tmp_dir: tmp_dir_path} do
    :ok = Mix.Tasks.Rclex.Prep.Ros2.create_resources_directory!(tmp_dir_path)
    assert File.exists?(Path.join(tmp_dir_path, ".gitignore"))
  end
end
