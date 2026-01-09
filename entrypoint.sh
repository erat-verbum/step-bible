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

# Add debugging information
echo "=== STEP Application Debug Info ==="
echo "Current user: $(whoami)"
echo "Java version: $(java -version 2>&1 | head -n 1)"
echo "Application path: /opt/step/step-install4j"
echo "Network interfaces:"
ip addr
echo "Listening ports before starting app:"
netstat -tlnp 2>/dev/null || ss -tlnp 2>/dev/null || echo "No netstat/ss available"

# Start the application in the foreground with additional Java options
# Using exec to make it the main process (Docker best practice)
# Add Java options to force binding to all interfaces and show port info
echo "Starting STEP application..."
exec /opt/step/step-install4j -Djava.net.preferIPv4Stack=true -Djava.rmi.server.hostname=0.0.0.0
