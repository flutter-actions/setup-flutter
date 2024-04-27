#!/bin/bash
SETUP_FLUTTER_WORKDIR=${SETUP_FLUTTER_WORKDIR:-"$(pwd)/.setup-flutter"}

# Runner environment variables
export RUNNER_TOOL_CACHE="$SETUP_FLUTTER_WORKDIR/tool_cache"
export RUNNER_TEMP="$SETUP_FLUTTER_WORKDIR/temp"
export RUNNER_ARCH=$(uname -m)
export RUNNER_OS=$(uname -s | tr '[:upper:]' '[:lower:]')

if [ "$RUNNER_OS" = "darwin" ]; then
    export RUNNER_OS="macos"
fi

# GitHub Context
export GITHUB_ENV="$ACTION_TEST_DIR/.GITHUB_ENV"
export GITHUB_PATH="$ACTION_TEST_DIR/.GITHUB_PATH"

# Create mock environment
mkdir -p "$RUNNER_TOOL_CACHE" "$RUNNER_TEMP"
touch "$GITHUB_ENV" "$GITHUB_PATH"

# Run the action
curl -fsSL "https://raw.githubusercontent.com/flutter-actions/setup-flutter/main/action.sh" | bash -s -- "$@"
