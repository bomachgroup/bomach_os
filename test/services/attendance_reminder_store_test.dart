import 'package:bomach_os/src/services/attendance_reminder_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('persists opt-in, workspace entry, and daily clock-out deduplication',
      () async {
    SharedPreferences.setMockInitialValues({});
    final store = SharedPreferencesAttendanceReminderStore();

    expect(await store.isEnabled(71), isFalse);
    await store.setEnabled(71, true);
    await store.setInside(71, 'id-9', '2026-09-24', true);
    await store.markClockOutReminderSent(71, '2026-09-24');

    expect(await store.isEnabled(71), isTrue);
    expect(await store.isInside(71, 'id-9', '2026-09-24'), isTrue);
    expect(await store.isInside(71, 'id-9', '2026-09-25'), isFalse);
    expect(await store.wasClockOutReminderSent(71, '2026-09-24'), isTrue);
    expect(await store.wasClockOutReminderSent(72, '2026-09-24'), isFalse);
  });
}
