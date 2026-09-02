import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:bomach_os/src/constants/api_constants.dart';

import 'services_webview_stub.dart'
    if (dart.library.js_interop) 'services_webview_web.dart' as platform;

class ServicesWebView extends StatefulWidget {
  final String route;
  final bool hideSidebar;
  final bool hideTopbar;
  final String? customBaseUrl;

  const ServicesWebView({
    super.key,
    required this.route,
    this.hideSidebar = true,
    this.hideTopbar = false,
    this.customBaseUrl,
  });

  @override
  State<ServicesWebView> createState() => _ServicesWebViewState();
}

class _ServicesWebViewState extends State<ServicesWebView> {
  static const _storage = FlutterSecureStorage();
  String _token = '';
  String _refreshToken = '';
  bool _isLoading = true;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    try {
      final credentials = await Future.wait([
        _storage.read(key: 'access_token'),
        _storage.read(key: 'refresh_token'),
      ]).timeout(const Duration(seconds: 8));
      final token = credentials[0];
      final refreshToken = credentials[1];
      if (mounted) {
        setState(() {
          _token = token ?? '';
          _refreshToken = refreshToken ?? '';
          _isLoading = false;
          _loadError = token == null || token.isEmpty
              ? 'Your Bomach OS session is unavailable. Please sign in again.'
              : null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _loadError = 'Services could not read your Bomach OS session. Try again.';
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

    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(_loadError!),
            const SizedBox(height: 12),
            FilledButton(onPressed: _loadAuthToken, child: const Text('Try again')),
          ],
        ),
      );
    }

    final baseUrl = widget.customBaseUrl ?? ApiConstants.servicesBaseUrl;

    return platform.buildServicesPlatformView(
      initialUrl: baseUrl,
      token: _token,
      refreshToken: _refreshToken,
      currentRoute: widget.route,
      hideSidebar: widget.hideSidebar,
      hideTopbar: widget.hideTopbar,
    );
  }
}
