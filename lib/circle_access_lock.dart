/// A Dart package to add a Circle Access Lock to a Flutter application.
library circle_access_lock;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

/// A class that manages the Circle Access Lock.
class CircleAccessLock {
  final GlobalKey<NavigatorState> navigatorKey;
  bool isEnabled;
  final bool isTest;

  /// Constructor for CircleAccessLock.
  ///
  /// [navigatorKey] is a required GlobalKey<NavigatorState>.
  /// [isTest] is an optional flag, defaulting to false.
  CircleAccessLock({required this.navigatorKey, this.isTest = false})
      : isEnabled = true {
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == AppLifecycleState.resumed.toString()) {
        await _presentWebViewController();
      }
      return;
    });

    if (isTest) {
      _presentWebViewController();
    }
  }

  /// Enables the Circle Access Lock.
  void enable() {
    isEnabled = true;
  }

  /// Disables the Circle Access Lock.
  void disable() {
    isEnabled = false;
  }

  /// Forces a check for Circle Access Lock.
  void forceCheck() {
    _presentWebViewController();
  }

  /// Presents the WebViewController for Circle Access Lock.
  Future<void> _presentWebViewController() async {
    if (!isEnabled) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = await CircleViewController.getLastTime();
    final maxTime = await CircleViewController.getMaxTime();

    if ((now - lastTime).abs() > maxTime) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(
            builder: (context) => const CircleViewController(),
            fullscreenDialog: true),
      );
    }
  }
}

/// A StatefulWidget that displays the Circle Access Lock interface.
class CircleViewController extends StatefulWidget {
  static const defaultUrl = 'https://unic-auth.web.app/circlebrowser/';

  const CircleViewController({super.key});

  @override
  State<CircleViewController> createState() => _CircleViewControllerState();

  /// Retrieves the saved URL from SharedPreferences.
  static Future<String> getSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('savedUrl') ?? defaultUrl;
  }

  /// Saves the URL to SharedPreferences.
  static Future<void> saveUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedUrl', Uri.decodeFull(url));
  }

  /// Retrieves the last saved time from SharedPreferences.
  static Future<int> getLastTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastTime') ?? 0;
  }

  /// Saves the time to SharedPreferences.
  static Future<void> saveTime(int time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastTime', time);
  }

  /// Retrieves the max time from SharedPreferences.
  static Future<int> getMaxTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('maxTime') ?? (10 * 60 * 1000); // 10 min default
  }

  /// Saves the max time to SharedPreferences.
  static Future<void> saveMaxTime(int time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('maxTime', time);
  }
}

/// The State object for CircleViewController.
class _CircleViewControllerState extends State<CircleViewController> {
  late WebViewController _webViewController;
  bool _isLoading = true;

  /// Initializes the state object and the webview controller.
  @override
  void initState() {
    super.initState();
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
            onNavigationRequest: (NavigationRequest request) async {
          final url = request.url;
          if (url.startsWith('circlebrowser://')) {
            if (url.startsWith('circlebrowser://save=')) {
              final parts = url
                  .substring('circlebrowser://save='.length)
                  .split('?max_time=');
              final baseUrl = parts[0];
              final maxTime = parts.length > 1 ? parts[1] : null;

              await CircleViewController.saveUrl(baseUrl);

              if (maxTime != null) {
                await CircleViewController.saveMaxTime(int.parse(maxTime));
              }

              _showSavedAlert(url: Uri.decodeFull(baseUrl));
            } else if (url == 'circlebrowser://dismiss') {
              _callDismiss();
            }
            return NavigationDecision.prevent;
          }
          return NavigationDecision.navigate;
        }, onPageStarted: (_) {
          setState(() {
            _isLoading = true;
          });
        }, onPageFinished: (_) {
          setState(() {
            _isLoading = false;
          });
        }),
      );

    _loadInitialContent();
  }

  void _loadInitialContent() async {
    final url = await CircleViewController.getSavedUrl();
    _navigateTo(url);
  }

  /// Builds the main view of the Circle Access Lock screen.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Circle Access Lock'),
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _navigateTo(CircleViewController.defaultUrl);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _webViewController),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(),
            ),
          GestureDetector(
            onTap: () {},
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
          )
        ],
      ),
    );
  }

  void _callDismiss() async {
    final now = DateTime.now().millisecondsSinceEpoch;
    await CircleViewController.saveTime(now);
    if (mounted) {
      Navigator.pop(context);
    }
  }

  void _showSavedAlert({required String url}) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Configuration saved'),
        content: Text(
            'Your configuration has been saved successfully. You will be automatically redirected to the end-user login website to log in with your credentials.'),
      ),
    );

    Future.delayed(const Duration(seconds: 5)).then((value) {
      if (mounted) {
        Navigator.pop(context); // Dismiss alert
      }
      _navigateTo(url);
    });
  }

  void _navigateTo(String url) {
    _webViewController.loadRequest(Uri.parse(url));
  }
}
