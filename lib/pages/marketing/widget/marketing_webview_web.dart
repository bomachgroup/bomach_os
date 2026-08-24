import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:web/web.dart' as web;

import '../../shared/embedded_web_view.dart';

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
  Timer? _tokenRetryTimer;
  int _postAttempts = 0;

  @override
  void initState() {
    super.initState();
    // Audit V3 fix: tokens no longer ride in the URL.
    _targetUrl = buildEmbeddedUrl(
      baseUrl: widget.initialUrl,
      route: widget.currentRoute,
      hideSidebar: widget.hideSidebar,
      hideTopbar: widget.hideTopbar,
    );
    _viewType = 'marketing-iframe-${DateTime.now().millisecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = _targetUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block';

      // Deliver auth via postMessage once the child app has loaded. The
      // marketing app listens for {type:'BOMACH_AUTH_TOKEN', token,
      // refreshToken} and persists them itself.
      iframe.addEventListener(
        'load',
        ((web.Event _) => _postTokens(iframe)).toJS,
      );

      _activeIframes[_viewType] = iframe;
      return iframe;
    });

    _scheduleTokenRetries();
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
      final newUrl = buildEmbeddedUrl(
        baseUrl: widget.initialUrl,
        route: widget.currentRoute,
        hideSidebar: widget.hideSidebar,
        hideTopbar: widget.hideTopbar,
      );
      final iframe = _activeIframes[_viewType];
      if (iframe != null) {
        iframe.src = newUrl;
        _postAttempts = 0;
        _scheduleTokenRetries();
      }
    }
  }

  void _scheduleTokenRetries() {
    _tokenRetryTimer?.cancel();
    _postAttempts = 0;
    // SPA reload race: the child may not have its listener registered when
    // the first load event fires. Resend a few times; the child persists
    // tokens to storage, so later loads self-heal even if all retries are
    // missed before navigation.
    _tokenRetryTimer = Timer.periodic(const Duration(milliseconds: 1500),
        (timer) {
      if (_postAttempts >= 3) {
        timer.cancel();
        return;
      }
      _postAttempts++;
      final iframe = _activeIframes[_viewType];
      if (iframe != null) {
        _postTokens(iframe);
      }
    });
  }

  /// Posts the token pair to the iframe with an EXPLICIT target origin —
  /// never '*', so a malicious nested page can't capture credentials.
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
    };

    win.postMessage(payload.jsify(), targetOrigin.toJS);
  }

  @override
  void dispose() {
    _tokenRetryTimer?.cancel();
    _activeIframes.remove(_viewType);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: HtmlElementView(viewType: _viewType),
    );
  }
}
