#!/bin/bash

testDir=`pwd`
root=$1
cd rclcpp
colcon build
source install/setup.bash
cd $root
echo $root
mix compile
mix run ros2_test/simple_pubsub_with_cpp/rclex/sub_test.exs &
sleep 1
cd $testDir
ros2 run cpp_pubsub talker &
wait
cppPub=`cat cpp_pub.txt`
exSub=`cat $root/ex_sub.txt`
test $cppPub = $exSub
result=$?
echo "published message : $cppPub"
echo "subscribed message : $exSub"
echo "result : $result"
if [ $result -ne 0 ]; then
    exit 1
fi 