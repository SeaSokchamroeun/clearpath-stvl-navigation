#!/bin/bash

# Source ROS 2 workspace
source /opt/ros/humble/setup.bash
source $HOME/clearpath_ws/install/setup.bash

# Launch Clearpath RViz visualization with namespace in the background
ros2 launch clearpath_manipulators moveit.launch.py setup_path:=$HOME/clearpath use_sim_time:=true &
sleep 3

python3  $HOME/clearpath_ws/src/hc10_motion_planner/hc10_motion_planner/move_scan.py &
sleep 3



