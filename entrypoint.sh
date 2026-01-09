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

echo "=== Checking web.xml configuration ==="
if [ -f /opt/step/step-web/WEB-INF/web.xml ]; then
    echo "web.xml found, checking for Remote Address Filter:"
    grep -n "Remote Address Filter" /opt/step/step-web/WEB-INF/web.xml || echo "No Remote Address Filter found (good)"
    echo "Checking for any filter configurations:"
    grep -n "<filter>" /opt/step/step-web/WEB-INF/web.xml | head -5
else
    echo "ERROR: web.xml not found at /opt/step/step-web/WEB-INF/web.xml"
fi

echo "=== Checking application properties ==="
if [ -f /opt/step/step-web/WEB-INF/classes/step.properties ]; then
    echo "step.properties found, showing relevant network settings:"
    grep -E "(port|host|bind|address)" /opt/step/step-web/WEB-INF/classes/step.properties || echo "No network-related properties found"
else
    echo "No step.properties file found"
fi

# Start the application in the foreground with additional Java options
# Using exec to make it the main process (Docker best practice)
# Add Java options to force binding to all interfaces and show port info
echo "Starting STEP application..."
exec /opt/step/step-install4j -Djava.net.preferIPv4Stack=true -Djava.rmi.server.hostname=0.0.0.0
