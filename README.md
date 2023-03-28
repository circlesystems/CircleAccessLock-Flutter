# Circle Access Lock

A Flutter package to handle access lock using a Circle Technology. This package provides a simple way to present a Lock Screen to the user and control access.

## Features

- Easy integration with your Flutter app
- Configurable time constraints
- Enable/disable the access lock

## Installation

To use the Circle Access Lock package, add it as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
circle_access_lock: ^1.0.2
```

Then, run `flutter pub get` to download the package.

## Usage

1. Import the package in your Dart file:

```dart
import 'package:circle_access_lock/circle_access_lock.dart';
```

2. Initialize the `CircleAccessLock` in your widget:

```dart
import 'package:flutter/material.dart';
import 'package:circle_access_lock/circle_access_lock.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final navigatorKey = GlobalKey<NavigatorState>();
  final circleAccessLock = CircleAccessLock(navigatorKey: navigatorKey);

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
      home: Scaffold(
        body: Center(
          child: Text('Testing'),
          ),
        ),
      ),
    );
  }
}

```

3. Use the `enable` and `disable` methods to control the access lock:

```dart

circleAccessLock.enable();
circleAccessLock.disable();

```

## License

This project is licensed under the MIT License.
