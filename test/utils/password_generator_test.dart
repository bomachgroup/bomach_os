import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/src/utils/password_generator.dart';

/// Spec (V2 fix, Batch 1d):
///
/// `generateStrongPassword({Random? rng, int length = 16})` produces a
/// password with:
///   - exact requested length (default 16)
///   - at least one lowercase, one uppercase, one digit, one symbol
///   - no ambiguous characters (O/0/l/I/1) to survive manual transcription
///   - deterministic under a seeded RNG (testability)
///   - high uniqueness across samples (no static default)
const unambiguousLower = 'abcdefghjkmnpqrstuvwxyz'; // no i, l, o
const unambiguousUpper = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // no I, O
const digits = '23456789'; // no 0, 1
const symbols = '!@#\$%&*?-+';

void main() {
  group('generateStrongPassword', () {
    test('default length is 16', () {
      final pw = generateStrongPassword();
      expect(pw.length, 16);
    });

    test('honors custom length', () {
      expect(generateStrongPassword(length: 20).length, 20);
      expect(generateStrongPassword(length: 12).length, 12);
    });

    test('contains at least one character of every class', () {
      for (var i = 0; i < 50; i++) {
        final pw = generateStrongPassword(rng: Random(42 + i));
        expect(pw.split('').any(unambiguousLower.contains), isTrue,
            reason: 'missing lowercase in $pw');
        expect(pw.split('').any(unambiguousUpper.contains), isTrue,
            reason: 'missing uppercase in $pw');
        expect(pw.split('').any(digits.contains), isTrue,
            reason: 'missing digit in $pw');
        expect(pw.split('').any(symbols.contains), isTrue,
            reason: 'missing symbol in $pw');
      }
    });

    test('never contains ambiguous characters', () {
      for (var i = 0; i < 100; i++) {
        final pw = generateStrongPassword();
        for (final c in ['O', '0', 'l', 'I', '1']) {
          expect(pw.contains(c), isFalse,
              reason: 'ambiguous char $c leaked into $pw');
        }
      }
    });

    test('deterministic under a seeded Random', () {
      final a = generateStrongPassword(rng: Random(7));
      final b = generateStrongPassword(rng: Random(7));
      expect(a, b);
    });

    test('differs across seeds', () {
      final a = generateStrongPassword(rng: Random(1));
      final b = generateStrongPassword(rng: Random(2));
      expect(a, isNot(b));
    });

    test('200 samples are unique (no hardcoded default)', () {
      final seen = <String>{};
      for (var i = 0; i < 200; i++) {
        seen.add(generateStrongPassword());
      }
      expect(seen.length, 200);

      // Regression guard for the audited vulnerability: the old hardcoded
      // value must never be producible.
      expect(seen.contains('Password123!'), isFalse);
    });
  });
}
