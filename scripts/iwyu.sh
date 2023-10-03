#!/bin/bash

# find src -name "*.c" -exec ./iwyu.sh {} \;

include-what-you-use \
-I"$HOME/.asdf/installs/erlang/26.0.2/usr/include" \
-I"/opt/ros/$ROS_DISTRO/include" \
-Xiwyu --max_line_length=100 \
-Xiwyu --quoted_includes_first \
-Xiwyu --no_comments \
"$1"
