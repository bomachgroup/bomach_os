import 'package:flutter/foundation.dart';

class ApiConstants {
  static const String _prodBase = 'https://bomachauth.bgbot.app';
  static const String _stagingBase = 'https://bomachauthtest.bgbot.app';

  @visibleForTesting
  static bool isLiveHost(String host) {
    final h = host.toLowerCase();
    return h == 'bomach-os-app.web.app' ||
        h == 'bomach-os-app.firebaseapp.com' ||
        h == 'bomachosapp.web.app' ||
        h == 'bomachauthapp.web.app' ||
        h == 'bomachauth.bgbot.app';
  }

  @visibleForTesting
  static bool isStagingHost(String host) {
    final h = host.toLowerCase();
    return h == 'localhost' ||
        h == '127.0.0.1' ||
        h == '[::1]' ||
        h.endsWith('.local') ||
        h == 'bomach-os-test.web.app' ||
        h == 'bomachostest.web.app' ||
        h.contains('test');
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
    // On web: ONLY live hosts use prodBase. Standalone, localhost, and test use stagingBase.
    if (isLiveHost(host)) {
      return _prodBase;
    }
    return _stagingBase;
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
      defaultValue: 'https://finance-six-murex.vercel.app',
    );
  }

  // Deprecated: migrate to authBaseUrl or operationsBaseUrl
  static String get baseUrl => authBaseUrl;

  static const bool enableRequestBodyLogging = kDebugMode;
}
