#!/bin/bash

# Parse SDK and version args
CHANNEL="${1:-stable}"
VERSION="${3:-2.0.2}"

# Parse OS Environment
OS="${2:-Linux}"
OS=$(echo "$OS" | awk '{print tolower($0)}')

# OS archive file extension
EXT="zip"
if [[ $OS == linux ]]
then
  EXT="tar.xz"
fi

# Flutter runner tool cache
FLUTTER_RUNNER_TOOL_CACHE="${RUNNER_TOOL_CACHE}/${VERSION}-${CHANNEL}"

# Check if Flutter SDK already exists
# Otherwise download and install
if [ ! -d "${FLUTTER_RUNNER_TOOL_CACHE}" ]; then
  echo "Installing Flutter SDK version \"${VERSION}\" from the ${CHANNEL} channel on ${OS}"

  # Calculate download Url. Based on:
  # https://flutter.dev/docs/development/tools/sdk/releases
  PREFIX="https://storage.googleapis.com/flutter_infra_release/releases"
  BUILD="flutter_${OS}_${VERSION}-${CHANNEL}.${EXT}"

  URL="${PREFIX}/${CHANNEL}/${OS}/${BUILD}"
  echo "Downloading ${URL}..."

  # Download installation archive
  curl --connect-timeout 15 --retry 5 "$URL" > "/tmp/${BUILD}"

  # Prepare tool cache folder
  mkdir -p "${FLUTTER_RUNNER_TOOL_CACHE}"

  # Extracting installation archive
  if [[ $OS == linux ]]
  then
    tar -C "${FLUTTER_RUNNER_TOOL_CACHE}" -xf "/tmp/${BUILD}" > /dev/null
  else
    unzip "/tmp/${BUILD}" -d "${FLUTTER_RUNNER_TOOL_CACHE}" > /dev/null
  fi

  if [ $? -ne 0 ]; then
    echo -e "::error::Download failed! Please check passed arguments."
    exit 1
  fi
fi

echo "Installed Flutter SDK version \"${VERSION}\"!"

# Configure pub to use a fixed location.
echo "PUB_CACHE=${HOME}/.pub-cache" >> $GITHUB_ENV

# Update paths.
echo "${HOME}/.pub-cache/bin" >> $GITHUB_PATH
echo "${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin" >> $GITHUB_PATH

# Report success, and print version.
echo -e "Succesfully installed Flutter SDK:"
${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin/dart --version
${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin/flutter --version
