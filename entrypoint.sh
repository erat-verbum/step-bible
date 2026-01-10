#!/bin/bash

# Clean up any existing X11 locks to prevent conflicts
rm -f /tmp/.X99-lock
rm -f /tmp/.X11-unix/X99

# Start the virtual framebuffer (Xvfb) in the background
# Using display :99 as configured in the application
echo "Starting Xvfb on display :99..."
Xvfb :99 -screen 0 1280x720x16 -nolisten tcp &

# Set the DISPLAY environment variable to point to the virtual screen
export DISPLAY=:99

# Give Xvfb a moment to initialize before starting the app
sleep 2

# Ensure the .sword directory exists and has the correct permissions
mkdir -p /home/step/.sword
chmod -R 777 /home/step/.sword

# Start the application in the foreground
# Using exec to make it the main process (Docker best practice)
# Set step.jetty=true to force desktop mode and bypass server security restrictions
echo "Starting STEP application..."

# Export Java options using the proper INSTALL4J_ADD_VM_PARAMS method
export INSTALL4J_ADD_VM_PARAMS="-Dstep.jetty=true -Dapp.desktop=true -Dstep.desktop=true"

# Start the application
exec /opt/step/step-install4j
