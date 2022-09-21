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

## Recommended Environment

Currently, we use the following environment as the development target:

- Ubuntu 20.04.2 LTS (Focal Fossa)
- ROS 2 [Foxy Fitzroy](https://docs.ros.org/en/foxy/Releases/Release-Foxy-Fitzroy.html)
  - NOTE: [Dashing Diademata](https://index.ros.org/doc/ros2/Releases/Release-Dashing-Diademata/) on Ubuntu 18.04.5 LTS does not work well since v0.6.0 (we try to continue to support it, see #89)
- Elixir 1.12.3-otp-24
- Erlang/OTP 24.1.5

As an operation test, we check the communication with nodes implemented by [rclcpp](https://github.com/ros2/rclcpp) using [rclex/rclex_connection_tests](https://github.com/rclex/rclex_connection_tests).

We also run CI in multiple different environments on [GitHub Actions](https://github.com/rclex/rclex/actions). 
However, please note that we cannot guarantee the operation of all of these versions due to our limited development resources.

The pre-built Docker images used in CI have published on [Docker Hub](https://hub.docker.com/r/rclex/rclex_docker).
You can also try the power of Rclex with it easily.

## Installation

`rclex` is [available in Hex](https://hex.pm/docs/publish).

You can install this package into your project
by adding `rclex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rclex, "~> 0.7.0"}
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

## Maintainers and developers (including past)

- [@takasehideki](https://github.com/takasehideki)
- [@HiroiImanishi](https://github.com/HiroiImanishi)
- [@kebus426](https://github.com/kebus426)
- [@shiroro466](https://github.com/shiroro466)
- [@s-hosoai](https://github.com/s-hosoai)
