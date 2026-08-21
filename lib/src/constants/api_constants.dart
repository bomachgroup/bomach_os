import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get authBaseUrl {
    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();
      if (host.contains('test') || host.contains('staging') || host == 'localhost' || host == '127.0.0.1') {
        return 'https://bomachauthtest.bgbot.app';
      }
      if (host.contains('bomach-os-app') || host.isNotEmpty) {
        return 'https://bomachauth.bgbot.app';
      }
    }
    return kReleaseMode
        ? 'https://bomachauth.bgbot.app'
        : 'https://bomachauthtest.bgbot.app';
  }

  static String get operationsBaseUrl {
    if (kIsWeb) {
      final host = Uri.base.host.toLowerCase();
      if (host.contains('test') || host.contains('staging') || host == 'localhost' || host == '127.0.0.1') {
        return 'https://bomachauthtest.bgbot.app';
      }
      if (host.contains('bomach-os-app') || host.isNotEmpty) {
        return 'https://bomachauth.bgbot.app';
      }
    }
    return kReleaseMode
        ? 'https://bomachauth.bgbot.app'
        : 'https://bomachauthtest.bgbot.app';
  }

  static String get marketingBaseUrl {
    return const String.fromEnvironment(
      'MARKETING_URL',
      defaultValue: 'https://marketing-wine-alpha.vercel.app',
    );
  }

  static String get servicesBaseUrl {
    return const String.fromEnvironment(
      'SERVICES_URL',
      defaultValue: 'https://services-mocha-xi.vercel.app',
    );
  }

  // Deprecated: migrate to authBaseUrl or operationsBaseUrl
  static String get baseUrl => authBaseUrl;

  static const bool enableRequestBodyLogging = kDebugMode;
}
