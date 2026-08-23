import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;
import 'package:bomach_os/src/constants/api_constants.dart';

final Map<String, web.HTMLIFrameElement> _activeIframes = {};

Widget buildMarketingPlatformView({
  required String initialUrl,
  required String token,
  String refreshToken = '',
  required String currentRoute,
  bool hideSidebar = true,
  bool hideTopbar = false,
}) {
  return _MarketingIFrameView(
    initialUrl: initialUrl,
    token: token,
    refreshToken: refreshToken,
    currentRoute: currentRoute,
    hideSidebar: hideSidebar,
    hideTopbar: hideTopbar,
  );
}

class _MarketingIFrameView extends StatefulWidget {
  final String initialUrl;
  final String token;
  final String refreshToken;
  final String currentRoute;
  final bool hideSidebar;
  final bool hideTopbar;

  const _MarketingIFrameView({
    required this.initialUrl,
    required this.token,
    this.refreshToken = '',
    required this.currentRoute,
    required this.hideSidebar,
    required this.hideTopbar,
  });

  @override
  State<_MarketingIFrameView> createState() => _MarketingIFrameViewState();
}

class _MarketingIFrameViewState extends State<_MarketingIFrameView> {
  late final String _viewType;
  late final String _targetUrl;

  @override
  void initState() {
    super.initState();
    _targetUrl = _buildFullUrl();
    _viewType = 'marketing-iframe-${DateTime.now().millisecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = _targetUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block';

      _activeIframes[_viewType] = iframe;
      return iframe;
    });
  }

  @override
  void didUpdateWidget(covariant _MarketingIFrameView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute ||
        oldWidget.token != widget.token ||
        oldWidget.refreshToken != widget.refreshToken ||
        oldWidget.initialUrl != widget.initialUrl ||
        oldWidget.hideSidebar != widget.hideSidebar ||
        oldWidget.hideTopbar != widget.hideTopbar) {
      final newUrl = _buildFullUrl();
      final iframe = _activeIframes[_viewType];
      if (iframe != null) {
        iframe.src = newUrl;
      }
    }
  }

  @override
  void dispose() {
    _activeIframes.remove(_viewType);
    super.dispose();
  }

  String _buildFullUrl() {
    final cleanBase = widget.initialUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanRoute = widget.currentRoute.startsWith('/')
        ? widget.currentRoute
        : '/${widget.currentRoute}';
    final uri = Uri.parse('$cleanBase$cleanRoute');

    final queryParams = Map<String, String>.from(uri.queryParameters);
    queryParams['embed'] = 'true';
    if (widget.hideSidebar) queryParams['hideSidebar'] = 'true';
    if (widget.hideTopbar) queryParams['hideTopbar'] = 'true';
    if (widget.token.isNotEmpty) {
      queryParams['token'] = widget.token;
      queryParams['access_token'] = widget.token;
    }
    if (widget.refreshToken.isNotEmpty) {
      queryParams['refresh_token'] = widget.refreshToken;
      queryParams['refreshToken'] = widget.refreshToken;
    }
    queryParams['apiBaseUrl'] = ApiConstants.authBaseUrl;
    queryParams['backendUrl'] = ApiConstants.authBaseUrl;

    return uri.replace(queryParameters: queryParams).toString();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
