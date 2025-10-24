#!/bin/bash
# Start the virtual framebuffer (Xvfb) in the background
Xvfb :99 -screen 0 1280x720x16 &

# Set the DISPLAY environment variable to point to the virtual screen
export DISPLAY=:99

# Give Xvfb a moment to initialize before starting the app
sleep 1

# Execute the application. 'exec' is used so that the application becomes
# the main process, which is a Docker best practice.
exec /opt/step/step-install4j
