# Use on Nerves

`rclex` can be operated onto Nerves. In this case, you do not need to prepare the ROS 2 environment on the host computer to build Nerves project (so awesome!).

This doc shows the steps on how to use Rclex on Nerves from scratch.

We have also published the Nerves project that has been prepared and includes example code at [b5g-ex/rclex_on_nerves](https://github.com/b5g-ex/rclex_on_nerves). Please also refer to this repository. 
> #### Support Target {: .neutral }
>
> Currentry Rclex only support aarch64 for Nerves, following steps use rpi4 as an example.

## Create Nerves Project

```
mix nerves.new rclex_usage_on_nerves --target rpi4
cd rclex_usage_on_nerves
export MIX_TARGET=rpi4
mix deps.get
```

> #### Note {: .warning }
>
> If `mix deps.get` failed, you may need to create SSH key and configure config/target.exs.

## Add rclex as the dependency in mix.exs

Please edit mix.exs to add rclex as the dependency of your Nerves project as the following.

```elixir
  defp deps do
    [
      ...
      # FIXME when merged
      {:rclex,
       git: "https://github.com/rclex/rclex.git", branch: "improve-mix_tasks_usability-pojiro"},
      ...
    ]
  end
```

```
mix deps.get
```

## Prepare ROS 2 resoures

Please start Docker first since Docker is used in this step.

```
export ROS_DISTRO=foxy
mix rclex.prep.ros2
```

The above command extracts the ROS 2 Docker image and copies resources required for Rclex to the Nerves file system.

## Configure ROS 2 message types you want to use

Rclex provides pub/sub based topic communication using the message type defined in ROS 2. Please refer [here](https://docs.ros.org/en/foxy/Concepts/About-ROS-Interfaces.html) for more details about message types in ROS 2.

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

If you want to change the message types in config, do `mix rclex.gen.msgs` again.

## Write Rclex code

Now, you can acquire the environment for [Rclex API](https://hexdocs.pm/rclex/api-reference.html)! Of course, you can execute APIs on IEx directly.

Please also check the examples for Rclex.
- [rclex/rclex_examples](https://github.com/rclex/rclex_examples)
- [b5g-ex/rclex_on_nerves](https://github.com/b5g-ex/rclex_on_nerves)

## Copy erlinit.config to rootfs_overlay/etc and add LD_LIBRARY_PATH

Copy erlinit.config from `nerves_system_***`.

```
cp deps/nerves_system_rpi4/rootfs_overlay/etc/erlinit.config rootfs_overlay/etc
```

Add `-e LD_LIBRARY_PATH=/opt/ros/foxy/lib` line like following.  
`ROS_DISTRO` is needed to be written directly, following is the case of `foxy`.

```
# Enable UTF-8 filename handling in Erlang and custom inet configuration
-e LANG=en_US.UTF-8;LANGUAGE=en;ERL_INETRC=/etc/erl_inetrc;ERL_CRASH_DUMP=/root/crash.dump
-e LD_LIBRARY_PATH=/opt/ros/foxy/lib
```

> #### Why add LD_LIBRARY_PATH explicitly {: .info }
>
> ROS 2 needs the path. If you want to know the details, please read followings
>
> - https://github.com/ros-tooling/cross_compile/issues/363
> - https://github.com/ros2/rcpputils/pull/122

## Create fw, and burn (or, upload)

```
mix firmware
mix burn # or, mix upload
```
