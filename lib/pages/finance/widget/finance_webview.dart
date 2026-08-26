import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import '../../auth/controller.dart';

import 'finance_webview_stub.dart'
    if (dart.library.js_interop) 'finance_webview_web.dart' as platform;

class FinanceWebView extends StatefulWidget {
  final String route;
  final bool hideSidebar;
  final bool hideTopbar;
  final String? customBaseUrl;

  const FinanceWebView({
    super.key,
    required this.route,
    this.hideSidebar = true,
    this.hideTopbar = false,
    this.customBaseUrl,
  });

  @override
  State<FinanceWebView> createState() => _FinanceWebViewState();
}

class _FinanceWebViewState extends State<FinanceWebView> {
  static const _storage = FlutterSecureStorage();
  String _token = '';
  String _refreshToken = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
  }

  Future<void> _loadAuthToken() async {
    try {
      final token = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (mounted) {
        setState(() {
          _token = token ?? '';
          _refreshToken = refreshToken ?? '';
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

    final baseUrl = widget.customBaseUrl ?? ApiConstants.financeBaseUrl;
    final authCtrl =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

    if (authCtrl != null) {
      return Obx(() {
        final user = authCtrl.currentUser.value;
        final fullName =
            user != null ? '${user.firstName} ${user.lastName}'.trim() : '';
        final email = user?.email ?? '';

        return platform.buildFinancePlatformView(
          initialUrl: baseUrl,
          token: _token,
          refreshToken: _refreshToken,
          fullName: fullName,
          email: email,
          currentRoute: widget.route,
          hideSidebar: widget.hideSidebar,
          hideTopbar: widget.hideTopbar,
        );
      });
    }

    return platform.buildFinancePlatformView(
      initialUrl: baseUrl,
      token: _token,
      refreshToken: _refreshToken,
      fullName: '',
      email: '',
      currentRoute: widget.route,
      hideSidebar: widget.hideSidebar,
      hideTopbar: widget.hideTopbar,
    );
  }
}
