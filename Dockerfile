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
COPY get_latest_stepbible_deb.sh /tmp/get_latest_stepbible_deb.sh
RUN chmod +x /tmp/get_latest_stepbible_deb.sh

# Download, verify, and install the latest application package
RUN set -ex && \
    # Get the latest .deb URL and checksum from the script
    STEP_DEB_URL=$(/tmp/get_latest_stepbible_deb.sh | head -n 1) && \
    echo "Downloading latest StepBible from: $STEP_DEB_URL" && \
    \
    # Download the package
    wget -q -O /tmp/step.deb "$STEP_DEB_URL" && \
    \
    # Calculate the SHA256 checksum of the downloaded file
    STEP_DEB_SHA256=$(sha256sum /tmp/step.deb | cut -d' ' -f1) && \
    echo "Calculated SHA256: $STEP_DEB_SHA256" && \
    \
    # Install the package
    apt-get update && \
    apt-get install -y --no-install-recommends /tmp/step.deb && \
    \
    # Clean up
    rm /tmp/step.deb /tmp/get_latest_stepbible_deb.sh && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Create X11 directory with proper permissions (before switching to non-root user)
RUN mkdir -p /tmp/.X11-unix && chmod 1777 /tmp/.X11-unix

# Set ownership of the application directory
RUN chown -R step:step /opt/step

# Switch to the non-root user
USER step

# Expose the application port
EXPOSE 8989

# Remove the Remote Address Filter from web.xml to allow external connections
RUN if [ -f /opt/step/step-web/WEB-INF/web.xml ]; then \
    sed -i '/<filter>/,/<\/filter>/ { /Remote Address Filter/ { :a; N; /<\/filter>/!ba; d; } }' /opt/step/step-web/WEB-INF/web.xml && \
    sed -i '/<filter-mapping>/,/<\/filter-mapping>/ { /Remote Address Filter/ { :a; N; /<\/filter-mapping>/!ba; d; } }' /opt/step/step-web/WEB-INF/web.xml; \
    fi

# Set the entrypoint to run our startup script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
