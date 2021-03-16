#!/bin/bash

# Parse SDK and version args
CHANNEL="${1:-stable}"
VERSION="${3:-2.0.2}"

# Parse OS Environment
OS="${2:-Linux}"
OS=$(echo "$OS" | awk '{print tolower($0)}')

echo "Installing Flutter SDK version \"${VERSION}\" from the ${CHANNEL} channel on ${OS}"

# OS archive file extension
EXT="zip"
if [[ $OS == linux ]]
then
  EXT="tar.xz"
fi

# Calculate download Url. Based on:
# https://flutter.dev/docs/development/tools/sdk/releases
PREFIX="https://storage.googleapis.com/flutter_infra/releases"
BUILD="flutter_${OS}_${VERSION}-${CHANNEL}.${EXT}"

URL="${PREFIX}/${CHANNEL}/${OS}/${BUILD}"
echo "Downloading ${URL}..."

# Download installation archive
curl --connect-timeout 15 --retry 5 "$URL" > "${HOME}/fluttersdk.${EXT}"

# Extracting installation archive
if [[ $OS == linux ]]
then
  tar -C "${RUNNER_TOOL_CACHE}" -xf "${HOME}/fluttersdk.${EXT}" > /dev/null
else
  unzip "${HOME}/fluttersdk.${EXT}" -d "${RUNNER_TOOL_CACHE}" > /dev/null
fi

if [ $? -ne 0 ]; then
  echo -e "::error::Download failed! Please check passed arguments."
  exit 1
fi
rm "${HOME}/fluttersdk.${EXT}"

# Update paths.
echo "${HOME}/.pub-cache/bin" >> $GITHUB_PATH
echo "${RUNNER_TOOL_CACHE}/flutter/bin" >> $GITHUB_PATH

# Report success, and print version.
echo -e "Succesfully installed Flutter SDK:"
${RUNNER_TOOL_CACHE}/flutter/bin/dart --version
${RUNNER_TOOL_CACHE}/flutter/bin/flutter --version
