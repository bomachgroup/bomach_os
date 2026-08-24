import 'dart:math';

/// Audit V2 fix: generates a strong one-off password for newly created
/// associate accounts. Replaces the hardcoded `'Password123!'` default
/// that shipped inside the web bundle.
///
/// Contract (pinned by test/utils/password_generator_test.dart):
///   - exact requested length (default 16)
///   - at least one character from each class (lower/upper/digit/symbol)
///   - no visually ambiguous characters (O, 0, l, I, 1)
///   - deterministic under a seeded [Random]
const String _lower = 'abcdefghjkmnpqrstuvwxyz'; // no i, l, o
const String _upper = 'ABCDEFGHJKLMNPQRSTUVWXYZ'; // no I, O
const String _digits = '23456789'; // no 0, 1
const String _symbols = '!@#\$%&*?-+';

String generateStrongPassword({Random? rng, int length = 16}) {
  assert(length >= 8, 'passwords shorter than 8 chars are not strong');
  final random = rng ?? Random.secure();
  final all = _lower + _upper + _digits + _symbols;

  // Guarantee at least one of each class, then fill from the full set.
  final chars = <String>[
    _lower[random.nextInt(_lower.length)],
    _upper[random.nextInt(_upper.length)],
    _digits[random.nextInt(_digits.length)],
    _symbols[random.nextInt(_symbols.length)],
  ];
  for (var i = chars.length; i < length; i++) {
    chars.add(all[random.nextInt(all.length)]);
  }

  // Fisher-Yates shuffle so class positions are unpredictable.
  for (var i = chars.length - 1; i > 0; i--) {
    final j = random.nextInt(i + 1);
    final tmp = chars[i];
    chars[i] = chars[j];
    chars[j] = tmp;
  }
  return chars.join();
}
