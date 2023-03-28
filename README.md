# Circle Access Lock

A Flutter package to handle access lock using a Circle Technology. This package provides a simple way to present a Lock Screen to the user and control access.

## Features

- Easy integration with your Flutter app
- Configurable time constraints
- Enable/disable the access lock

## Installation

To use the Circle Access Lock package, add it as a dependency in your `pubspec.yaml` file:

\```yaml
dependencies:
circle_access_lock: ^1.0.0
\```

Then, run `flutter pub get` to download the package.

## Usage

1. Import the package in your Dart file:

\```dart
import 'package:circle_access_lock/circle_access_lock.dart';
\```

2. Initialize the `CircleAccessLock` in your widget:

\```dart
class _MyHomePageState extends State<MyHomePage> {
late CircleAccessLock circleAccessLock;

@override
void initState() {
super.initState();
circleAccessLock = CircleAccessLock(context: context);
}
\```

3. Use the `enable` and `disable` methods to control the access lock:

\```dart
RaisedButton(
onPressed: () {
circleAccessLock.enable();
},
child: Text('Enable'),
),
RaisedButton(
onPressed: () {
circleAccessLock.disable();
},
child: Text('Disable'),
),
\```

## License

This project is licensed under the MIT License.
