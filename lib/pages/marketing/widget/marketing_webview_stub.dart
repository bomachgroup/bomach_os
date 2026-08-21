import 'package:flutter/material.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/api_constants.dart';

Widget buildMarketingPlatformView({
  required String initialUrl,
  required String token,
  required String currentRoute,
  bool hideSidebar = true,
  bool hideTopbar = false,
}) {
  final fullUrl = _buildFullUrl(
    initialUrl: initialUrl,
    route: currentRoute,
    token: token,
    hideSidebar: hideSidebar,
    hideTopbar: hideTopbar,
  );

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
              'Target URL: $fullUrl',
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

String _buildFullUrl({
  required String initialUrl,
  required String route,
  required String token,
  required bool hideSidebar,
  required bool hideTopbar,
}) {
  final cleanBase = initialUrl.replaceAll(RegExp(r'/+$'), '');
  final cleanRoute = route.startsWith('/') ? route : '/$route';
  final uri = Uri.parse('$cleanBase$cleanRoute');

  final queryParams = Map<String, String>.from(uri.queryParameters);
  queryParams['embed'] = 'true';
  if (hideSidebar) queryParams['hideSidebar'] = 'true';
  if (hideTopbar) queryParams['hideTopbar'] = 'true';
  if (token.isNotEmpty) queryParams['token'] = token;
  queryParams['apiBaseUrl'] = ApiConstants.authBaseUrl;
  queryParams['backendUrl'] = ApiConstants.authBaseUrl;

  return uri.replace(queryParameters: queryParams).toString();
}
