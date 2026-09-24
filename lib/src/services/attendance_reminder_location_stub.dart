import 'package:geolocator/geolocator.dart';

import 'attendance_reminder_contracts.dart';

AttendanceReminderLocationProvider createAttendanceReminderLocationProvider() =>
    _UnsupportedLocationProvider();

class _UnsupportedLocationProvider
    implements AttendanceReminderLocationProvider {
  @override
  Future<Position> requestPermissionAndGetPosition() => Future<Position>.error(
      UnsupportedError('Location reminders unavailable'));

  @override
  Future<bool> hasExistingPermission() async => false;

  @override
  Future<Position> getCurrentPosition() => Future<Position>.error(
      UnsupportedError('Location reminders unavailable'));

  @override
  Stream<Position> watchPositions() => const Stream<Position>.empty();
}
