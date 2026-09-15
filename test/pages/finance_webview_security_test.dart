import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/pages/finance/widget/finance_webview_contract.dart';

void main() {
  test('accepts auth-ready only from the exact iframe origin and source', () {
    expect(
      isTrustedFinanceMessage(
        eventOrigin: 'https://finance-six-murex.vercel.app',
        targetOrigin: 'https://finance-six-murex.vercel.app',
        sourceMatches: true,
      ),
      isTrue,
    );
    expect(
      isTrustedFinanceMessage(
        eventOrigin: 'https://attacker.example',
        targetOrigin: 'https://finance-six-murex.vercel.app',
        sourceMatches: true,
      ),
      isFalse,
    );
    expect(
      isTrustedFinanceMessage(
        eventOrigin: 'https://finance-six-murex.vercel.app',
        targetOrigin: 'https://finance-six-murex.vercel.app',
        sourceMatches: false,
      ),
      isFalse,
    );
  });

  test('finance iframe URL contains layout/config only, never credentials or identity', () {
    const token = 'ACCESS_TOKEN_SHOULD_NOT_BE_IN_URL';
    const refreshToken = 'REFRESH_TOKEN_SHOULD_NOT_BE_IN_URL';

    final url = buildFinanceIframeUrl(
      baseUrl: 'https://finance-six-murex.vercel.app/',
      route: 'dashboard',
      token: token,
      refreshToken: refreshToken,
      fullName: 'Test User',
      email: 'test@example.com',
      apiBaseUrl: 'https://bomachauthtest.bgbot.app',
      hideSidebar: true,
      hideTopbar: false,
    );
    final uri = Uri.parse(url);

    expect(uri.path, '/dashboard');
    expect(uri.queryParameters['embed'], 'true');
    expect(uri.queryParameters['hideSidebar'], 'true');
    expect(uri.queryParameters.containsKey('hideTopbar'), isFalse);
    for (final key in ['token', 'refreshToken', 'refresh_token', 'email', 'name', 'fullName']) {
      expect(uri.queryParameters.containsKey(key), isFalse, reason: 'sensitive key leaked: $key');
    }
    expect(url.contains(token), isFalse);
    expect(url.contains(refreshToken), isFalse);
  });
}
