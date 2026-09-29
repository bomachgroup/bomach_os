import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import '../../auth/controller.dart';

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
  String _refreshToken = '';
  bool _isLoading = true;
  StreamSubscription<dynamic>? _authUserSubscription;
  int _tokenLoadGeneration = 0;

  @override
  void initState() {
    super.initState();
    _loadAuthToken();
    if (Get.isRegistered<AuthController>()) {
      final authController = Get.find<AuthController>();
      _authUserSubscription = authController.currentUser.listen((user) {
        if (user == null) {
          _tokenLoadGeneration++;
          if (mounted) {
            setState(() {
              _token = '';
              _refreshToken = '';
            });
          }
        } else {
          _loadAuthToken();
        }
      });
    }
  }

  Future<void> _loadAuthToken() async {
    final generation = ++_tokenLoadGeneration;
    try {
      final token = await _storage.read(key: 'access_token');
      final refreshToken = await _storage.read(key: 'refresh_token');
      if (mounted && generation == _tokenLoadGeneration) {
        setState(() {
          _token = token ?? '';
          _refreshToken = refreshToken ?? '';
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted && generation == _tokenLoadGeneration) {
        setState(() {
          _token = '';
          _refreshToken = '';
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _tokenLoadGeneration++;
    _authUserSubscription?.cancel();
    super.dispose();
  }

  void _handleNavigationRequested(String route) {
    if (mounted && GoRouter.of(context).state.matchedLocation != route) {
      context.go(route);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_token.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Marketing is waiting for your Bomach OS sign-in.'),
              const SizedBox(height: 12),
              TextButton(
                onPressed: _loadAuthToken,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    final baseUrl = widget.customBaseUrl ?? ApiConstants.marketingBaseUrl;
    final authCtrl =
        Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;

    if (authCtrl != null) {
      return Obx(() {
        final user = authCtrl.currentUser.value;
        final fullName =
            user != null ? '${user.firstName} ${user.lastName}'.trim() : '';
        final email = user?.email ?? '';

        return platform.buildMarketingPlatformView(
          initialUrl: baseUrl,
          token: _token,
          refreshToken: _refreshToken,
          fullName: fullName,
          email: email,
          currentRoute: widget.route,
          hideSidebar: widget.hideSidebar,
          hideTopbar: widget.hideTopbar,
          onNavigationRequested: _handleNavigationRequested,
        );
      });
    }

    return platform.buildMarketingPlatformView(
      initialUrl: baseUrl,
      token: _token,
      refreshToken: _refreshToken,
      fullName: '',
      email: '',
      currentRoute: widget.route,
      hideSidebar: widget.hideSidebar,
      hideTopbar: widget.hideTopbar,
      onNavigationRequested: _handleNavigationRequested,
    );
  }
}
