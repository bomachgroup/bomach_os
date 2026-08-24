import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/pages/shared/embedded_web_view.dart';

/// Spec (V3/V7 fix, Batch 2):
///
/// `buildEmbeddedUrl` is the pure, VM-testable URL builder shared by the
/// marketing and services embedded webviews. It MUST:
///   - keep non-secret config params: embed, hideSidebar, hideTopbar,
///     apiBaseUrl, backendUrl
///   - NEVER emit any token parameter (token / access_token /
///     refresh_token / refreshToken) — tokens travel via postMessage.
void main() {
  const marketingBase = 'https://marketing-wine-alpha.vercel.app';
  const servicesBase = 'https://services-mocha-xi.vercel.app';
  const access = 'ACCESS_TOKEN_VALUE';
  const refresh = 'REFRESH_TOKEN_VALUE';

  // The four keys that leaked credentials before the fix. If any of these
  // ever reappear in a built URL, this suite fails loudly.
  const forbiddenKeys = [
    'token',
    'access_token',
    'refresh_token',
    'refreshToken',
  ];

  Map<String, String> queryOf(String url) {
    return Uri.parse(url).queryParameters;
  }

  group('buildEmbeddedUrl — marketing config', () {
    test('keeps embed + layout flags', () {
      final url = buildEmbeddedUrl(
        baseUrl: marketingBase,
        route: '/dashboard',
        hideSidebar: true,
        hideTopbar: false,
      );
      final q = queryOf(url);
      expect(q['embed'], 'true');
      expect(q['hideSidebar'], 'true');
      expect(q.containsKey('hideTopbar'), isFalse);
    });

    test('keeps backend/api base config params', () {
      final url = buildEmbeddedUrl(
        baseUrl: marketingBase,
        route: '/campaigns',
        apiBaseUrl: 'https://bomachauth.bgbot.app',
        backendUrl: 'https://bomachauth.bgbot.app',
      );
      final q = queryOf(url);
      expect(q['apiBaseUrl'], 'https://bomachauth.bgbot.app');
      expect(q['backendUrl'], 'https://bomachauth.bgbot.app');
    });

    test('NEVER contains any token query key even when tokens are passed',
        () {
      final url = buildEmbeddedUrl(
        baseUrl: marketingBase,
        route: '/dashboard',
        token: access,
        refreshToken: refresh,
      );
      for (final key in forbiddenKeys) {
        expect(queryOf(url).containsKey(key), isFalse,
            reason: 'credential leaked via "$key" in $url');
      }
      expect(url.contains(access), isFalse);
      expect(url.contains(refresh), isFalse);
    });

    test('normalizes base trailing slashes and route leading slash', () {
      final url = buildEmbeddedUrl(
        baseUrl: '$marketingBase/',
        route: 'pipeline',
      );
      expect(Uri.parse(url).host, 'marketing-wine-alpha.vercel.app');
      expect(Uri.parse(url).path, '/pipeline');
    });
  });

  group('buildEmbeddedUrl — services config', () {
    test('same contract: config params kept, zero token params', () {
      final url = buildEmbeddedUrl(
        baseUrl: servicesBase,
        route: '/app/invoices-payments',
        token: access,
        refreshToken: refresh,
        hideSidebar: true,
        hideTopbar: true,
      );
      final q = queryOf(url);
      expect(q['embed'], 'true');
      expect(q['hideSidebar'], 'true');
      expect(q['hideTopbar'], 'true');
      for (final key in forbiddenKeys) {
        expect(q.containsKey(key), isFalse,
            reason: 'credential leaked via "$key" in $url');
      }
    });
  });
}
