[![Hex version](https://img.shields.io/hexpm/v/rclex.svg "Hex version")](https://hex.pm/packages/rclex)
[![API docs](https://img.shields.io/hexpm/v/rclex.svg?label=hexdocs "API docs")](https://hexdocs.pm/rclex/readme.html)
[![License](https://img.shields.io/hexpm/l/rclex.svg)](https://github.com/rclex/rclex/blob/main/LICENSE)
[![ci-latest](https://github.com/rclex/rclex/actions/workflows/ci-latest.yml/badge.svg)](https://github.com/rclex/rclex/actions/workflows/ci-latest.yml)
[![ci-all_version](https://github.com/rclex/rclex/actions/workflows/ci-all_version.yml/badge.svg)](https://github.com/rclex/rclex/actions/workflows/ci-all_version.yml)

[日本語のREADME](README_ja.md)

# Rclex

Rclex is a ROS 2 client library for the functional language [Elixir](https://elixir-lang.org/).

This library lets you perform basic ROS 2 behaviors by calling out from Elixir code into the RCL (ROS Client Library) API, which
uses the ROS 2 common hierarchy.

Additionally, publisher-subscriber (PubSub) communication between nodes and associated callback functions are executed as Erlang lightweight processes.
This enables the creation of and communication between a large number of fault-tolerant
nodes while suppressing memory load.

## What is ROS 2

ROS 2 (Robot Operating System 2) is a state-of-the-art Robot development platform. In ROS 2, each functional
unit is exposed as a node, and by combining these nodes you can create different robot applications. Additionally,
communication between nodes uses a PubSub model where publishers and subscribers exchange information by specifying a
common topic name.

The main benefits of ROS 2 are that the DDS (Data Distribution Service) protocol was adopted for
communication, and the library was divided into a hierarchical structure.
This allows us to develop  ROS 2 client libraries in various languages and, of course, to build robot applications in Elixir.

For details on ROS 2, see [the official ROS 2 Documentation](https://docs.ros.org/en/rolling/index.html).

## Recommended environment

### Native environment

The basic and recommended environment is where the host (development) and the target (operation) are the same.

Currently, we use the following environment as the main development target:

- Ubuntu 22.04.4 LTS (Jammy Jellyfish)
- ROS 2 [Humble Hawksbill](https://docs.ros.org/en/humble/Releases/Release-Humble-Hawksbill.html)
- Elixir 1.15.7-otp-26
- Erlang/OTP 26.2.2

We highly recommend using Humble for ROS 2 LTS distribution.
Iron, the STS distribution, is experimentally supported and confirmed for the proper operation only in the native environment. See detail and status on [Issue#228](https://github.com/rclex/rclex/issues/228#issuecomment-1715293177).
Although we also use Foxy and Galactic as CI targets, they have already reached EOL.

For other environments used to check the operation of this library,
please refer to [here](https://github.com/rclex/rclex_docker#available-versions-docker-tags).

### Docker environment

The pre-built Docker images are available at [Docker Hub](https://hub.docker.com/r/rclex/rclex_docker).
You can also try the power of Rclex with it easily. Please check ["Docker Environment"](#Docker-environment) section for details.

### Nerves device (target)

`rclex` can be operated onto Nerves. In this case, you do not need to prepare the ROS 2 environment on the host computer to build Nerves project (so awesome!).

Please refer to [Use on Nerves](USE_ON_NERVES.md) section and [b5g-ex/rclex_on_nerves](https://github.com/b5g-ex/rclex_on_nerves) example repository for more details!

## Features

Currently, the Rclex API allows for the following:

1. The ability to create a large number of publishers sending to the same topic.
2. The ability to create large numbers of each combination of publishers, topics, and subscribers.

You can find the API documentation at [https://hexdocs.pm/rclex](https://hexdocs.pm/rclex).

Please refer [rclex/rclex_examples](https://github.com/rclex/rclex_examples) for the examples of usage along with the sample code.

## How to use

This section explains the quickstart for `rclex` in the native environment where ROS 2 and Elixir have been installed.

### Create the project

First of all, create the Mix project as a normal Elixir project.

```
mix new rclex_usage
cd rclex_usage
```

### Install rclex

`rclex` is [available in Hex](https://hex.pm/docs/publish).

You can install this package into your project
by adding `rclex` to your list of dependencies in `mix.exs`:

```elixir
  defp deps do
    [
      ...
      {:rclex, "~> 0.10.0"},
      ...
    ]
  end
```

After that, execute `mix deps.get` into the project repository.

```
mix deps.get
```

### Setup the ROS 2 environment

```
source /opt/ros/humble/setup.bash
```

## Configure ROS 2 message types you want to use

Rclex provides pub/sub-based topic communication using the message type defined in ROS 2. Please refer [here](https://docs.ros.org/en/humble/Concepts/About-ROS-Interfaces.html) for more details about message types in ROS 2.

The message types you want to use in your project can be specified in `ros2_message_types` in `config/config.exs`. 
Multiple message types can be specified separated by comma `,`.

The following `config/config.exs` example wants to use `String` type.

```elixir
import Config

config :rclex, ros2_message_types: ["std_msgs/msg/String"]
```

Then, execute the following Mix task to generate required definitions and files for message types.

```
mix rclex.gen.msgs
```

When editing `config/config.exs` to change the message types, do `mix rclex.gen.msgs` again.

### Write Rclex code

Now, you can acquire the environment for [Rclex API](https://hexdocs.pm/rclex/api-reference.html)! Of course, you can execute APIs on IEx directly.

Here is the simplest implementation example `lib/rclex_usage.ex` that will publish the string to `/chatter` topic.

```elixir
defmodule RclexUsage do
  alias Rclex.Pkgs.StdMsgs

  def publish_message do
    Rclex.start_node("talker")
    Rclex.start_publisher(StdMsgs.Msg.String, "/chatter", "talker")

    data = "Hello World from Rclex!"
    msg = struct(StdMsgs.Msg.String, %{data: data})

    IO.puts("Rclex: Publishing: #{data}")
    Rclex.publish(msg, "/chatter", "talker")
  end
end
```

Please also check the examples for Rclex.

- [rclex/rclex_examples](https://github.com/rclex/rclex_examples)

### Build and Execute

Build your application as follows.

```
mix compile
iex -S mix
```

Operate the following command on IEx.

```
iex()> RclexUsage.publish_message
Rclex: Publishing: Hello World from Rclex!
:ok
```

You can confirm the above operation by subscribing with `ros2 topic echo` from the other terminal.

```
$ source /opt/ros/humble/setup.bash
$ ros2 topic echo /chatter std_msgs/msg/String
data: Hello World from Rclex!
---
```

## Enhance devepoment experience

This section describes the information mainly for developers.

### Docker environment

This repository provides a `docker compose` environment for library development with Docker.

As mentioned above, pre-built Docker images are available at [Docker Hub](https://hub.docker.com/r/rclex/rclex_docker), which can be used to easily try out Rclex.
You can set the environment variable `$RCLEX_DOCKER_TAG` to the version of the target environment. Please refer to [here](https://github.com/rclex/rclex_docker#available-versions-docker-tags) for the available environments.

```
# optional: set to the target environment (default `latest`)
export RCLEX_DOCKER_TAG=latest
# create and start the container
docker compose up -d
# execute the container (with the workdir where this repository is mounted)
docker compose exec -w /root/rclex rclex_docker /bin/bash
# stop the container
docker compose down
```

In [GitHub Actions](https://github.com/rclex/rclex/actions), we perform CI on multiple tool versions at Pull Requests by using these Docker environments. However, we cannot guarantee operation in all of these environments.

### Automatic execution of mix test, etc.

`mix test.watch` is introduced to automatically run unit test `mix test` and code formatting `mix format` every time the source code was edited.

```
$ mix test.watch
# or, run on docker by following
$ docker compose run --rm -w /root/rclex rclex_docker mix test.watch
```

### Confirmation of communication operation

To check the operation, especially for communication features of this library, we prepare [rclex/rclex_connection_tests](https://github.com/rclex/rclex_connection_tests) to test the communication with the nodes implemented with Rclcpp.

```
cd /path/to/yours
git clone https://github.com/rclex/rclex
git clone https://github.com/rclex/rclex_connection_tests
cd /path/to/yours/rclex_connection_tests
./run-all.sh
```

## Presentations

- Rclex on Nerves: a bare minimum runtime platform for ROS 2 nodes in Elixir
  - [ROSCon 2023](https://roscon.ros.org/2023/)
  - [Video](https://vimeo.com/879001529/b23eaacae8) | [SpeakerDeck](https://speakerdeck.com/takasehideki/rclex-on-nerves-a-bare-minimum-runtime-platform-for-ros-2-nodes-in-elixir)
- On the way to achieve autonomous node communication in the Elixir ecosystem
  - [Code BEAM America 2022](https://codebeamamerica.com/archives/CBA_2023/index.html) at 2022/11/03
  - [Video](https://www.youtube.com/watch?v=Y4IASAU4Bjo) | [SpeakerDeck](https://speakerdeck.com/takasehideki/on-the-way-to-achieve-autonomous-node-communication-in-the-elixir-ecosystem)
- Rclex: A Library for Robotics meet Elixir
  - [Code BEAM America 2021](https://codesync.global/conferences/code-beam-sf-2021/) at 2021/11/05
  - [Video](https://www.youtube.com/watch?v=9B5lQ3kQ_wI) | [SlideShare](https://www.slideshare.net/takasehideki/rclex-a-library-for-robotics-meet-elixir)

## Maintainers and developers (including past)

- [@takasehideki](https://github.com/takasehideki)
- [@s-hosoai](https://github.com/s-hosoai)
- [@pojiro](https://github.com/pojiro)
- [@HiroiImanishi](https://github.com/HiroiImanishi)
- [@kebus426](https://github.com/kebus426)
- [@shiroro466](https://github.com/shiroro466)
