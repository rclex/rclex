# Use on Nerves

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

```
export ROS_DISTRO=foxy
mix rclex.prep.ros2
```

## Configure ROS 2 message types you want to use

Add `ros2_message_types` config to config/config.exs. The following example wants to use messages of type String and Twist.

```elixir
config :rclex, ros2_message_types: ["std_msgs/msg/String", "geometry_msgs/msg/Twist"]
```

Generate message types codes for topic communication.

```
mix rclex.gen.msgs
```

## Write Rclex code

Now you can write your ROS 2 codes with Rclex!

Please also check the examples for Rclex.
- [rclex/rclex_examples](https://github.com/rclex/rclex_examples)
- [b5g-ex/rclex_on_nerves](https://github.com/b5g-ex/rclex_on_nerves)

If you change the message types in config, do `mix rclex.gen.msgs` again.

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
