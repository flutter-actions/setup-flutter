#!/bin/bash
cd "$(dirname "$0")" || exit 1
TEST_DIR=$(mktemp -d)
trap 'rm -rf "$TEST_DIR"' EXIT
FAILED=0

# Usage: expect <expected version, or "error"> <environment.flutter line(s)>
expect() {
	local expected=$1
	printf 'name: example\nenvironment:\n  sdk: ^3.6.0\n%s\ndependencies:\n  flutter:\n    sdk: flutter\n' "$2" > "$TEST_DIR/pubspec.yaml"
	: > "$TEST_DIR/output"

	if GITHUB_OUTPUT="$TEST_DIR/output" ./action.sh "$TEST_DIR/pubspec.yaml" > /dev/null; then
		local actual
		actual=$(sed -n 's/^version=//p' "$TEST_DIR/output")
	else
		local actual="error"
	fi

	if [ "$actual" == "$expected" ]; then
		echo "ok: '$2' -> $actual"
	else
		echo "FAIL: '$2' -> $actual, expected $expected"
		FAILED=1
	fi
}

expect "3.27.0" "  flutter: 3.27.0"
expect "3.27.0" "  flutter: '3.27.0'"
expect "3.27.0" '  flutter: "3.27.0"'
expect "3.27.0" "  flutter: ^3.27.0"
expect "3.27.0" "  flutter: '>=3.27.0 <4.0.0'"
expect "3.27.0" "  flutter: 3.27.0 # pinned"
expect "3.27.0-0.1.pre" "  flutter: 3.27.0-0.1.pre"
expect "latest" "  flutter: any"
expect "error" ""

if ./action.sh "$TEST_DIR/missing.yaml" > /dev/null; then
	echo "FAIL: missing file did not error"
	FAILED=1
else
	echo "ok: missing file -> error"
fi

exit $FAILED
