#!/bin/bash

# Source ROS 2 workspace
source /opt/ros/humble/setup.bash
source $HOME/clearpath_ws/install/setup.bash


#ros2 launch realsense2_camera rs_launch.py 

# Launch Clearpath RViz visualization with namespace in the background
ros2 launch crack_detection crack_detection.launch.py camera_topic:=/camera/camera/color/image_raw depth_topic:=/camera/camera/depth/image_rect_raw zoom_enabled:=true zoom_factor:=1.5 &
sleep 3


#ros2 launch crack_detection crack_detection.launch.py use_pix2pix:=true camera_topic:=/camera/camera/color/image_raw depth_topic:=/camera/camera/depth/image_rect_raw zoom_enabled:=true zoom_factor:=1.5 &
sleep 3

ros2 run rqt_image_view rqt_image_view /crack_detection/visualization&
sleep 3



