[![Hex version](https://img.shields.io/hexpm/v/rclex.svg "Hex version")](https://hex.pm/packages/rclex)
[![API docs](https://img.shields.io/hexpm/v/rclex.svg?label=hexdocs "API docs")](https://hexdocs.pm/rclex/readme.html)
[![License](https://img.shields.io/hexpm/l/rclex.svg)](https://github.com/rclex/rclex/blob/main/LICENSE)
[![ci-latest_push](https://github.com/rclex/rclex/actions/workflows/ci_latest.yml/badge.svg)](https://github.com/rclex/rclex/actions/workflows/ci_latest.yml)
[![ci-allver_PR](https://github.com/rclex/rclex/actions/workflows/ci_allver.yml/badge.svg)](https://github.com/rclex/rclex/actions/workflows/ci_allver.yml)

[日本語のREADME](README_ja.md)

# Rclex

Rclex is a ROS 2 client library for Elixir.

This library lets you perform basic ROS 2 behaviors by calling out from Elixir code into the RCL (ROS Client Library) API, which
uses the ROS 2 common hierarchy.

Additionally, publisher-subscriber (PubSub) communication between nodes and associated callback functions are executed by *tasks*,
which are part of a lightweight process model. This enables generation of and communication between a large number of fault-tolerant
nodes while suppressing memory load.

## What is ROS 2

ROS (Robot Operating System) is a next-generation Robot development platform. In both ROS and ROS 2, each functional
unit is exposed as a node, and by combining these nodes you can create different robot applications. Additionally,
communication between nodes uses a PubSub model where publisher and subscriber exchange information by specifying a
common topic name.

The biggest difference between ROS and ROS 2 is that the DDS (Data Distribution Service) protocol was adopted for
communication, and the library was divided in a hierarchical structure, allowing for the creation of ROS 2 client
libraries in various languages. This has allowed for the creation of a robot application library in Elixir.

For details on ROS 2, see the official [ROS 2 documentation](https://index.ros.org/doc/ros2/).

## Recommended environment

Currently, we use the following environment as the main development target:

- Ubuntu 20.04.2 LTS (Focal Fossa)
- ROS 2 [Foxy Fitzroy](https://docs.ros.org/en/foxy/Releases/Release-Foxy-Fitzroy.html)
- Elixir 1.13.4-otp-25
- Erlang/OTP 25.0.3

For other environments used to check the operation of this library,
please refer to [here](https://github.com/rclex/rclex_docker#available-versions-docker-tags).

The pre-built Docker images are available at [Docker Hub](https://hub.docker.com/r/rclex/rclex_docker).
You can also try the power of Rclex with it easily. Please check ["Docker Environment"](#Docker-environment) section for details.

## Installation

`rclex` is [available in Hex](https://hex.pm/docs/publish).

You can install this package into your project
by adding `rclex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rclex, "~> 0.7.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm).  
You can find the docs at [https://hexdocs.pm/rclex](https://hexdocs.pm/rclex).

## Usage

Currently, the Rclex API allows for the following:

1. The ability to create a large number of publishers sending to the same topic.
2. The ability to create large numbers of each combination of publishers, topics, and subscribers.

Please reference examples [here](https://github.com/rclex/rclex_examples). Also note the usage alongside the sample code.

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

### Automatic execution of mix test, etc.

`mix test.watch` is introduced to automatically run unit test `mix test` and code formatting `mix format` every time the source code was editted.

```
mix test.watch
```

### Confirmation of operation

To check the operation of this library, we prepare [rclex/rclex_connection_tests](https://github.com/rclex/rclex_connection_tests) to test the communication with the nodes implemented with Rclcpp.

```
cd /path/to/yours
git clone https://github.com/rclex/rclex
git clone https://github.com/rclex/rclex_connection_tests
cd /path/to/yours/rclex_connection_tests
./run-all.sh
```

In [GitHub Actions](https://github.com/rclex/rclex/actions), we perform CI on multiple environments at Pull Requests. HOwever, we cannot guarantee operation in all of these environments.

## Maintainers and developers (including past)

- [@takasehideki](https://github.com/takasehideki)
- [@HiroiImanishi](https://github.com/HiroiImanishi)
- [@kebus426](https://github.com/kebus426)
- [@shiroro466](https://github.com/shiroro466)
- [@s-hosoai](https://github.com/s-hosoai)
