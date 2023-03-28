# Circle Access Lock

A Flutter package to handle access lock using a Circle Technology. This package provides a simple way to present a Lock Screen to the user and control access.

## Features

- Easy integration with your Flutter app
- Configurable time constraints
- Keep in mind that the default time constraint (demo) is 10 minutes
- Once you sign in, the lock screen will not be triggered for the next 10 minutes
- Our customers can customize it to be all time, 1 minute, 1 hour, 1 day, etc.
- Enable/disable the access lock

## Installation

To use the Circle Access Lock package, add it as a dependency in your `pubspec.yaml` file:

```yaml
dependencies:
circle_access_lock: ^1.0.6
```

Then, run `flutter pub get` to download the package.

## Usage

1. Import the package in your Dart file:

```dart
import 'package:circle_access_lock/circle_access_lock.dart';
```

2. Initialize the `CircleAccessLock` in your widget:

```dart
import 'package:circle_access_lock/circle_access_lock.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MyHomePage(title: 'Flutter Demo Home Page');
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  final navigatorKey = GlobalKey<NavigatorState>();
  late CircleAccessLock circleAccessLock;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      circleAccessLock = CircleAccessLock(navigatorKey: navigatorKey);
      // you can use forceCheck to check on demand
      circleAccessLock.forceCheck();
    });
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return  MaterialApp(
        navigatorKey: navigatorKey,
        title: 'Flutter Demo',
        theme: ThemeData(
          primarySwatch: Colors.blue,
        ),
        home: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(

            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                const Text(
                  'You have pushed the button this many times:',
                ),
                Text(
                  '$_counter',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: _incrementCounter,
            tooltip: 'Increment',
            child: const Icon(Icons.add),
          ),
        )
    );
  }
}

```

3. Use the `enable` and `disable` methods to control the access lock:

```dart

circleAccessLock.enable();
circleAccessLock.disable();

```


34. if you need, you can use `forceCheck` to check on demand:

```dart

circleAccessLock.forceCheck();

```

## License

This project is licensed under the MIT License.
