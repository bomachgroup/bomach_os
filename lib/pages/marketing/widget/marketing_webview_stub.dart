import 'package:flutter/material.dart';
import 'package:bomach_os/src/constants/colors.dart';

/// Desktop/non-web fallback. Audit V7 fix: this used to render the full
/// token-bearing URL on screen ('Target URL: ...') — showing the live
/// access/refresh token pair to anyone near the screen. Only the route
/// name is shown now; no credential material exists in this widget.
Widget buildMarketingPlatformView({
  required String initialUrl,
  required String token,
  String refreshToken = '',
  required String currentRoute,
  bool hideSidebar = true,
  bool hideTopbar = false,
}) {
  return Container(
    width: double.infinity,
    height: double.infinity,
    color: AppColors.background,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.web_outlined,
              size: 56,
              color: AppColors.primary,
            ),
            const SizedBox(height: 16),
            const Text(
              'Marketing OS Web View',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Route: $currentRoute',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Webview embedding is active on Flutter Web. On desktop builds, please ensure your local marketing server is running or configure WebView2.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: AppColors.textMuted),
            ),
          ],
        ),
      ),
    ),
  );
}
