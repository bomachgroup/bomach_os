import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get authBaseUrl {
    if (kIsWeb) {
      if (Uri.base.host.contains('test') || Uri.base.host.contains('staging')) {
        return 'https://bomachauthtest.bgbot.app';
      }
    }
    return kReleaseMode
        ? 'https://bomachauth.bgbot.app'
        : 'https://bomachauthtest.bgbot.app';
  }

  static String get operationsBaseUrl {
    if (kIsWeb) {
      if (Uri.base.host.contains('test') || Uri.base.host.contains('staging')) {
        // Evidence suggests operations might be on the same domain or a dedicated one
        return 'https://bomachauthtest.bgbot.app';
      }
    }
    return kReleaseMode
        ? 'https://bomachauth.bgbot.app'
        : 'https://bomachauthtest.bgbot.app';
  }

  static String get marketingBaseUrl {
    return const String.fromEnvironment(
      'MARKETING_URL',
      defaultValue: 'http://localhost:5173',
    );
  }

  static String get servicesBaseUrl {
    return const String.fromEnvironment(
      'SERVICES_URL',
      defaultValue: 'http://localhost:5174',
    );
  }

  // Deprecated: migrate to authBaseUrl or operationsBaseUrl
  static String get baseUrl => authBaseUrl;

  static const bool enableRequestBodyLogging = kDebugMode;
}
