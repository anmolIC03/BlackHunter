import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
// Import this to access the Android-specific features
import 'package:webview_flutter_android/webview_flutter_android.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();

    // The controller is now initialized without platform-specific parameters.
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => setState(() => _isLoading = true),
          onPageFinished: (_) => setState(() => _isLoading = false),
          onWebResourceError: (error) {
            debugPrint('''
              Page resource error:
              code: ${error.errorCode}
              description: ${error.description}
              errorType: ${error.errorType}
              isForMainFrame: ${error.isForMainFrame}
          ''');
          },
        ),
      )
      ..loadRequest(Uri.parse("https://blackhunter.in/"));
  }

  @override
  Widget build(BuildContext context) {
    // Platform-specific settings like Hybrid Composition are now applied to the widget.
    late final PlatformWebViewWidgetCreationParams params;
    if (WebViewPlatform.instance is AndroidWebViewPlatform) {
      params = AndroidWebViewWidgetCreationParams(
        // CORRECTED: Use the .platform property to pass the correct controller type.
        controller: _controller.platform,
        displayWithHybridComposition: true,
      );
    } else {
      params = PlatformWebViewWidgetCreationParams(
        // CORRECTED: Use the .platform property to pass the correct controller type.
        controller: _controller.platform,
      );
    }

    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) {
          return;
        }
        if (await _controller.canGoBack()) {
          _controller.goBack();
        } else {
          Navigator.of(context).pop();
        }
      },
      child: Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              // Use the WebViewWidget.fromPlatformCreationParams factory
              WebViewWidget.fromPlatformCreationParams(params: params),
              if (_isLoading) const Center(child: CircularProgressIndicator()),
            ],
          ),
        ),
      ),
    );
  }
}
