# Use on Nerves

`rclex` can be operated onto Nerves. In this case, you do not need to prepare the ROS 2 environment on the host computer to build Nerves project (so awesome!).

This doc shows the steps on how to use Rclex on Nerves from scratch.

We have also published the Nerves project that has been prepared and includes example code at [b5g-ex/rclex_on_nerves](https://github.com/b5g-ex/rclex_on_nerves). Please also refer to this repository. 
> #### Support Target {: .neutral }
>
> Currentry Rclex only support aarch64 for Nerves, following steps use rpi4 as an example.

## Preliminaries

During the procedure for Rclex on Nerves, the docker command is used to copy the necessary directory in `mix rclex.prep.ros2`.
Please install [Docker Desktop](https://docs.docker.com/desktop/) or [Docker Engine](https://docs.docker.com/engine/), and start it first.  
And also, Rclex on Nerves will deploy an docker container for arm64 arch. If you want to operate this project by Docker Engine on other platforms (x86_64), you need to install qemu as the follows: `sudo apt-get install qemu binfmt-support qemu-user-static`

It should be noted that do not perform the following steps inside a docker container.  
Once again, they can be operated even if ROS 2 is not installed on the host machine!

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

### Install rclex

`rclex` is [available in Hex](https://hex.pm/docs/publish).

You can install this package into your project
by adding `rclex` to your list of dependencies in `mix.exs`:

```elixir
  defp deps do
    [
      ...
      {:rclex, "~> 0.8.2"},
      ...
    ]
  end
```

After that, execute `mix deps.get` into the project repository.


```
mix deps.get
```

## Prepare ROS 2 resoures

The following command extracts the ROS 2 Docker image and copies resources required for Rclex to the Nerves file system.

```
export ROS_DISTRO=foxy
mix rclex.prep.ros2
```

## Configure ROS 2 message types you want to use

Rclex provides pub/sub based topic communication using the message type defined in ROS 2. Please refer [here](https://docs.ros.org/en/foxy/Concepts/About-ROS-Interfaces.html) for more details about message types in ROS 2.

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

## Write Rclex code

Now, you can acquire the environment for [Rclex API](https://hexdocs.pm/rclex/api-reference.html)! Of course, you can execute APIs on IEx directly.

Here is the simplest implementation example `lib/rclex_usage_on_nerves.ex` that will publish the string to `/chatter` topic.

```elixir
defmodule RclexUsageOnNerves do
  def publish_message do
    context = Rclex.rclexinit()
    {:ok, node} = Rclex.ResourceServer.create_node(context, 'talker')
    {:ok, publisher} = Rclex.Node.create_publisher(node, 'StdMsgs.Msg.String', 'chatter')

    msg = Rclex.Msg.initialize('StdMsgs.Msg.String')
    data = "Hello World from Rclex!"
    msg_struct = %Rclex.StdMsgs.Msg.String{data: String.to_charlist(data)}
    Rclex.Msg.set(msg, msg_struct, 'StdMsgs.Msg.String')

    IO.puts("Rclex: Publishing: #{data}")
    Rclex.Publisher.publish([publisher], [msg])

    Rclex.Node.finish_job(publisher)
    Rclex.ResourceServer.finish_node(node)
    Rclex.shutdown(context)
  end
end
```

Please also check the examples for Rclex.
- [rclex/rclex_examples](https://github.com/rclex/rclex_examples)
- [b5g-ex/rclex_on_nerves](https://github.com/b5g-ex/rclex_on_nerves)

## Create fw, and burn (or, upload)

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
{:ok, #Reference<0.2970499651.1284374532.3555>}
```

You can confirm the above operation by subscribing with `ros2 topic echo` on the machine where ROS 2 env has been installed.

```
$ source /opt/ros/foxy/setup.bash
$ ros2 topic echo /chatter std_msgs/msg/String
data: Hello World from Rclex!
---
```
