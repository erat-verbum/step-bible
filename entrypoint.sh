#!/bin/bash
# Clean up any existing Xvfb lock files from previous runs
rm -f /tmp/.X99-lock

# Start the virtual framebuffer (Xvfb) in the background
Xvfb :99 -screen 0 1280x720x16 &

# Set the DISPLAY environment variable to point to the virtual screen
export DISPLAY=:99

# Give Xvfb a moment to initialize before starting the app
sleep 1

# Ensure the .sword directory exists and has the correct permissions
mkdir -p /home/step/.sword
chmod -R 777 /home/step/.sword

# Start the application in the foreground
# Using exec to make it the main process (Docker best practice)
exec /opt/step/step-install4j -Djava.net.preferIPv4Stack=true
