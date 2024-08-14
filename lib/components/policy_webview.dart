import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class PolicyWebView extends StatefulWidget {
  const PolicyWebView({super.key});

  @override
  State<PolicyWebView> createState() => _PolicyWebViewState();
}

class _PolicyWebViewState extends State<PolicyWebView> {

  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
    ..loadRequest(Uri.parse("https://polmitra.com/privacy-policy-2"));
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
      ),
      body: WebViewWidget(
        controller: _controller,

      ),
    );
  }
}
