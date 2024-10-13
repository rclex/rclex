# Use on Nerves

`rclex` can be operated onto Nerves. In this case, you do not need to prepare the ROS 2 environment on the host computer to build Nerves project (so awesome!).

This doc shows the steps on how to use Rclex on Nerves from scratch.

We have also published the Nerves project that has been prepared and includes example code at [b5g-ex/rclex_on_nerves](https://github.com/b5g-ex/rclex_on_nerves). Please also refer to this repository.

## Supported Targets

Currently, we have confirmed the following boards as the Nerves device that can operate Rclex (good luck to get one!).

| board | tag | arch | support for nerves_system |
| :--- | :--- | :---| :---|
| [Raspberry Pi 4](https://github.com/nerves-project/nerves_system_rpi4) | rpi4 | arm64v8 | Officially supported, recommended |
| [BeagleBone Green](https://github.com/nerves-project/nerves_system_bbb) | bbb | arm32v7 | Officially supported |
| [Kria KR260](https://github.com/b5g-ex/nerves_system_kr260) | kr260 | arm64v8 | Third-party supported |
| [ODYSSEY - STM32MP157C](https://github.com/b5g-ex/nerves_system_stm32mp157c_odyssey) | stm32mp157c_odyssey | arm32v7 | Third-party supported |
| [F3RP70 (e-RT3 Plus)](https://github.com/pojiro/nerves_system_f3rp70) | f3rp70 | arm32v7 | Third-party supported |

The below is the supported ROS 2 distribution and architecture that can operate rclex_on_nerves.
The "support" colomn refers to its status of official support as the ROS 2 distribution.

| `ROS_DISTRO` | arm64v8 | arm32v7 | support |
| :--- | :--- | :---| :---|
| humble | ○ | ○ | LTS until May 2027 |
| galactic | ○ | - | EOL at Dec 2022 |
| foxy | ○ | ○ | EOL at Jun 2023 |

## Preliminaries

During the procedure for Rclex on Nerves, the docker command is used to copy the necessary directory in `mix rclex.prep.ros2`.
Please install [Docker Desktop](https://docs.docker.com/desktop/) or [Docker Engine](https://docs.docker.com/engine/), and start it first.  
And also, Rclex on Nerves will deploy an docker container for arm64 arch. If you want to operate this project by Docker Engine on other platforms (x86_64), you need to install qemu as the follows: `sudo apt-get install qemu binfmt-support qemu-user-static`

It should be noted that do not perform the following steps inside a docker container.  
Once again, they can be operated even if ROS 2 is not installed on the host machine!

## Procedure

> #### Target device {: .neutral }
>
> The following steps assume that `rpi4` and `arm64v8` will be used as the target Nerves device.
> You may change the values of `MIX_TARGET` and `--arch` to match the "tag" and "arch" columns on the supported target list according to the board you want to use.

### Create Nerves Project

```
mix nerves.new rclex_usage_on_nerves --target rpi4
cd rclex_usage_on_nerves
export MIX_TARGET=rpi4
mix deps.get
```

> #### Note {: .warning }
>
> If `mix deps.get` failed, you may need to create SSH key and configure config/target.exs.

### Install rclex

`rclex` is [available in Hex](https://hex.pm/docs/publish).

You can install this package into your project
by adding `rclex` to your list of dependencies in `mix.exs`:

```elixir
  defp deps do
    [
      ...
      {:rclex, "~> 0.11.2"},
      ...
    ]
  end
```

After that, execute `mix deps.get` into the project repository.

```
mix deps.get
```

### Prepare ROS 2 resources

> #### Note {: .info }
>
> In the following steps, Humble Hawksbill (`humble`) is assumed to be used as `ROS_DISTRO` (strongly recommend to use).
> If you want to use `foxy` or `galactic`, you need to replace it appropriately in the subsequent steps. Note that these have already reached EOL.

The following command extracts the ROS 2 Docker image and copies resources required for Rclex to the Nerves file system.
You may change the value of `--arch` according to the architecture of your target board (see the "arch" column on the supported target list)

```
export ROS_DISTRO=humble
mix rclex.prep.ros2 --arch arm64v8
```

> #### Note {: .warning }
>
> The following warning messages will occur at several times when the host and target architectures are different. These can be ignored.
> > WARNING: The requested image's platform (linux/arm/v7) does not match the detected host platform (linux/amd64) and no specific platform was requested

### Configure ROS 2 message types you want to use

Rclex provides pub/sub based topic communication using the message type defined in ROS 2. Please refer [here](https://docs.ros.org/en/humble/Concepts/About-ROS-Interfaces.html) for more details about message types in ROS 2.

The message types you want to use in your project can be specified in `ros2_message_types` in `config/config.exs`. 
Multiple message types can be specified separated by comma `,`.

The following `config/config.exs` example wants to use `String` type.

```elixir
config :rclex, ros2_message_types: ["std_msgs/msg/String"]
```

Then, execute the following Mix task to generate required definitions and files for message types.

```
mix rclex.gen.msgs
```

If you want to change the message types in config, do `mix rclex.gen.msgs` again.

### Copy erlinit.config to rootfs_overlay/etc and add LD_LIBRARY_PATH

Copy erlinit.config from `nerves_system_***`.

```
cp deps/nerves_system_rpi4/rootfs_overlay/etc/erlinit.config rootfs_overlay/etc
```

Add LD_LIBRARY_PATH line like following.  
`ROS_DISTRO` should be written directly such as `humble`, as the below.

```
# Enable UTF-8 filename handling in Erlang and custom inet configuration
-e LANG=en_US.UTF-8;LANGUAGE=en;ERL_INETRC=/etc/erl_inetrc

# Enable crash dumps (set ERL_CRASH_DUMP_SECONDS=0 to disable)
-e ERL_CRASH_DUMP=/root/erl_crash.dump;ERL_CRASH_DUMP_SECONDS=5

# add for ROS 2 (rclex_on_nerves)
-e LD_LIBRARY_PATH=/opt/ros/humble/lib
```

> #### Why add LD_LIBRARY_PATH explicitly {: .info }
>
> ROS 2 needs the path. If you want to know the details, please read following
>
> - https://github.com/ros-tooling/cross_compile/issues/363
> - https://github.com/ros2/rcpputils/pull/122

> #### Note {: .warning }
>
> If you want to use `galactic`, adding line should be as the below.
> 
> ```
> ## only galactic needs /opt/ros/galactic/lib/aarch64-linux-gnu also, for libddsc
> # -e LD_LIBRARY_PATH=/opt/ros/galactic/lib/aarch64-linux-gnu:/opt/ros/galactic/lib
> ```

### Write Rclex code

Now, you can acquire the environment for [Rclex API](https://hexdocs.pm/rclex/api-reference.html)! Of course, you can execute APIs on IEx directly.

Here is the simplest implementation example `lib/rclex_usage_on_nerves.ex` that will publish the string to `/chatter` topic.

```elixir
defmodule RclexUsageOnNerves do
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
- [b5g-ex/rclex_on_nerves](https://github.com/b5g-ex/rclex_on_nerves)

### Create fw, and burn (or, upload)

```
mix firmware
mix burn # or, mix upload
```

### Execute

Connect the Nerves device via ssh.

```
ssh nerves.local
```

Operate the following command on IEx.

```
iex()> RclexUsageOnNerves.publish_message
Rclex: Publishing: Hello World from Rclex!
:ok
```

You can confirm the above operation by subscribing with `ros2 topic echo` on the machine where ROS 2 env has been installed.

```
$ source /opt/ros/humble/setup.bash
$ ros2 topic echo /chatter std_msgs/msg/String
data: Hello World from Rclex!
---
```
