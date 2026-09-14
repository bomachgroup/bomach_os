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

  /// Local-dev escape hatch. Run with
  /// `--dart-define=USE_LOCAL_BACKEND=true` to point auth + operations at
  /// the Django runserver instead of staging/prod. Override host/port with
  /// `--dart-define=LOCAL_API_URL=http://127.0.0.1:8000`.
  /// (Android emulator quirk: the emulator's localhost is itself, so use
  /// `--dart-define=LOCAL_API_URL=http://10.0.2.2:8000` there.)
  static const bool _useLocalBackend =
      bool.fromEnvironment('USE_LOCAL_BACKEND', defaultValue: false);
  static const String _localApiUrl = String.fromEnvironment(
    'LOCAL_API_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );

  /// Pure, testable base-URL resolver. Web builds pick by window host;
  /// non-web builds keep the release/debug split.
  @visibleForTesting
  static String resolveApiBase({
    required bool isWeb,
    required bool isRelease,
    required String host,
    bool useLocalBackend = _useLocalBackend,
    String localApiUrl = _localApiUrl,
  }) {
    if (useLocalBackend) return localApiUrl;
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

  static String get financeBaseUrl {
    return const String.fromEnvironment(
      'FINANCE_URL',
      defaultValue: 'https://finances-bomach.vercel.app',
    );
  }

  // Deprecated: migrate to authBaseUrl or operationsBaseUrl
  static String get baseUrl => authBaseUrl;

  static const bool enableRequestBodyLogging = kDebugMode;
}
