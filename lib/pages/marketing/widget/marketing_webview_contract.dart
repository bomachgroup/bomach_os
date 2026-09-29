import 'package:bomach_os/src/app_routes/app_route_constants.dart';

/// Builds the child-app URL without placing credentials or user identity in it.
/// Authentication is delivered separately through a validated postMessage.
const String marketingNewLeadNavigationMessage =
    'BOMACH_NAVIGATE_MARKETING_NEW_LEAD';

String? marketingRouteForMessage(String? message) {
  if (message == marketingNewLeadNavigationMessage) {
    return RouteConstants.marketingNewLead;
  }
  return null;
}

String buildMarketingIframeUrl({
  required String baseUrl,
  required String route,
  String token = '',
  String refreshToken = '',
  String fullName = '',
  String email = '',
  String apiBaseUrl = '',
  String backendUrl = '',
  String parentOrigin = '',
  bool hideSidebar = true,
  bool hideTopbar = false,
}) {
  final base = Uri.parse(baseUrl.trim());
  final childRoute = Uri.parse(route.startsWith('/') ? route : '/$route');
  final basePath = base.path.endsWith('/')
      ? base.path.substring(0, base.path.length - 1)
      : base.path;
  final routePath =
      childRoute.path.startsWith('/') ? childRoute.path : '/${childRoute.path}';
  final query = <String, String>{
    ...base.queryParameters,
    ...childRoute.queryParameters,
    'embed': 'true',
    if (hideSidebar) 'hideSidebar': 'true',
    if (hideTopbar) 'hideTopbar': 'true',
    if (apiBaseUrl.isNotEmpty) 'apiBaseUrl': apiBaseUrl,
    if (backendUrl.isNotEmpty) 'backendUrl': backendUrl,
    if (parentOrigin.isNotEmpty) 'parentOrigin': parentOrigin,
  };

  return base
      .replace(path: '$basePath$routePath', queryParameters: query)
      .toString();
}

bool isTrustedMarketingMessage({
  required String eventOrigin,
  required String targetOrigin,
  required bool sourceMatches,
}) =>
    eventOrigin == targetOrigin && sourceMatches;
