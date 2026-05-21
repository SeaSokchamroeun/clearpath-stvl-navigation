#!/bin/bash
# =============================================================================
# Husky A200 STVL Full Launch Script
# =============================================================================
# Usage:
#   chmod +x launch_stvl.sh
#   ./launch_stvl.sh
#
# This script launches all required components for STVL navigation:
#   1. Gazebo simulation
#   2. RViz2
#   3. Localization (AMCL)
#   4. TF relay (bridges /a200_1103/tf -> /tf)
#   5. TF static relay
#   6. Nav2 with STVL
# =============================================================================

SETUP_PATH="/home/rbt-roeun/clearpath/"
NAMESPACE="a200_1103"

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}   Husky A200 STVL Navigation Launch Script           ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""

# ── Terminal 1: Gazebo ───────────────────────────────────────────────────────
echo -e "${YELLOW}[1/6] Launching Gazebo simulation...${NC}"
gnome-terminal --title="1: Gazebo" -- bash -c "
  source /opt/ros/humble/setup.bash
  source $HOME/clearpath/setup.bash 2>/dev/null || true
  echo '[Gazebo] Starting...'
  ros2 launch clearpath_gz simulation.launch.py setup_path:=$HOME/clearpath
  exec bash" &

echo "      Waiting 30 seconds for Gazebo to fully load..."
sleep 30

# ── Terminal 2: RViz ─────────────────────────────────────────────────────────
echo -e "${YELLOW}[2/6] Launching RViz2...${NC}"
gnome-terminal --title="2: RViz" -- bash -c "
  source /opt/ros/humble/setup.bash
  source $HOME/clearpath/setup.bash 2>/dev/null || true
  echo '[RViz] Starting...'
  ros2 launch clearpath_viz view_navigation.launch.py namespace:=$NAMESPACE
  exec bash" &

sleep 5

# ── Terminal 3: Localization ─────────────────────────────────────────────────
echo -e "${YELLOW}[3/6] Launching Localization (AMCL)...${NC}"
gnome-terminal --title="3: Localization" -- bash -c "
  source /opt/ros/humble/setup.bash
  source $HOME/clearpath/setup.bash 2>/dev/null || true
  echo '[Localization] Starting...'
  ros2 launch clearpath_nav2_demos localization.launch.py \
    setup_path:=$SETUP_PATH use_sim_time:=true
  exec bash" &

echo "      Waiting 10 seconds for localization to start..."
sleep 10

# ── Terminal 4: TF relay ─────────────────────────────────────────────────────
echo -e "${YELLOW}[4/6] Launching TF relay (CRITICAL)...${NC}"
gnome-terminal --title="4: TF relay" -- bash -c "
  source /opt/ros/humble/setup.bash
  echo '[TF relay] Bridging /a200_1103/tf -> /tf'
  echo 'Ignore transient local durability warnings — they are harmless'
  ros2 run topic_tools relay /a200_1103/tf /tf
  exec bash" &

sleep 3

# ── Terminal 5: TF static relay ──────────────────────────────────────────────
echo -e "${YELLOW}[5/6] Launching TF static relay (CRITICAL)...${NC}"
gnome-terminal --title="5: TF static relay" -- bash -c "
  source /opt/ros/humble/setup.bash
  echo '[TF static relay] Bridging /a200_1103/tf_static -> /tf_static'
  ros2 run topic_tools relay /a200_1103/tf_static /tf_static
  exec bash" &

echo "      Waiting 5 seconds for TF relays to stabilize..."
sleep 5

# ── Terminal 6: Nav2 ─────────────────────────────────────────────────────────
echo -e "${YELLOW}[6/6] Launching Nav2 with STVL...${NC}"
gnome-terminal --title="6: Nav2 STVL" -- bash -c "
  source /opt/ros/humble/setup.bash
  source $HOME/clearpath/setup.bash 2>/dev/null || true
  echo '[Nav2] Starting with STVL config...'
  ros2 launch clearpath_nav2_demos nav2.launch.py \
    setup_path:=$SETUP_PATH use_sim_time:=true
  exec bash" &

echo ""
echo -e "${YELLOW}Waiting 20 seconds for Nav2 to fully activate...${NC}"
sleep 20

# ── Verification ─────────────────────────────────────────────────────────────
echo ""
echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}   Verification                                       ${NC}"
echo -e "${BLUE}======================================================${NC}"

# Check costmap lifecycle
LIFECYCLE=$(ros2 lifecycle get /$NAMESPACE/local_costmap/local_costmap 2>/dev/null)
if echo "$LIFECYCLE" | grep -q "active"; then
    echo -e "${GREEN}[OK]${NC} Costmap lifecycle: $LIFECYCLE"
else
    echo -e "${YELLOW}[WAIT]${NC} Costmap not active yet: $LIFECYCLE"
    echo "       Try setting 2D Pose Estimate in RViz2 first"
fi

# Check STVL plugins
PLUGINS=$(ros2 param get /$NAMESPACE/local_costmap/local_costmap plugins 2>/dev/null)
if echo "$PLUGINS" | grep -q "stvl_layer"; then
    echo -e "${GREEN}[OK]${NC} STVL plugin loaded: $PLUGINS"
else
    echo -e "${YELLOW}[WARN]${NC} STVL plugin check: $PLUGINS"
fi

# Check VLP-16
HZ=$(ros2 topic hz /$NAMESPACE/sensors/lidar3d_0/points --window 5 2>&1 | grep "average rate" | head -1)
if [ -n "$HZ" ]; then
    echo -e "${GREEN}[OK]${NC} VLP-16 publishing: $HZ"
else
    echo -e "${YELLOW}[WARN]${NC} VLP-16 not detected yet"
fi

echo ""
echo -e "${BLUE}======================================================${NC}"
echo -e "${BLUE}   Next Steps                                         ${NC}"
echo -e "${BLUE}======================================================${NC}"
echo ""
echo "  1. In RViz2: click '2D Pose Estimate' and click on the map"
echo "     where the robot is to initialize localization"
echo ""
echo "  2. Verify STVL is working:"
echo "     ros2 lifecycle get /$NAMESPACE/local_costmap/local_costmap"
echo "     → must show: active [3]"
echo ""
echo "     ros2 topic hz /$NAMESPACE/local_costmap/voxel_grid"
echo "     → must show: ~50 Hz"
echo ""
echo "  3. In RViz2 add visualization:"
echo "     Add → By display type → PointCloud2"
echo "     Topic: /$NAMESPACE/local_costmap/voxel_grid"
echo "     Style: Boxes, Size: 0.05"
echo ""
echo "  4. Send a navigation goal:"
echo "     Click '2D Nav Goal' in RViz2 and click on the warehouse floor"
echo ""
