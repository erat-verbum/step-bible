FROM ubuntu:22.04

# Define build-time arguments for the download URL and the expected SHA256 checksum
ARG STEP_DEB_URL=https://downloads.stepbible.com/file/Stepbible/stepbible_24_10_9.deb
ARG STEP_DEB_SHA256=f4548ab939022807239c4a2a501965174ee9c1819ead9a6c583bbcd82b9b4f72

ENV DEBIAN_FRONTEND=noninteractive
ENV JAVA_HOME /usr/lib/jvm/java-8-openjdk-amd64

# Install all system dependencies, including tools for download and verification
# Added 'ca-certificates' for HTTPS downloads and 'coreutils' for sha256sum
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        openjdk-8-jdk \
        wget \
        psmisc \
        xvfb \
        ca-certificates \
        coreutils && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create the non-root user
RUN useradd -m -s /bin/bash step

# Download, verify, and install the application package in a single layer
# This ensures that if the checksum fails, the build stops.
# It also cleans up the downloaded .deb file in the same layer to keep the image small.
RUN set -ex && \
    # Download the package
    wget -q -O /tmp/step.deb "${STEP_DEB_URL}" && \
    \
    # Verify the package checksum
    # Note the two spaces between the sum and the filename, as required by sha256sum
    echo "${STEP_DEB_SHA256}  /tmp/step.deb" | sha256sum -c - && \
    \
    # Install the verified package
    apt-get update && \
    apt-get install -y --no-install-recommends /tmp/step.deb && \
    \
    # Clean up
    rm /tmp/step.deb && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Copy the entrypoint script and make it executable
COPY entrypoint.sh /usr/local/bin/entrypoint.sh
RUN chmod +x /usr/local/bin/entrypoint.sh

# Set ownership of the application directory
RUN chown -R step:step /opt/step

# Switch to the non-root user
USER step

# Expose the application port
EXPOSE 8989

# Set the entrypoint to run our startup script
ENTRYPOINT ["/usr/local/bin/entrypoint.sh"]
