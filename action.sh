#!/bin/bash

# Options
ARCH=$(echo "${RUNNER_ARCH:-x64}" | awk '{print tolower($0)}')
OS=$(echo "${RUNNER_OS:-linux}" | awk '{print tolower($0)}')

# Args
FLUTTER_VERSION=${1:-"latest"}
FLUTTER_CHANNEL=${2:-"stable"}
FLUTTER_OS=$OS

# Detect the latest version
if [[ $FLUTTER_VERSION == "latest" ]]
then
	FLUTTER_RELEASE_MANIFEST_URL="https://storage.googleapis.com/flutter_infra_release/releases/releases_$OS.json"
	FLUTTER_RELEASE_MANIFEST_FILE="${RUNNER_TEMP}/flutter_release.json"
	echo "Detecting latest version..."
	if curl -fsSL "$FLUTTER_RELEASE_MANIFEST_URL" -o "$FLUTTER_RELEASE_MANIFEST_FILE";
	then
		CURRENT_RELEASE=$(jq -r ".current_release.${FLUTTER_CHANNEL}" "$FLUTTER_RELEASE_MANIFEST_FILE")
		FLUTTER_VERSION=$(jq -r ".releases | map(select(.hash == \"${CURRENT_RELEASE}\")) | .[0].version" "$FLUTTER_RELEASE_MANIFEST_FILE")
		rm "$FLUTTER_RELEASE_MANIFEST_FILE"
	else
		echo -e "::error::Failed to detect the latest version."
		exit 1
	fi
fi

# Apple Intel or Apple Silicon
if [[ $OS == "macos" && $ARCH == "arm64" && $FLUTTER_VERSION < 3.* ]]
then
	echo -e "::error::Flutter SDK version \"${FLUTTER_VERSION}\" is not supported on Apple Silicon. Please use version 3.0.0 or higher."
	exit 1
fi

# Flutter runner tool cache
# path: "${{ runner.tool_cache }}/flutter-${{ runner.os }}-${{ inputs.version }}-${{ runner.arch }}"
# key: flutter-action-setup-flutter-${{ runner.os }}-${{ inputs.version }}-${{ runner.arch }}
FLUTTER_RUNNER_TOOL_CACHE="${RUNNER_TOOL_CACHE}/flutter-${RUNNER_OS}-${FLUTTER_VERSION}-${RUNNER_ARCH}"

# Check if Flutter SDK already exists
# Otherwise download and install
# https://storage.googleapis.com/flutter_infra_release/releases/stable/macos/flutter_macos_arm64_3.0.2-stable.zip
FLUTTER_RELEASE_URL="https://storage.googleapis.com/flutter_infra_release/releases"

# OS archive file extension
EXT="zip"
if [[ $OS == "linux" ]]
then
	EXT="tar.xz"
fi

if [ ! -d "${FLUTTER_RUNNER_TOOL_CACHE}" ]; then
	FLUTTER_BUILD_OS=$FLUTTER_OS
	echo "Installing Flutter SDK version \"${FLUTTER_VERSION}\" from the ${FLUTTER_CHANNEL} channel on ${FLUTTER_OS}"

	# Linux
	# /stable    /linux/     flutter_linux_2.10.2-stable.tar.xz
	# /beta      /linux/     flutter_linux_3.1.0-9.0.pre-beta.tar.xz

	# macOS
	# /stable    /macos/     flutter_macos_3.0.2-stable.zip
	# /stable    /macos/     flutter_macos_arm64_3.0.2-stable.zip
	# /beta      /macos/     flutter_macos_arm64_3.1.0-9.0.pre-beta.zip
	# /beta      /macos/     flutter_macos_3.1.0-9.0.pre-beta.zip

	# Windows
	# /stable    /windows/   flutter_windows_3.0.2-stable.zip
	# /beta      /windows/   flutter_windows_3.1.0-9.0.pre-beta.zip

	# Apple Intel or Apple Silicon
	if [[ $OS == "macos" && $ARCH == "arm64" ]]
	then
		FLUTTER_BUILD_OS="macos_arm64"
	fi

	FLUTTER_BUILD="flutter_${FLUTTER_BUILD_OS}_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.${EXT}"
	FLUTTER_DOWNLOAD_URL="${FLUTTER_RELEASE_URL}/${FLUTTER_CHANNEL}/${FLUTTER_OS}/${FLUTTER_BUILD}"

	echo "Downloading ${FLUTTER_DOWNLOAD_URL}"

	# Download installation archive
	DOWNLOAD_PATH="/tmp/${FLUTTER_BUILD}"
	curl --connect-timeout 15 --retry 5 "$FLUTTER_DOWNLOAD_URL" > ${DOWNLOAD_PATH}

	# Prepare tool cache folder
	mkdir -p "${FLUTTER_RUNNER_TOOL_CACHE}"

	# Extracting installation archive
	if [[ $OS == linux ]]
	then
		tar -C "${FLUTTER_RUNNER_TOOL_CACHE}" -xf ${DOWNLOAD_PATH} > /dev/null
	else
		unzip ${DOWNLOAD_PATH} -d "${FLUTTER_RUNNER_TOOL_CACHE}" > /dev/null
	fi

	if [ $? -ne 0 ]; then
		echo -e "::error::Download failed! Please check passed arguments."
		exit 1
	fi
else
	echo "Cache restored Flutter SDK version \"${FLUTTER_VERSION}\" from the ${FLUTTER_CHANNEL} channel on ${FLUTTER_OS}"
fi

# Configure pub to use a fixed location.
echo "PUB_CACHE=${HOME}/.pub-cache" >> $GITHUB_ENV

# Update paths.
echo "${HOME}/.pub-cache/bin" >> $GITHUB_PATH
echo "${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin" >> $GITHUB_PATH

# Report success, and print version.
echo -e "Succesfully installed Flutter SDK:"
${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin/dart --version
${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin/flutter --version
