#!/bin/bash

# Source ROS 2 workspace
source /opt/ros/humble/setup.bash
source $HOME/clearpath_ws/install/setup.bash

# Launch Clearpath simulation in the background
ros2 launch husky_a200_1103_gz simulation.launch.py &
sleep 3

python3 $HOME/clearpath_ws/src/husky_a200_1103_gz/worlds/move_robot.py &
sleep 3

# Launch Clearpath RViz visualization with namespace in the background
ros2 launch husky_a200_1103_viz view_navigation.launch.py namespace:=a200_1103 &
sleep 3

# Launch Clearpath Nav2 localization with custom map in the background
ros2 launch clearpath_nav2_demos localization.launch.py setup_path:=$HOME/clearpath/ use_sim_time:=true &

sleep 2

ros2 launch clearpath_nav2_demos nav2.launch.py setup_path:=$HOME/clearpath/ use_sim_time:=true

sleep 3

# Optional: wait for all background processes to finish
wait

