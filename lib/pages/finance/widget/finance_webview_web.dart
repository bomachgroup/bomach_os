import 'dart:async';
import 'dart:js_interop';
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:web/web.dart' as web;

final Map<String, web.HTMLIFrameElement> _activeIframes = {};

Widget buildFinancePlatformView({
  required String initialUrl,
  required String token,
  String refreshToken = '',
  String fullName = '',
  String email = '',
  required String currentRoute,
  bool hideSidebar = true,
  bool hideTopbar = false,
}) {
  return _FinanceIFrameView(
    initialUrl: initialUrl,
    token: token,
    refreshToken: refreshToken,
    fullName: fullName,
    email: email,
    currentRoute: currentRoute,
    hideSidebar: hideSidebar,
    hideTopbar: hideTopbar,
  );
}

class _FinanceIFrameView extends StatefulWidget {
  final String initialUrl;
  final String token;
  final String refreshToken;
  final String fullName;
  final String email;
  final String currentRoute;
  final bool hideSidebar;
  final bool hideTopbar;

  const _FinanceIFrameView({
    required this.initialUrl,
    required this.token,
    this.refreshToken = '',
    this.fullName = '',
    this.email = '',
    required this.currentRoute,
    required this.hideSidebar,
    required this.hideTopbar,
  });

  @override
  State<_FinanceIFrameView> createState() => _FinanceIFrameViewState();
}

class _FinanceIFrameViewState extends State<_FinanceIFrameView> {
  late final String _viewType;
  late final String _targetUrl;
  Timer? _tokenRetryTimer;
  int _postAttempts = 0;

  @override
  void initState() {
    super.initState();
    _targetUrl = _buildFullUrl();
    _viewType = 'finance-iframe-${DateTime.now().millisecondsSinceEpoch}';

    ui_web.platformViewRegistry.registerViewFactory(_viewType, (int viewId) {
      final iframe = web.HTMLIFrameElement()
        ..src = _targetUrl
        ..style.border = 'none'
        ..style.width = '100%'
        ..style.height = '100%'
        ..style.display = 'block';

      // Deliver auth via postMessage once the child app has loaded
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
  void didUpdateWidget(covariant _FinanceIFrameView oldWidget) {
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
    final cleanBase = widget.initialUrl.replaceAll(RegExp(r'/+$'), '');
    final cleanRoute = widget.currentRoute.startsWith('/')
        ? widget.currentRoute
        : '/${widget.currentRoute}';
    final uri = Uri.parse('$cleanBase$cleanRoute');

    final queryParams = Map<String, String>.from(uri.queryParameters);
    queryParams['embed'] = 'true';
    if (widget.hideSidebar) queryParams['hideSidebar'] = 'true';
    if (widget.hideTopbar) queryParams['hideTopbar'] = 'true';
    if (widget.token.isNotEmpty) queryParams['token'] = widget.token;
    if (widget.refreshToken.isNotEmpty) queryParams['refreshToken'] = widget.refreshToken;
    if (widget.fullName.isNotEmpty) {
      queryParams['name'] = widget.fullName;
      queryParams['fullName'] = widget.fullName;
    }
    if (widget.email.isNotEmpty) {
      queryParams['email'] = widget.email;
    }
    final effectiveApiBase = ApiConstants.authBaseUrl;
    queryParams['apiBaseUrl'] = effectiveApiBase;
    queryParams['backendUrl'] = effectiveApiBase;

    return uri.replace(queryParameters: queryParams).toString();
  }

  void _scheduleTokenRetries() {
    _tokenRetryTimer?.cancel();
    _postAttempts = 0;
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
      if (widget.fullName.isNotEmpty) 'fullName': widget.fullName,
      if (widget.fullName.isNotEmpty) 'name': widget.fullName,
      if (widget.email.isNotEmpty) 'email': widget.email,
      'apiBaseUrl': ApiConstants.authBaseUrl,
      'backendUrl': ApiConstants.authBaseUrl,
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
