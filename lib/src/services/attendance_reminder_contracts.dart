import 'package:geolocator/geolocator.dart';

import '../../pages/hr/models/workspace_model.dart';

abstract interface class AttendanceReminderApi {
  Future<List<WorkspaceConfig>> fetchWorkspaces(String token);

  Future<List<Map<String, dynamic>>> fetchAttendanceRecords(String token);

  Future<Duration> fetchServerTimeOffset(String token);
}

abstract interface class AttendanceReminderLocationProvider {
  /// Requests permission through a browser geolocation call and returns its
  /// initial fix. Call only as a result of the user's opt-in action.
  Future<Position> requestPermissionAndGetPosition();

  /// Reads permission without opening a browser prompt.
  Future<bool> hasExistingPermission();

  Future<Position> getCurrentPosition();

  Stream<Position> watchPositions();
}

abstract interface class AttendanceReminderNotificationProvider {
  Future<bool> requestPermission();

  /// Returns true only when a browser notification was actually displayed.
  Future<bool> showNotification({
    required String title,
    required String body,
    required String tag,
  });
}

abstract interface class AttendanceReminderStore {
  Future<bool> isEnabled(int userId);

  Future<void> setEnabled(int userId, bool enabled);

  Future<bool> isInside(int userId, String workspaceKey);

  Future<void> setInside(int userId, String workspaceKey, bool inside);

  Future<bool> wasClockOutReminderSent(int userId, String watDate);

  Future<void> markClockOutReminderSent(int userId, String watDate);
}

typedef AttendanceReminderClock = DateTime Function(Duration serverOffset);
typedef InAppAttendanceReminder = void Function(String title, String body);
typedef AttendanceReminderTokenReader = Future<String?> Function();
