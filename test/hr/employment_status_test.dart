import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/src/model/employees_model.dart';

/// Spec (B6 fix, Batch 7c) — the suspended-status data-corruption bug:
///
/// `resolveEmploymentStatus` seeds the Edit-Employee status dropdown from
/// the model's REAL employment status instead of collapsing everything
/// through the boolean `isActive`. Contract:
///   - known statuses ('active', 'inactive', 'suspended') pass through
///     case-normalized, regardless of isActive
///   - unknown/legacy values (e.g. 'on_leave') ALSO pass through so a save
///     round-trip can never silently rewrite them
///   - only when the model has no usable status does the boolean decide:
///     isActive → 'active', else 'inactive'
void main() {
  group('resolveEmploymentStatus', () {
    test('preserves suspended (THE CORRUPTION BUG)', () {
      expect(resolveEmploymentStatus('suspended', false), 'suspended');
      expect(resolveEmploymentStatus('Suspended', false), 'suspended');
    });

    test('preserves active/inactive with case normalization', () {
      expect(resolveEmploymentStatus('ACTIVE', true), 'active');
      expect(resolveEmploymentStatus('Inactive', false), 'inactive');
    });

    test('unknown legacy values pass through untouched (save-safe)', () {
      expect(resolveEmploymentStatus('on_leave', false), 'on_leave');
      expect(resolveEmploymentStatus('probation', true), 'probation');
    });

    test('falls back to boolean mapping only when status is unusable', () {
      expect(resolveEmploymentStatus(null, true), 'active');
      expect(resolveEmploymentStatus(null, false), 'inactive');
      expect(resolveEmploymentStatus('', true), 'active');
      expect(resolveEmploymentStatus('', false), 'inactive');
    });
  });

  group('knownEmploymentStatusOptions', () {
    test('includes suspended in the offered dropdown options', () {
      expect(knownEmploymentStatusOptions, containsAll(
        <String>['active', 'inactive', 'suspended'],
      ));
    });

    test('dropdown options always include an unknown current value',
        () {
      // The widget builds its option list as: known list + current value
      // when unknown. This helper must make that composition trivial and
      // consistent.
      final options =
          buildStatusOptions(currentValue: 'secondment');
      expect(options, contains('secondment'));
      expect(options.length, knownEmploymentStatusOptions.length + 1);
    });
  });
}
