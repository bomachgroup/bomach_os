import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bomach_os/src/constants/api_constants.dart';

import 'marketing_webview_stub.dart'
    if (dart.library.js_interop) 'marketing_webview_web.dart' as platform;

class MarketingWebView extends StatefulWidget {
  final String route;
  final bool hideSidebar;
  final bool hideTopbar;
  final String? customBaseUrl;

  const MarketingWebView({
    super.key,
    required this.route,
    this.hideSidebar = true,
    this.hideTopbar = false,
    this.customBaseUrl,
  });

  @override
  State<MarketingWebView> createState() => _MarketingWebViewState();
}

class _MarketingWebViewState extends State<MarketingWebView> {
  static const _storage = FlutterSecureStorage();
  String _token = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    try {
      final token = await _storage.read(key: 'access_token');
      if (mounted) {
        setState(() {
          _token = token ?? '';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    final baseUrl = widget.customBaseUrl ?? ApiConstants.marketingBaseUrl;

    return platform.buildMarketingPlatformView(
      initialUrl: baseUrl,
      token: _token,
      currentRoute: widget.route,
      hideSidebar: widget.hideSidebar,
      hideTopbar: widget.hideTopbar,
    );
  }
}
