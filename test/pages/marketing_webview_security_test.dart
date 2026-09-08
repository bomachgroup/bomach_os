import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/pages/marketing/widget/marketing_webview_contract.dart';

void main() {
  test('accepts auth-ready only from the exact iframe origin and source', () {
    expect(
      isTrustedMarketingMessage(
        eventOrigin: 'https://marketing-wine-alpha.vercel.app',
        targetOrigin: 'https://marketing-wine-alpha.vercel.app',
        sourceMatches: true,
      ),
      isTrue,
    );
    expect(
      isTrustedMarketingMessage(
        eventOrigin: 'https://attacker.example',
        targetOrigin: 'https://marketing-wine-alpha.vercel.app',
        sourceMatches: true,
      ),
      isFalse,
    );
    expect(
      isTrustedMarketingMessage(
        eventOrigin: 'https://marketing-wine-alpha.vercel.app',
        targetOrigin: 'https://marketing-wine-alpha.vercel.app',
        sourceMatches: false,
      ),
      isFalse,
    );
  });

  test('marketing iframe URL contains layout/config only, never credentials or identity', () {
    const token = 'ACCESS_TOKEN_SHOULD_NOT_BE_IN_URL';
    const refreshToken = 'REFRESH_TOKEN_SHOULD_NOT_BE_IN_URL';

    final url = buildMarketingIframeUrl(
      baseUrl: 'https://marketing-wine-alpha.vercel.app/',
      route: 'performance',
      token: token,
      refreshToken: refreshToken,
      fullName: 'Test User',
      email: 'test@example.com',
      apiBaseUrl: 'https://bomachauthtest.bgbot.app',
      hideSidebar: true,
      hideTopbar: false,
    );
    final uri = Uri.parse(url);

    expect(uri.path, '/performance');
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
