defmodule Mix.Tasks.Rclex.Prep.Ros2Test do
  use ExUnit.Case

  alias Mix.Tasks.Rclex.Prep.Ros2

  describe "docker_input_mode/1" do
    test "returns default when docker options are not specified" do
      assert Ros2.docker_input_mode([]) == :default
    end

    test "returns dockerfile mode" do
      assert Ros2.docker_input_mode(dockerfile: "docker/ros2/Dockerfile") ==
               {:dockerfile, "docker/ros2/Dockerfile"}
    end
  end

  describe "parse_args/1" do
    test "parses supported options" do
      assert Ros2.parse_args([
               "--arch",
               "amd64",
               "--dockerfile",
               "docker/ros2/Dockerfile"
             ]) == [arch: "amd64", dockerfile: "docker/ros2/Dockerfile"]
    end

    test "allows positional arguments and parses known options" do
      assert Ros2.parse_args(["--arch", "arm64v8", "extra-arg"]) == [arch: "arm64v8"]
    end

    test "raises on unknown options" do
      assert_raise Mix.Error, ~r/Unknown options: --unknown/, fn ->
        Ros2.parse_args(["--unknown", "value"])
      end
    end
  end
end
