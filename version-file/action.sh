#!/bin/bash
VERSION_FILE=${1:-"pubspec.yaml"}

if [ ! -f "$VERSION_FILE" ]; then
	echo "::error::The version file '${VERSION_FILE}' does not exist."
	exit 1
fi

# Takes the first version in environment.flutter, so ranges resolve to their lower bound.
FLUTTER_VERSION=$(
	sed -nE '/^environment:/,/^[^[:space:]#]/ s/^[[:space:]]+flutter:[[:space:]]*//p' "$VERSION_FILE" |
	head -n 1 |
	tr -d "'\"\r" |
	sed -E 's/#.*//; s/^[[:space:]~><=v^]+//; s/[[:space:]><].*$//'
)

if [ -z "$FLUTTER_VERSION" ]; then
	echo "::error::Failed to find an 'environment.flutter' version in '${VERSION_FILE}'."
	exit 1
fi

if [ "$FLUTTER_VERSION" == "any" ]; then
	FLUTTER_VERSION="latest"
fi

echo "Resolved Flutter SDK version from '${VERSION_FILE}': ${FLUTTER_VERSION}"

if [ -n "$GITHUB_OUTPUT" ]; then
	echo "version=${FLUTTER_VERSION}" >> "$GITHUB_OUTPUT"
fi
