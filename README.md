# setup-flutter

This [GitHub Action]() installs and sets up of a Flutter SDK for use in actions by:

* Downloading the Flutter SDK
* Adding the `flutter` command and `dart` command to path

## Inputs

The action takes the following inputs:
  * `sdk`: A release channel, which will install the latest build from that channel.
    Available channels are `stable`, `beta`, `dev`. See
    https://flutter.dev/docs/development/tools/sdk/releases for details.

  * `version`: A specific SDK version, e.g. `2.0.2` or `2.1.0-12.1.pre`

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
      - uses: actions/checkout@v2

      - name: Setup Flutter SDK
        uses: flutter-actions/setup-flutter@v1
        with:
          sdk: stable
          version: 2.0.2

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
      - uses: actions/checkout@v2

      - name: Set up JDK 1.8
        uses: actions/setup-java@v1
        with:
          java-version: 1.8

      - name: Setup Android SDK
        uses: android-actions/setup-android@v2

      - name: Setup Flutter SDK
        uses: flutter-actions/setup-flutter@v1
        with:
          sdk: stable
          version: 2.0.2

      - name: Install dependencies
        run: flutter pub get

      - name: Analyze project source
        run: dart analyze

      - name: Run tests
        run: flutter test
```


# License

See the [`LICENSE`](LICENSE) file.
