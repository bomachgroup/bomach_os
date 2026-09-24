import 'attendance_reminder_contracts.dart';

AttendanceReminderNotificationProvider
    createAttendanceReminderNotificationProvider() =>
        _UnsupportedNotificationProvider();

class _UnsupportedNotificationProvider
    implements AttendanceReminderNotificationProvider {
  @override
  Future<bool> requestPermission() async => false;

  @override
  Future<bool> showNotification({
    required String title,
    required String body,
    required String tag,
  }) async =>
      false;
}
