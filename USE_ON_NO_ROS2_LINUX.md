# Use on No ROS 2 Linux

`rclex` can run on Linux environments where ROS 2 is not installed.
In this case, ROS 2 resources are prepared from Docker and copied into your project.

This document explains a minimal, practical workflow for host Linux.

## Procedure

> #### Target environment {: .neutral }
>
> The examples below assume:
> - Architecture: `amd64`
> - ROS 2 distro: `jazzy`

### Prepare ROS 2 resources

Set `ROS_DISTRO`, then run `mix rclex.prep.ros2` with your host architecture.

```
export ROS_DISTRO=jazzy
mix rclex.prep.ros2 --arch amd64
```

The resources are copied under:

```
.ros2/resources/from-docker/amd64/opt/ros/jazzy
```

### Configure ROS 2 message types

Specify ROS 2 message types in `config/config.exs`.

```elixir
import Config

config :rclex, ros2_message_types: ["std_msgs/msg/String"]
```

Generate the message-related files from the copied ROS 2 resources:

```
mix rclex.gen.msgs --from .ros2/resources/from-docker/amd64/opt/ros/jazzy/share
```

If you change `ros2_message_types`, run `mix rclex.gen.msgs` again.

### Write your application

Implement your application code that uses Rclex APIs.

### Run with `LD_LIBRARY_PATH`

Set `LD_LIBRARY_PATH` to the copied ROS 2 library path when running your app:

```
LD_LIBRARY_PATH=.ros2/resources/from-docker/amd64/opt/ros/jazzy/lib YOUR_COMMAND
```

For example:

```
LD_LIBRARY_PATH=.ros2/resources/from-docker/amd64/opt/ros/jazzy/lib iex -S mix
```
