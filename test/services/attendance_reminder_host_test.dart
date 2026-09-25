import 'package:bomach_os/src/services/attendance_reminder_host.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('web reminders are not explicitly paused just because the PWA is hidden',
      () {
    expect(
      shouldPauseAttendanceReminders(AppLifecycleState.hidden, isWeb: true),
      isFalse,
    );
    expect(
      shouldPauseAttendanceReminders(AppLifecycleState.paused, isWeb: true),
      isFalse,
    );
    expect(
      shouldPauseAttendanceReminders(AppLifecycleState.detached, isWeb: true),
      isTrue,
    );
  });

  test('native reminders pause when the app is backgrounded', () {
    expect(
      shouldPauseAttendanceReminders(AppLifecycleState.hidden, isWeb: false),
      isTrue,
    );
    expect(
      shouldPauseAttendanceReminders(AppLifecycleState.paused, isWeb: false),
      isTrue,
    );
  });
}
