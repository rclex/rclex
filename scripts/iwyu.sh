#!/bin/bash

# find src -name "*.c" -exec ./iwyu.sh {} \;

include-what-you-use \
-I"$HOME/.asdf/installs/erlang/27.3.4.3/usr/include" \
-I"/opt/ros/$ROS_DISTRO/include/rcl" \
-I"/opt/ros/$ROS_DISTRO/include/rcutils" \
-I"/opt/ros/$ROS_DISTRO/include/rmw" \
-I"/opt/ros/$ROS_DISTRO/include/rcl_yaml_param_parser" \
-I"/opt/ros/$ROS_DISTRO/include/rosidl_runtime_c" \
-I"/opt/ros/$ROS_DISTRO/include/rosidl_typesupport_interface" \
-Xiwyu --max_line_length=100 \
-Xiwyu --quoted_includes_first \
-Xiwyu --no_comments \
"$1"
