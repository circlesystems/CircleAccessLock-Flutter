library circle_access_lock;

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';

class CircleAccessLock {
  final GlobalKey<NavigatorState> navigatorKey;
  bool isEnabled;
  final bool isTest;

  CircleAccessLock({required this.navigatorKey, this.isTest = false}) : isEnabled = true {
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

  void enable() {
    isEnabled = true;
  }

  void disable() {
    isEnabled = false;
  }

  void forceCheck() {
    _presentWebViewController();
  }

  Future<void> _presentWebViewController() async {
    if (!isEnabled) return;

    final now = DateTime.now().millisecondsSinceEpoch;
    final lastTime = await CircleViewController.getLastTime();
    final maxTime = await CircleViewController.getMaxTime();

    if ((now - lastTime).abs() > maxTime) {
      navigatorKey.currentState?.push(
        MaterialPageRoute(builder: (context) => const CircleViewController(), fullscreenDialog: true),
      );
    }
  }
}

class CircleViewController extends StatefulWidget {
  static const defaultUrl = 'https://unic-auth.web.app/circlebrowser/';

  const CircleViewController({super.key});

  @override
  State<CircleViewController> createState() => _CircleViewControllerState();

  static Future<String> getSavedUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('savedUrl') ?? defaultUrl;
  }

  static Future<void> saveUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('savedUrl', Uri.decodeFull(url));
  }

  static Future<int> getLastTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('lastTime') ?? 0;
  }

  static Future<void> saveTime(int time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastTime', time);
  }

  static Future<int> getMaxTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('maxTime') ?? (10 * 60 * 1000); // 10 min default
  }

  static Future<void> saveMaxTime(int time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('maxTime', time);
  }
}

class _CircleViewControllerState extends State<CircleViewController> {
  WebViewController? _webViewController;
  bool _isLoading = true;

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
              final webViewController = _webViewController;
              if (webViewController != null) {
                webViewController.loadUrl(CircleViewController.defaultUrl);
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          FutureBuilder(
              future: CircleViewController.getSavedUrl(),
              builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }
                return WebView(
                  initialUrl: snapshot.data,
                  javascriptMode: JavascriptMode.unrestricted,
                  onWebViewCreated: (WebViewController webViewController) {
                    _webViewController = webViewController;
                  },
                  navigationDelegate: (NavigationRequest request) async {
                    final url = request.url;
                    if (url.startsWith('circlebrowser://')) {
                      if (url.startsWith('circlebrowser://save=')) {
                        final parts = url.substring('circlebrowser://save='.length).split('?max_time=');
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
                  },
                  onPageStarted: (_) {
                    setState(() {
                      _isLoading = true;
                    });
                  },
                  onPageFinished: (_) {
                    setState(() {
                      _isLoading = false;
                    });
                  },
                );
              }),
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
    if (mounted){
      Navigator.pop(context);
    }
  }

  void _showSavedAlert({required String url}) {
    showDialog(
      context: context,
      builder: (context) => const AlertDialog(
        title: Text('Configuration saved'),
        content: Text('Your configuration has been saved successfully. You will be automatically redirected to the end-user login website to log in with your credentials.'),
      ),
    );

    Future.delayed(const Duration(seconds: 5)).then((value) {
      if (mounted){
        Navigator.pop(context); // Dismiss alert
      }
      _webViewController?.loadUrl(url);
    });
  }
}
