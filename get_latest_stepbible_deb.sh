#!/bin/bash

# Script to get the latest StepBible .deb download URL
# This script extracts the current version from the StepBible downloads page
# and constructs the download URL for the .deb package

set -e

# Fetch the downloads page and extract the current version
DOWNLOADS_PAGE=$(curl -s "https://www.stepbible.org/downloads.jsp")

# Extract the current version (format: XX_XX_XX)
CURRENT_VERSION=$(echo "$DOWNLOADS_PAGE" | grep -o "Current version for download is: [0-9_]*" | grep -o "[0-9_]*$")

if [ -z "$CURRENT_VERSION" ]; then
    echo "Error: Could not extract current version from downloads page" >&2
    exit 1
fi

# Construct the download URL
DEB_FILENAME="stepbible_${CURRENT_VERSION}.deb"
DEB_URL="https://downloads.stepbible.com/file/Stepbible/${DEB_FILENAME}"

# Output ONLY the URL so it can be used by the Dockerfile
echo "$DEB_URL"