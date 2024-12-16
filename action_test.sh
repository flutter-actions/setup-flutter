#!/bin/bash
export ACTION_TEST_DIR="$(pwd)/.setup-flutter"

# Runner environment variables
export RUNNER_TOOL_CACHE="$ACTION_TEST_DIR/tool_cache"
export RUNNER_TEMP="$ACTION_TEST_DIR/temp"
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
export FLUTTER_RELEASE_URL="http://localhost:9876/releases"
exec ./action.sh "$@"
