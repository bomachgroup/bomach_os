import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../shared/embedded_web_view.dart';
import '../../../src/constants/api_constants.dart';

final Map<String, web.HTMLIFrameElement> _activeServicesIframes = {};

Widget buildServicesPlatformView({
  required String initialUrl,
  required String token,
  String refreshToken = '',
  required String currentRoute,
  bool hideSidebar = true,
  bool hideTopbar = false,
}) {
  return _ServicesIFrameView(
    initialUrl: initialUrl,
    token: token,
    refreshToken: refreshToken,
    currentRoute: currentRoute,
    hideSidebar: hideSidebar,
    hideTopbar: hideTopbar,
  );
}

class _ServicesIFrameView extends StatefulWidget {
  final String initialUrl;
  final String token;
  final String refreshToken;
  final String currentRoute;
  final bool hideSidebar;
  final bool hideTopbar;

  const _ServicesIFrameView({
    required this.initialUrl,
    required this.token,
    this.refreshToken = '',
    required this.currentRoute,
    required this.hideSidebar,
    required this.hideTopbar,
  });

  @override
  State<_ServicesIFrameView> createState() => _ServicesIFrameViewState();
}

class _ServicesIFrameViewState extends State<_ServicesIFrameView> {
  late final String _viewType;
  late String _targetUrl;
  Timer? _tokenRetryTimer;
  int _postAttempts = 0;

  @override
  void initState() {
    super.initState();
    // Audit V3 fix: tokens no longer ride in the URL.
    _targetUrl = buildEmbeddedUrl(
      baseUrl: widget.initialUrl,
      route: widget.currentRoute,
      token: widget.token,
      refreshToken: widget.refreshToken,
      hideSidebar: widget.hideSidebar,
      hideTopbar: widget.hideTopbar,
    );
    _viewType = 'services-iframe-${DateTime.now().millisecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = _targetUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block';

      iframe.addEventListener(
        'load',
        ((web.Event _) => _postTokens(iframe)).toJS,
      );

      _activeServicesIframes[_viewType] = iframe;
      return iframe;
    });

    _scheduleTokenRetries();
  }

  @override
  void didUpdateWidget(covariant _ServicesIFrameView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute ||
        oldWidget.token != widget.token ||
        oldWidget.refreshToken != widget.refreshToken ||
        oldWidget.initialUrl != widget.initialUrl ||
        oldWidget.hideSidebar != widget.hideSidebar ||
        oldWidget.hideTopbar != widget.hideTopbar) {
      final newUrl = buildEmbeddedUrl(
        baseUrl: widget.initialUrl,
        route: widget.currentRoute,
        token: widget.token,
        refreshToken: widget.refreshToken,
        hideSidebar: widget.hideSidebar,
        hideTopbar: widget.hideTopbar,
      );
      final iframe = _activeServicesIframes[_viewType];
      if (iframe != null) {
        _targetUrl = newUrl;
        iframe.src = newUrl;
        _postAttempts = 0;
        _scheduleTokenRetries();
      }
    }
  }

  void _scheduleTokenRetries() {
    _tokenRetryTimer?.cancel();
    _postAttempts = 0;
    _tokenRetryTimer = Timer.periodic(const Duration(milliseconds: 1500),
        (timer) {
      if (_postAttempts >= 12) {
        timer.cancel();
        return;
      }
      _postAttempts++;
      final iframe = _activeServicesIframes[_viewType];
      if (iframe != null) {
        _postTokens(iframe);
      }
    });
  }

  void _postTokens(web.HTMLIFrameElement iframe) {
    if (widget.token.isEmpty) return;
    final win = iframe.contentWindow;
    if (win == null) return;

    final Uri parsed;
    try {
      parsed = Uri.parse(_targetUrl);
    } on FormatException {
      return;
    }
    if (!parsed.hasScheme || parsed.host.isEmpty) return;
    final targetOrigin =
        '${parsed.scheme}://${parsed.host}${parsed.hasPort ? ':${parsed.port}' : ''}';

    final payload = <String, String>{
      'type': 'BOMACH_AUTH_TOKEN',
      'token': widget.token,
      if (widget.refreshToken.isNotEmpty) 'refreshToken': widget.refreshToken,
      'apiBaseUrl': ApiConstants.authBaseUrl,
      'backendUrl': ApiConstants.authBaseUrl,
    };

    win.postMessage(payload.jsify(), targetOrigin.toJS);
  }

  @override
  void dispose() {
    _tokenRetryTimer?.cancel();
    _activeServicesIframes.remove(_viewType);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
