#!/bin/bash
export ACTION_TEST_DIR="$(pwd)/.test"

# Runner environment variables
export RUNNER_TOOL_CACHE="$ACTION_TEST_DIR/tool_cache"
export RUNNER_TEMP="$ACTION_TEST_DIR/temp"
export RUNNER_ARCH=$(uname -m)
export RUNNER_OS=$(uname -s | tr '[:upper:]' '[:lower:]')

if [ "$RUNNER_OS" = "darwin" ]; then
    export RUNNER_OS="macos"
fi

# GitHub Context
export GITHUB_ENV="$ACTION_TEST_DIR/.env"
export GITHUB_PATH="$ACTION_TEST_DIR/.path"

# Create mock environment
mkdir -p "$RUNNER_TOOL_CACHE" "$RUNNER_TEMP"

# Run the action
exec ./action.sh "$@"
