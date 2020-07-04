[![Hex version](https://img.shields.io/hexpm/v/rclex.svg "Hex version")](https://hex.pm/packages/rclex)
[![API docs](https://img.shields.io/hexpm/v/rclex.svg?label=hexdocs "API docs")](https://hexdocs.pm/rclex/readme.html)
[![License](https://img.shields.io/hexpm/l/rclex.svg)](https://github.com/tlk-emb/rclex/blob/master/LICENSE)

[日本語のREADME](README_ja.md)

# Rclex

Rclex is a ROS 2 client library for Elixir.

This library lets you perform basic ROS 2 behaviors by calling out from Elixir code into the RCL (ROS Client Library) API, which
uses the ROS 2 common hierarchy.

Additionally, publisher-subscriber (PubSub) communication between nodes and associated callback functions are executed by *tasks*,
which are part of a lightweight process model. This enables generation of and communication between a large number of fault-tolerant
nodes while suppressing memory load.

## About ROS 2

ROS (Robot Operating System) is a next-generation Robot development framework. In both ROS and ROS 2, each functional
unit is exposed as a node, and by combining these nodes you can create different robot applications. Additionally,
communication between nodes uses a PubSub model where publisher and subscriber exchange information by specifying a
common topic name.

The biggest difference between ROS and ROS 2 is that the DDS (Data Distribution Service) protocol was adopted for
communication, and the library was divided in a hierarchical structure, allowing for the creation of ROS 2 client
libraries in various languages. This has allowed for the creation of a robot application library in Elixir.

For details on ROS 2, see the official [ROS 2 documentation](https://index.ros.org/doc/ros2/).

## Usage

Currently, the Rclex API allows for the following:

1. The ability to create a large number of publishers sending to the same topic.
2. The ability to create large numbers of each combination of publishers, topics, and subscribers.

## Making it Work

Please reference examples [here](https://github.com/tlk-emb/rclex_samples). Also note the usage alongside the sample code.


## Environments

We tested following versions:

- Ubuntu 18.04.4 LTS
- ROS 2 [Dashing Diademata](https://index.ros.org/doc/ros2/Releases/Release-Dashing-Diademata/)
- Elixir 1.9.1-otp-22
- Erlang 22.0.7

Please let us know if you can operate this library with another environment.

## Installation

`rclex` is [available in Hex](https://hex.pm/docs/publish).

You can install this package into your project
by adding `rclex` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:rclex, "~> 0.3.1"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm).  
You can find the docs at [https://hexdocs.pm/rclex](https://hexdocs.pm/rclex).

