## About

This [GitHub Action]() installs and sets up of a Flutter SDK for use in actions by:

* Downloading the Flutter SDK
* Adding the `flutter` command and `dart` command to path

[![Flutter](https://github.com/flutter-actions/setup-flutter/actions/workflows/dart.yml/badge.svg)](https://github.com/flutter-actions/setup-flutter/actions/workflows/dart.yml)

## Inputs

The action takes the following inputs:
  * `channel`: (Required) A release channel, which will install the latest build from that channel.
    Available channels are `stable`, `beta`. See
    https://flutter.dev/docs/development/tools/sdk/releases for details.

  * `version`: (Required) A specific SDK version, e.g. `latest` or `3.0.2` or `3.1.0-9.0.pre`

  * `cache`: (Optional) Enable cache of the pub dependencies. Default: false

  * `cache-sdk`: (Optional) Enable cache of the installed Flutter SDK. Default: false

  * `cache-key`: (Optional) An explicit key for restoring and saving the pub dependencies to/from cache

## Basic example

Install the latest stable SDK, and run Hello World.

```yml
name: Flutter

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Setup Flutter SDK
        uses: flutter-actions/setup-flutter@v3
        with:
          channel: stable
          version: 3.0.2

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze project source
        run: dart analyze

      - name: Run tests
        run: flutter test
```

Working with Android project:

```yml
name: Flutter for Android

on:
  push:
    branches: [ master ]
  pull_request:
    branches: [ master ]

jobs:
  build:
    runs-on: ubuntu-latest

    steps:
      - uses: actions/checkout@v4

      - name: Set up JDK 21
        uses: actions/setup-java@v4
        with:
          java-version: 21
          distribution: 'temurin'

      - name: Setup Android SDK
        uses: android-actions/setup-android@v3

      - name: Setup Flutter SDK
        uses: flutter-actions/setup-flutter@v3
        with:
          channel: stable
          version: 3.0.2

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze project source
        run: dart analyze

      - name: Run tests
        run: flutter test
```

## Troubleshooting

### Apple Silicon

If you are running this on `self-hosted` runner specially with Apple Silicon Mac only Flutter SDK v3.0.0 or later are supported.

For more information plase check https://docs.flutter.dev/get-started/install/macos.

## Using outside of GitHub Actions environment

This action is designed to be used in GitHub Actions environment. If you want to use it outside of GitHub Actions, you can use the following script:

```bash
# Usage:
#     curl -fsSL https://raw.githubusercontent.com/flutter-actions/setup-flutter/main/install.sh | bash -s -- <version> <channel>
# 
# Example:
curl -fsSL https://raw.githubusercontent.com/flutter-actions/setup-flutter/main/install.sh | bash -s -- 3.0.2 stable
```

# License

See the [`LICENSE`](LICENSE) file.
