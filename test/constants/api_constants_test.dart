import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/src/constants/api_constants.dart';

/// Spec (V5 fix, Batch 4):
///
/// Staging backend is selected ONLY for an exact-host allowlist:
///   - 'localhost'
///   - '127.0.0.1'
///   - 'bomach-os-test.web.app'
/// Everything else — including hosts that merely CONTAIN the word "test" —
/// must fail closed to PRODUCTION.
///
/// Non-web builds keep the existing kReleaseMode split:
///   - release → prod, debug/profile → staging.
void main() {
  group('isStagingHost', () {
    test('exact allowlist maps to staging', () {
      expect(ApiConstants.isStagingHost('localhost'), isTrue);
      expect(ApiConstants.isStagingHost('127.0.0.1'), isTrue);
      expect(ApiConstants.isStagingHost('bomach-os-test.web.app'), isTrue);
    });

    test('matching is case-insensitive', () {
      expect(ApiConstants.isStagingHost('LOCALHOST'), isTrue);
      expect(ApiConstants.isStagingHost('BOMACH-OS-TEST.WEB.APP'), isTrue);
    });

    test('substring matches are REJECTED (fail closed to prod)', () {
      // The old bug: host.contains('test') matched these.
      expect(ApiConstants.isStagingHost('evil-test.attacker.com'), isFalse);
      expect(ApiConstants.isStagingHost('latest.bomach-os-app.web.app'),
          isFalse);
      expect(
          ApiConstants.isStagingHost('test.web.app.evil.com'), isFalse);
      // The old tautology: host.isNotEmpty made everything else "prod
      // allowed"; these are simply not staging.
      expect(ApiConstants.isStagingHost('bomach-os-app.web.app'), isFalse);
      expect(ApiConstants.isStagingHost('attestation.example.com'), isFalse);
    });

    test('empty host is not staging', () {
      expect(ApiConstants.isStagingHost(''), isFalse);
    });
  });

  group('resolveApiBase (web)', () {
    const prod = 'https://bomachauth.bgbot.app';
    const staging = 'https://bomachauthtest.bgbot.app';

    test('staging host → staging base', () {
      expect(
        ApiConstants.resolveApiBase(
            isWeb: true, isRelease: true, host: 'localhost'),
        staging,
      );
      expect(
        ApiConstants.resolveApiBase(
            isWeb: true, isRelease: true, host: '127.0.0.1'),
        staging,
      );
      expect(
        ApiConstants.resolveApiBase(
            isWeb: true, isRelease: true, host: 'bomach-os-test.web.app'),
        staging,
      );
    });

    test("host containing 'test' as substring → PROD (fail closed)", () {
      expect(
        ApiConstants.resolveApiBase(
            isWeb: true, isRelease: true, host: 'test-preview.vercel.app'),
        prod,
      );
      expect(
        ApiConstants.resolveApiBase(
            isWeb: true, isRelease: true, host: 'mytest-env.web.app'),
        prod,
      );
    });

    test('unknown/production hosts → PROD regardless of release mode', () {
      for (final host in [
        '',
        'bomach-os-app.web.app',
        'anything.example.com',
        'EVIL-TEST.attacker.com',
      ]) {
        expect(
          ApiConstants.resolveApiBase(
              isWeb: true, isRelease: true, host: host),
          prod,
          reason: 'host "$host" must hit prod',
        );
        expect(
          ApiConstants.resolveApiBase(
              isWeb: true, isRelease: false, host: host),
          prod,
          reason: 'host "$host" must hit prod even in debug',
        );
      }
    });
  });

  group('resolveApiBase (non-web)', () {
    const prod = 'https://bomachauth.bgbot.app';
    const staging = 'https://bomachauthtest.bgbot.app';

    test('release → prod, debug → staging (existing behavior kept)', () {
      expect(
        ApiConstants.resolveApiBase(
            isWeb: false, isRelease: true, host: ''),
        prod,
      );
      expect(
        ApiConstants.resolveApiBase(
            isWeb: false, isRelease: false, host: ''),
        staging,
      );
    });
  });

  test('live getters agree with the resolver in this test environment',
      () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    // flutter_test runs as a VM (non-web) debug environment.
    if (!kIsWeb && !kReleaseMode) {
      expect(ApiConstants.authBaseUrl, 'https://bomachauthtest.bgbot.app');
      expect(ApiConstants.operationsBaseUrl, ApiConstants.authBaseUrl);
    }
  });
}
