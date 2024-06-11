## About

This [GitHub Action] installs and sets up of a Flutter SDK for use in actions by:

* Downloading the Flutter SDK
* Adding the `flutter` command and `dart` command to path
* Support for caching the Flutter SDK and pub dependencies
* Support for automated publishing of packages to [Pub.dev]

[![Flutter SDK for Linux](https://github.com/flutter-actions/setup-flutter/actions/workflows/flutter-linux.yml/badge.svg)](https://github.com/flutter-actions/setup-flutter/actions/workflows/flutter-linux.yml)
[![Flutter SDK for macOS](https://github.com/flutter-actions/setup-flutter/actions/workflows/flutter-macos.yml/badge.svg)](https://github.com/flutter-actions/setup-flutter/actions/workflows/flutter-macos.yml)
[![Flutter SDK for macOS (Intel)](https://github.com/flutter-actions/setup-flutter/actions/workflows/flutter-macos-intel.yml/badge.svg)](https://github.com/flutter-actions/setup-flutter/actions/workflows/flutter-macos-intel.yml)
[![Flutter SDK for Windows](https://github.com/flutter-actions/setup-flutter/actions/workflows/flutter-windows.yml/badge.svg)](https://github.com/flutter-actions/setup-flutter/actions/workflows/flutter-windows.yml)

## Inputs

The action takes the following inputs:
  * `version`: (Required) A specific Flutter SDK version to install, e.g. `latest` or `3.0.2` or `3.1.0-9.0.pre`

  * `channel`: (Required) The Flutter SDK release channel to install.
    Available channels are `stable`, `beta`. See
    https://flutter.dev/docs/development/tools/sdk/releases for details.

  * `cache`: (Optional) Enable cache of the pub dependencies. Default: false

  * `cache-sdk`: (Optional) Enable cache of the installed Flutter SDK. Default: false

  * `cache-key`: (Optional) An explicit key for restoring and saving the pub dependencies to/from cache

## Basic example

Install the latest stable SDK, and run Hello World.

```yml
name: Flutter

on:
  push:

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

## Automated publishing of packages to [Pub.dev]

You can automated publishing of packages to [Pub.dev] from GitHub Actions by using the [flutter-actions/setup-pubdev-credentials] action.

```yml
# Setup Flutter SDK and automated pub.dev credentials
- uses: flutter-actions/setup-flutter@v3
- uses: flutter-actions/setup-pubdev-credentials@v1
```

## Automated job matrix across multiple version of Flutter SDK

You can automated job matrix across multiple version of **Flutter SDK** by using [flutter-actions/pubspec-matrix-action] action. This GitHub Action generates a matrix of **Dart** and **Flutter SDK** versions from a `pubspec.yaml` file.

<picture>
    <source srcset="https://github.com/flutter-actions/pubspec-matrix-action/blob/main/.github/assets/screenshot-dark.png"  media="(prefers-color-scheme: dark)">
    <img src="https://github.com/flutter-actions/pubspec-matrix-action/blob/main/.github/assets/screenshot-light.png">
</picture>

## Troubleshooting

### Apple Silicon

If you are running this on `self-hosted` runner specially with Apple Silicon Mac only Flutter SDK v3.0.0 or later are supported.

For more information plase check https://docs.flutter.dev/get-started/install/macos.

### Flutter uses Google Analytics

Starting from `flutter-actions/setup-flutter@v3`, the action will disable **Flutter SDK** built-in **Google Analytics** by default.

## Using outside of GitHub Actions environment

This action is designed to be used in GitHub Actions environment. If you want to use it outside of GitHub Actions, you can use the following script:

```bash
# Usage:
#     curl -fsSL https://raw.githubusercontent.com/flutter-actions/setup-flutter/main/install.sh | bash -s -- <version> <channel>
# 
# Example:

export SETUP_FLUTTER_BRANCH=main
curl -fsSL https://raw.githubusercontent.com/flutter-actions/setup-flutter/${SETUP_FLUTTER_BRANCH}/install.sh | bash -s -- 3.0.2 stable
```

## Alternatives

The [GitHub Actions for Flutter SDK] team also implemented an alternative action to Setup Flutter SDK using [Flutter Version Management] `fvm`. See [flutter-actions/setup-fvm] for more information.

**See also:**
- [subosito/flutter-action](https://github.com/subosito/flutter-action)

# License

Licensed under the [MIT License].

[MIT License]: https://github.com/flutter-actions/setup-flutter/blob/main/LICENSE
[GitHub Actions for Flutter SDK]: https://github.com/flutter-actions
[GitHub Action]: https://github.com/flutter-actions/setup-flutter
[Pub.dev]: https://pub.dev
[Flutter Version Management]: https://fvm.app/
[flutter-actions/setup-fvm]: https://github.com/flutter-actions/setup-fvm
[flutter-actions/setup-pubdev-credentials]: https://github.com/flutter-actions/setup-pubdev-credentials
[flutter-actions/pubspec-matrix-action]: https://github.com/flutter-actions/pubspec-matrix-action
