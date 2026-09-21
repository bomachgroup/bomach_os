import '../../src/constants/api_constants.dart';

/// Audit V3 fix: pure, VM-testable URL builder for embedded webviews.
///
/// Tokens are NEVER placed in the URL — they travel via postMessage
/// after iframe load (`postAuthTokens`, implemented in the web binding).
/// Only non-secret config params ride in the query string.
String buildEmbeddedUrl({
  required String baseUrl,
  required String route,
  String? token,
  String? refreshToken,
  bool hideSidebar = true,
  bool hideTopbar = false,
  String? apiBaseUrl,
  String? backendUrl,
}) {
  final cleanBase = baseUrl.replaceAll(RegExp(r'/+$'), '');
  final cleanRoute = route.startsWith('/') ? route : '/$route';
  final uri = Uri.parse('$cleanBase$cleanRoute');

  final queryParams = Map<String, String>.from(uri.queryParameters);
  queryParams['embed'] = 'true';
  if (hideSidebar) queryParams['hideSidebar'] = 'true';
  if (hideTopbar) queryParams['hideTopbar'] = 'true';
  final effectiveApiBase = apiBaseUrl ?? ApiConstants.authBaseUrl;
  queryParams['apiBaseUrl'] = effectiveApiBase;
  queryParams['backendUrl'] = backendUrl ?? effectiveApiBase;

  return uri.replace(queryParameters: queryParams).toString();
}
