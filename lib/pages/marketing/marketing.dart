import 'package:flutter/material.dart';
import 'package:bomach_os/pages/marketing/widget/marketing_webview.dart';

/// Root Marketing entry point inside BOMACH OS.
///
/// Navigation belongs to the BOMACH shell sidebar. The former implementation
/// rendered a second Marketing-specific tab navigation around the embedded
/// child app, which made the module appear to have two navigation systems and
/// allowed stale child navigation to remain visible.
class MarketingPage extends StatelessWidget {
  static const rootRoute = '/dashboard';

  const MarketingPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: const MarketingWebView(
        route: rootRoute,
        hideSidebar: true,
        hideTopbar: true,
      ),
    );
  }
}
