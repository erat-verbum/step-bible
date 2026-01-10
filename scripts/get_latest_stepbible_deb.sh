#!/bin/bash

# Script to get the latest StepBible .deb download URL and its SHA256 hash
# This script extracts the current version from the StepBible downloads page,
# constructs the download URL, downloads the package, and calculates its hash.

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

# Download the package to a temporary file to calculate the hash
TEMP_DEB=$(mktemp)
curl -s -L -o "$TEMP_DEB" "$DEB_URL"

# Calculate the SHA256 hash
SHA256_HASH=$(sha256sum "$TEMP_DEB" | awk '{ print $1 }')

# Clean up
rm "$TEMP_DEB"

# Output the results
echo "Version: $CURRENT_VERSION"
echo "URL:     $DEB_URL"
echo "SHA256:  $SHA256_HASH"
