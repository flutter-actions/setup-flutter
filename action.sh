#!/bin/bash
OS=$(echo "${RUNNER_OS:-linux}")
ARCH=$(echo "${RUNNER_ARCH:-x64}")

# Action inputs
FLUTTER_VERSION=${1:-"latest"}
FLUTTER_CHANNEL=${2:-"stable"}
FLUTTER_OS=$(echo "${OS}" | awk '{print tolower($0)}')
FLUTTER_ARCH=$(echo "${ARCH}" | awk '{print tolower($0)}')
FLUTTER_RELEASE_URL=${FLUTTER_RELEASE_URL:-"https://storage.googleapis.com/flutter_infra_release/releases"}

# Automatically determine the latest Flutter SDK version via the release manifest
if [[ $FLUTTER_VERSION == "latest" ]]; then
	# Flutter SDK release manifest
	FLUTTER_RELEASE_MANIFEST_URL="${FLUTTER_RELEASE_URL}/releases_${FLUTTER_OS}.json"
	FLUTTER_RELEASE_MANIFEST_FILE="${RUNNER_TEMP}/releases_${FLUTTER_OS}.json"

	echo "You have selected to install the latest Flutter SDK version (${FLUTTER_CHANNEL}) on \"${FLUTTER_OS}_${FLUTTER_ARCH}\"."
	echo "Attempting to determine the latest Flutter SDK version..."
	echo "Fetching Flutter SDK release manifest..."
	curl --silent --connect-timeout 15 --retry 5 "$FLUTTER_RELEASE_MANIFEST_URL" -o "$FLUTTER_RELEASE_MANIFEST_FILE"
	if [ $? -ne 0 ]; then
		echo -e "::error::Failed to fetch Flutter SDK release manifest."
		exit 1
	fi
	if [ -f "$FLUTTER_RELEASE_MANIFEST_FILE" ]; then
		__FLUTTER_CURRENT_RELEASE=$(jq -r ".current_release.${FLUTTER_CHANNEL}" "$FLUTTER_RELEASE_MANIFEST_FILE")
		__QUERY="select(.hash == \"${__FLUTTER_CURRENT_RELEASE}\" and .dart_sdk_arch == \"${ARCH}\")"
		FLUTTER_VERSION=$(jq -r ".releases | map(${__QUERY}) | .[0].version" "$FLUTTER_RELEASE_MANIFEST_FILE")
		if [ -z "$FLUTTER_VERSION" ]; then
			echo -e "::error::Failed to determine the latest Flutter SDK version."
			exit 1
		fi
		echo "Found the latest Flutter SDK version: ${FLUTTER_VERSION}"
	else
		echo -e "::error::Failed to determine the latest Flutter SDK version."
		exit 1
	fi
fi

# Strip 'v' prefix from the version
if [[ $FLUTTER_VERSION == v* ]]
then
	FLUTTER_VERSION=$(echo $FLUTTER_VERSION | sed 's/^v//')
fi

# Fix Flutter SDK version for Apple Silicon
FLUTTER_BUILD_OS=$FLUTTER_OS
if [[ $OS == "macos" && $ARCH == "arm64" ]]; then
	if [[ $FLUTTER_VERSION < 3.* ]]; then
		echo -e "::error::Flutter SDK version \"${FLUTTER_VERSION}\" is not supported on Apple Silicon. Please use version 3.0.0 or higher."
		exit 1
	fi

	FLUTTER_BUILD_OS="macos_arm64"
	echo "Apple Silicon detected, using \"${FLUTTER_BUILD_OS}\" build!"
fi

# OS archive file extension
EXT="zip"
if [[ $OS == "linux" ]]
then
	EXT="tar.xz"
fi

# Construct Flutter SDK build artifact URL
#   ---------- Linux ----------
#   /stable    /linux/     flutter_linux_2.10.2-stable.tar.xz
#   /beta      /linux/     flutter_linux_3.1.0-9.0.pre-beta.tar.xz
#   ---------- macOS ----------
#   /stable    /macos/     flutter_macos_3.0.2-stable.zip
#   /stable    /macos/     flutter_macos_arm64_3.0.2-stable.zip
#   /beta      /macos/     flutter_macos_arm64_3.1.0-9.0.pre-beta.zip
#   /beta      /macos/     flutter_macos_3.1.0-9.0.pre-beta.zip
#   ---------- Windows ----------
#   /stable    /windows/   flutter_windows_3.0.2-stable.zip
#   /beta      /windows/   flutter_windows_3.1.0-9.0.pre-beta.zip
FLUTTER_BUILD_ARTIFACT_ID="flutter_${FLUTTER_BUILD_OS}_${FLUTTER_VERSION}-${FLUTTER_CHANNEL}.${EXT}"
FLUTTER_BUILD_ARTIFACT_URL=${FLUTTER_BUILD_ARTIFACT_URL:-"${FLUTTER_RELEASE_URL}/${FLUTTER_CHANNEL}/${FLUTTER_OS}/${FLUTTER_BUILD_ARTIFACT_ID}"}

# Flutter runner tool cache and pub cache
#   Ref: https://github.com/flutter-actions/setup-flutter/pull/11
# FLUTTER_RUNNER_TOOL_CACHE=${{ runner.tool_cache }}/flutter-${{ runner.os }}-${{ inputs.version }}-${{ runner.arch }}-${{ inputs.channel }}
# FLUTTER_PUB_CACHE=${{ runner.temp }}/pub-cache
FLUTTER_RUNNER_TOOL_CACHE="${RUNNER_TOOL_CACHE}/flutter/${FLUTTER_BUILD_ARTIFACT_ID}"
FLUTTER_PUB_CACHE="${RUNNER_TEMP}/flutter/pub-cache"

# Check if Flutter SDK already exists, otherwise download and install
if [ ! -d "${FLUTTER_RUNNER_TOOL_CACHE}" ]; then
	echo "Installing Flutter SDK version: ${FLUTTER_VERSION} (${FLUTTER_CHANNEL}) on \"${FLUTTER_OS}_${FLUTTER_ARCH}\" ..."

	# Download Flutter SDK build artifact
	echo "Downloading ${FLUTTER_BUILD_ARTIFACT_URL}"
	FLUTTER_BUILD_ARTIFACT_FILE="${RUNNER_TEMP}/${FLUTTER_BUILD_ARTIFACT_ID}"
	curl --connect-timeout 15 --retry 5 -C - -o "${FLUTTER_BUILD_ARTIFACT_FILE}" "$FLUTTER_BUILD_ARTIFACT_URL"
	if [ $? -ne 0 ]; then
		echo -e "::error::Download failed! Please check passed arguments."
		exit 1
	fi

	# Prepare runner tool cache
	mkdir -p "${FLUTTER_RUNNER_TOOL_CACHE}"

	# Extracting installation archive
	echo -n "Extracting Flutter SDK archive..."
	if [[ $OS == linux ]]
	then
		tar -C "${FLUTTER_RUNNER_TOOL_CACHE}" -xf ${FLUTTER_BUILD_ARTIFACT_FILE} >/dev/null
		EXTRACT_ARCHIVE_CODE=$?
	else
		unzip ${FLUTTER_BUILD_ARTIFACT_FILE} -d "${FLUTTER_RUNNER_TOOL_CACHE}" >/dev/null
		EXTRACT_ARCHIVE_CODE=$?
	fi
	if [ $EXTRACT_ARCHIVE_CODE -eq 0 ]; then
		echo ": OK"
	else
		echo -e "::error::Failed to extract Flutter SDK archive."
		exit 1
	fi
else
	echo "Cache restored Flutter SDK version: ${FLUTTER_VERSION} (${FLUTTER_CHANNEL}) on \"${FLUTTER_OS}_${ARCH}\""
fi

# Configure pub to use a fixed location.
echo "PUB_CACHE=${FLUTTER_PUB_CACHE}" >> $GITHUB_ENV
mkdir -p $FLUTTER_PUB_CACHE

# Update paths.
echo "${FLUTTER_PUB_CACHE}/bin" >> $GITHUB_PATH
echo "${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin" >> $GITHUB_PATH

# Invoke Flutter SDK to suppress the analytics.
${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin/flutter --version --suppress-analytics 2>&1 >/dev/null

# Disable Google Analytics and CLI animations
${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin/flutter config --no-analytics 2>&1 >/dev/null
${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin/flutter config --no-cli-animations 2>&1 >/dev/null

# Report success, and print version.
echo "Succesfully installed Flutter SDK:"
echo "------------------------------------------------------------------------------"
${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin/dart --version
${FLUTTER_RUNNER_TOOL_CACHE}/flutter/bin/flutter --version
