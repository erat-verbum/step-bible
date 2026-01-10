FROM ubuntu:22.04

# Install all system dependencies, including tools for download and verification
# Added 'ca-certificates' for HTTPS downloads
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    openjdk-8-jdk \
    wget \
    xvfb \
    ca-certificates && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Create the non-root user
RUN useradd -m -s /bin/bash step

# Define the version and hash of StepBible to use
ARG STEP_VERSION=25_11_15
ARG STEP_HASH=7b8411f3d5c214c0de43575063f6f7ad2ce0e38aa0cb6f42d40cf845241a51c6

# Download and install the application package
RUN set -ex && \
    # Construct the download URL
    DEB_URL="https://downloads.stepbible.com/file/Stepbible/stepbible_${STEP_VERSION}.deb" && \
    # Download the package
    wget -q -O /tmp/step.deb "$DEB_URL" && \
    \
    # Verify the package hash
    echo "${STEP_HASH} /tmp/step.deb" | sha256sum -c - && \
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

# Compile and install the forwarded header filter
COPY config/ForwardedHeaderFilter.java /tmp/ForwardedHeaderFilter.java
RUN mkdir -p /opt/step/step-web/WEB-INF/classes/com/tyndalehouse/step/web && \
    javac -cp /opt/step/step-web/WEB-INF/lib/*:/opt/step/step.war/WEB-INF/lib/*:/opt/step/lib/tomcat-servlet-api-8.5.99.jar /tmp/ForwardedHeaderFilter.java -d /opt/step/step-web/WEB-INF/classes && \
    rm /tmp/ForwardedHeaderFilter.java

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
