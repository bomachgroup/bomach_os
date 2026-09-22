import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/pages/shared/embedded_web_view_interaction.dart';
import 'package:web/web.dart' as web;
import 'marketing_webview_contract.dart';

final Map<String, web.HTMLIFrameElement> _activeIframes = {};
final Map<String, JSFunction> _activeMessageHandlers = {};

Widget buildMarketingPlatformView({
  required String initialUrl,
  required String token,
  String refreshToken = '',
  String fullName = '',
  String email = '',
  required String currentRoute,
  bool hideSidebar = true,
  bool hideTopbar = false,
  ValueChanged<String>? onNavigationRequested,
}) {
  return _MarketingIFrameView(
    initialUrl: initialUrl,
    token: token,
    refreshToken: refreshToken,
    fullName: fullName,
    email: email,
    currentRoute: currentRoute,
    hideSidebar: hideSidebar,
    hideTopbar: hideTopbar,
    onNavigationRequested: onNavigationRequested,
  );
}

class _MarketingIFrameView extends StatefulWidget {
  final String initialUrl;
  final String token;
  final String refreshToken;
  final String fullName;
  final String email;
  final String currentRoute;
  final bool hideSidebar;
  final bool hideTopbar;
  final ValueChanged<String>? onNavigationRequested;

  const _MarketingIFrameView({
    required this.initialUrl,
    required this.token,
    this.refreshToken = '',
    this.fullName = '',
    this.email = '',
    required this.currentRoute,
    required this.hideSidebar,
    required this.hideTopbar,
    this.onNavigationRequested,
  });

  @override
  State<_MarketingIFrameView> createState() => _MarketingIFrameViewState();
}

class _MarketingIFrameViewState extends State<_MarketingIFrameView> {
  late final String _viewType;
  late final String _targetUrl;
  Timer? _tokenRetryTimer;
  int _postAttempts = 0;
  VoidCallback? _pointerEventsListener;

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

      _pointerEventsListener = () => _syncPointerEvents(iframe);
      embeddedWebViewInteraction.addListener(_pointerEventsListener!);
      _syncPointerEvents(iframe);

      // Deliver auth via postMessage once the child app has loaded
      iframe.addEventListener(
        'load',
        ((web.Event _) => _postTokens(iframe)).toJS,
      );

      final messageHandler = ((web.MessageEvent event) {
        final targetOrigin = _originForTarget();
        final trusted = isTrustedMarketingMessage(
          eventOrigin: event.origin,
          targetOrigin: targetOrigin,
          sourceMatches: event.source == iframe.contentWindow,
        );
        if (!trusted) return;
        final messageData = event.data;
        final message = messageData is JSString ? messageData.toDart : null;
        final requestedRoute = marketingRouteForMessage(message);
        if (requestedRoute != null) {
          widget.onNavigationRequested?.call(requestedRoute);
          return;
        }
        _postAttempts = 0;
        _postTokens(iframe);
        _scheduleTokenRetries();
      }).toJS;
      _activeMessageHandlers[_viewType] = messageHandler;
      web.window.addEventListener('message', messageHandler);

      _activeIframes[_viewType] = iframe;
      return iframe;
    });

    _scheduleTokenRetries();
  }

  void _syncPointerEvents(web.HTMLIFrameElement iframe) {
    iframe.style.pointerEvents = embeddedWebViewInteraction.pointerEvents;
  }

  @override
  void didUpdateWidget(covariant _MarketingIFrameView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentRoute != widget.currentRoute ||
        oldWidget.token != widget.token ||
        oldWidget.refreshToken != widget.refreshToken ||
        oldWidget.fullName != widget.fullName ||
        oldWidget.email != widget.email ||
        oldWidget.initialUrl != widget.initialUrl ||
        oldWidget.hideSidebar != widget.hideSidebar ||
        oldWidget.hideTopbar != widget.hideTopbar) {
      final newUrl = _buildFullUrl();
      final iframe = _activeIframes[_viewType];
      if (iframe != null) {
        if (oldWidget.currentRoute != widget.currentRoute) {
          iframe.src = newUrl;
        }
        _postAttempts = 0;
        _postTokens(iframe);
        _scheduleTokenRetries();
      }
    }
  }

  String _buildFullUrl() {
    final effectiveApiBase = ApiConstants.authBaseUrl;
    return buildMarketingIframeUrl(
      baseUrl: widget.initialUrl,
      route: widget.currentRoute,
      token: widget.token,
      refreshToken: widget.refreshToken,
      fullName: widget.fullName,
      email: widget.email,
      apiBaseUrl: effectiveApiBase,
      backendUrl: effectiveApiBase,
      hideSidebar: widget.hideSidebar,
      hideTopbar: widget.hideTopbar,
    );
  }

  void _scheduleTokenRetries() {
    _tokenRetryTimer?.cancel();
    _postAttempts = 0;
    // SPA reload race: the child may not have its listener registered when
    // the first load event fires. Resend a few times; the child persists
    // tokens to storage, so later loads self-heal even if all retries are
    // missed before navigation.
    _tokenRetryTimer =
        Timer.periodic(const Duration(milliseconds: 1500), (timer) {
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

  String _originForTarget() {
    final parsed = Uri.tryParse(_targetUrl);
    if (parsed == null || !parsed.hasScheme || parsed.host.isEmpty) return '';
    return '${parsed.scheme}://${parsed.host}${parsed.hasPort ? ':${parsed.port}' : ''}';
  }

  /// Posts the token pair to the iframe with an EXPLICIT target origin —
  /// never '*', so a malicious nested page can't capture credentials.
  void _postTokens(web.HTMLIFrameElement iframe) {
    if (widget.token.isEmpty) return;
    final win = iframe.contentWindow;
    if (win == null) return;

    final targetOrigin = _originForTarget();
    if (targetOrigin.isEmpty) return;

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
    final pointerEventsListener = _pointerEventsListener;
    if (pointerEventsListener != null) {
      embeddedWebViewInteraction.removeListener(pointerEventsListener);
    }
    final messageHandler = _activeMessageHandlers.remove(_viewType);
    if (messageHandler != null) {
      web.window.removeEventListener('message', messageHandler);
    }
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
