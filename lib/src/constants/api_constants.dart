import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _prodBase = 'https://bomachauth.bgbot.app';
  static const String _stagingBase = 'https://bomachauthtest.bgbot.app';

  /// Exact-host staging allowlist (audit V5 fix). Substring matching
  /// (`contains('test')`) used to route production credentials to the
  /// staging backend on hosts like `evil-test.attacker.com` or branch
  /// preview URLs; the old `|| host.isNotEmpty` tautology made the prod
  /// allowlist dead code. Fail closed: anything not listed here is PROD.
  @visibleForTesting
  static bool isStagingHost(String host) {
    final h = host.toLowerCase();
    return h == 'localhost' || h == '127.0.0.1' || h == 'bomach-os-test.web.app';
  }

  /// Pure, testable base-URL resolver. Web builds pick by window host;
  /// non-web builds keep the release/debug split.
  @visibleForTesting
  static String resolveApiBase({
    required bool isWeb,
    required bool isRelease,
    required String host,
  }) {
    if (!isWeb) {
      return isRelease ? _prodBase : _stagingBase;
    }
    return isStagingHost(host) ? _stagingBase : _prodBase;
  }

  static String get authBaseUrl {
    return resolveApiBase(
      isWeb: kIsWeb,
      isRelease: kReleaseMode,
      host: kIsWeb ? Uri.base.host : '',
    );
  }

  static String get operationsBaseUrl => authBaseUrl;

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
