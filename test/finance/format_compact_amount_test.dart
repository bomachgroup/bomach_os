import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/pages/finance/controllers/finance_dashboard_controller.dart';

/// Spec (B3 fix, Batch 8):
///
/// `formatCompactAmount` is a top-level pure function replacing the private
/// `_fmt`. Tiers:
///   - amount >= 1,000,000 → M with one decimal  (NEW — was missing, which
///     rendered ₦2,500,000 as "2500K")
///   - amount >= 100,000   → K with zero decimals
///   - otherwise           → plain integer string
void main() {
  group('formatCompactAmount', () {
    test('millions tier renders M with one decimal (the fixed bug)', () {
      expect(formatCompactAmount(2500000), '2.5M');
      expect(formatCompactAmount(1000000), '1.0M');
      expect(formatCompactAmount(12340000), '12.3M');
      expect(formatCompactAmount(9999999), '10.0M');
      expect(formatCompactAmount(150000000), '150.0M');
    });

    test('thousands tier renders K with zero decimals below 1M', () {
      expect(formatCompactAmount(950000), '950K');
      expect(formatCompactAmount(100000), '100K');
      expect(formatCompactAmount(999999), '1000K'); // documented boundary
    });

    test('below 100k renders plain integer', () {
      expect(formatCompactAmount(99999), '99999');
      expect(formatCompactAmount(0), '0');
      expect(formatCompactAmount(42), '42');
    });

    test('tier boundaries land in the correct bucket', () {
      expect(formatCompactAmount(99999.99), '99999');
      expect(formatCompactAmount(100000), '100K');
      expect(formatCompactAmount(999999), '1000K');
      expect(formatCompactAmount(1000000), '1.0M');
    });
  });
}
