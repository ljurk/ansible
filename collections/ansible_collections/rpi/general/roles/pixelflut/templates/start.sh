#!/bin/bash

export DISPLAY=:0

# disable sleep
xset -dpms
xset s noblank
xset s off
# Start pixelnuke
/home/pi/pixelflut/pixelnuke/pixelnuke &
APP_PID=$!

# Wait for pixelnuke to start
wait $APP_PID

# Once pixelnuke has started, execute xdotool
/usr/bin/xdotool key F11
