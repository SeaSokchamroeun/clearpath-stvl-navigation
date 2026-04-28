#!/bin/bash

# Source ROS 2 workspace
source /opt/ros/humble/setup.bash
source $HOME/clearpath_ws/install/setup.bash



ros2 launch husky_a200_1103_nav slam.launch.py use_sim_time:=false&

sleep 3

ros2 launch husky_a200_1103_nav localization.launch.py use_sime_time:=false map:=/home/yong-ann/s_map1.yaml &
sleep 3


# Optional: wait for all background processes to finish
wait
