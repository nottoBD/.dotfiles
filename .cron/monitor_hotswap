#!/bin/bash

LOGFILE="/tmp/monitor_hotswap_debug.log"
STATE_FILE="/tmp/monitor_hotswap_state"

echo "$(date): Starting monitor hotswap check" >> $LOGFILE

export DISPLAY=:0
export XAUTHORITY=/home/devid/.Xauthority
echo "After setting: DISPLAY=$DISPLAY, XAUTHORITY=$XAUTHORITY" >> $LOGFILE

# Get the current HDMI status and resolution
HDMI_STATUS=$(xrandr | grep "HDMI-1-0 connected")
RESOLUTION=$(xrandr | grep -A1 "HDMI-1-0 connected" | tail -n 1 | awk '{print $1}')

# Read previous state
PREVIOUS_STATE=""
if [ -f $STATE_FILE ]; then
    PREVIOUS_STATE=$(cat $STATE_FILE)
fi

# Create the current state string
CURRENT_STATE="HDMI_STATUS=${HDMI_STATUS},RESOLUTION=${RESOLUTION}"
echo "Current state: $CURRENT_STATE" >> $LOGFILE

# Compare current state with the previous state
if [ "$CURRENT_STATE" == "$PREVIOUS_STATE" ]; then
    echo "$(date): No change in monitor configuration. Exiting." >> $LOGFILE
    exit 0
fi

# Update the state file with the current state
echo "$CURRENT_STATE" > $STATE_FILE

# Apply monitor settings based on the detected resolution
if [ -n "$HDMI_STATUS" ]; then
    echo "HDMI is connected" >> $LOGFILE

    case "$RESOLUTION" in
        1680x1050)
            ~/.config/xrandr/top_down_1680x1050.sh
            echo "$(date): Applied top_down_1680x1050.sh" >> $LOGFILE
            ;;
        1920x1080)
            ~/.config/xrandr/top_down_1920x1080.sh
            echo "$(date): Applied top_down_1920x1080.sh" >> $LOGFILE
            ;;
        *)
            ~/.config/xrandr/defaults.sh
            echo "$(date): Applied defaults.sh" >> $LOGFILE
            ;;
    esac
else
    echo "HDMI is disconnected" >> $LOGFILE
    ~/.config/xrandr/defaults.sh
    echo "$(date): Applied defaults.sh for disconnection" >> $LOGFILE
    xrandr --output HDMI-1-0 --off
    echo "$(date): Turned off HDMI-1-0" >> $LOGFILE
fi

