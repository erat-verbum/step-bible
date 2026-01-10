FROM ubuntu:22.04

# Install all system dependencies, including tools for download and verification
# Added 'ca-certificates' for HTTPS downloads and 'coreutils' for sha256sum
# Also add curl for fetching the latest version
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    wget \
    psmisc \
    xvfb \
    ca-certificates \
    coreutils \
    curl && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Create the non-root user
RUN useradd -m -s /bin/bash step

# Copy the script to get the latest StepBible .deb URL
COPY scripts/get_latest_stepbible_deb.sh /tmp/get_latest_stepbible_deb.sh
RUN chmod +x /tmp/get_latest_stepbible_deb.sh

# Download and install the latest application package
RUN set -ex && \
    # Get the latest deb URL
    DEB_URL=$(/tmp/get_latest_stepbible_deb.sh) && \
    # Download the package
    wget -q -O /tmp/step.deb "$DEB_URL" && \
    \
    # Install the package
    apt-get update && \
    apt-get install -y --no-install-recommends /tmp/step.deb && \
    \
    # Clean up
    rm /tmp/step.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the entrypoint script and make it executable
COPY scripts/entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Copy the modified web.xml to allow network access
COPY config/web.xml.network /opt/step/step.war/WEB-INF/web.xml
COPY config/web.xml.network /opt/step/step-web/WEB-INF/web.xml

# Copy the modified properties file to force desktop mode (bypass server security)
COPY config/step.web.properties.network /opt/step/step-web/WEB-INF/classes/step.web.properties

# Create X11 directory with proper permissions (before switching to non-root user)
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Set ownership of the application directory
RUN chown -R step:step /opt/step

# Switch to the non-root user
USER step

# Expose the application port
EXPOSE 8989

# Note: Using embedded Tomcat, no need for manual web.xml modifications
# or symbolic link creation. The application handles deployment internally.

# Set the entrypoint to run our startup script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
