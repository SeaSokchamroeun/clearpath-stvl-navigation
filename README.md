# Clearpath A200 with STVL Navigation

## Overview
Configuration for Clearpath Husky A200 with Spatio-Temporal Voxel Layer (STVL)
integrated into Nav2 for 3D obstacle detection using:
- Velodyne VLP-16 3D Lidar
- Intel RealSense D435 depth camera
- Hokuyo UST 2D Lidar

## Requirements
- ROS2 Humble
- Clearpath packages
- `ros-humble-spatio-temporal-voxel-layer`
- `ros-humble-topic-tools`

## Installation
```bash
sudo apt install ros-humble-spatio-temporal-voxel-layer
sudo apt install ros-humble-topic-tools

sudo cp nav2/nav2_stvl.yaml \
    /opt/ros/humble/share/clearpath_nav2_demos/config/a200/nav2.yaml
```

## Launch Instructions

### Terminal 1 — Simulation
```bash
ros2 launch clearpath_gz simulation.launch.py setup_path:=$HOME/clearpath
```

### Terminal 2 — TF Relay
```bash
ros2 run topic_tools relay /a200_1103/tf /tf
```

### Terminal 3 — TF Static Relay
```bash
ros2 run topic_tools relay /a200_1103/tf_static /tf_static
```

### Terminal 4 — Localization
```bash
ros2 launch clearpath_nav2_demos localization.launch.py \
  setup_path:=$HOME/clearpath/ use_sim_time:=true
```

### Terminal 5 — Nav2
```bash
ros2 launch clearpath_nav2_demos nav2.launch.py \
  setup_path:=$HOME/clearpath/ use_sim_time:=true
```

### Terminal 6 — RViz
```bash
ros2 launch clearpath_viz view_navigation.launch.py namespace:=a200_1103
```

## Verify STVL Working
```bash
ros2 param get /a200_1103/local_costmap/local_costmap stvl_layer.publish_voxel_map
ros2 topic hz /a200_1103/local_costmap/voxel_marked_cloud
```

## File Structure
