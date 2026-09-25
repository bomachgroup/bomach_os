import 'dart:async';

import 'package:bomach_os/pages/hr/models/workspace_model.dart';
import 'package:bomach_os/src/services/attendance_reminder_coordinator.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  late _FakeReminderApi api;
  late _FakeLocationProvider location;
  late _FakeNotifier notifier;
  late _FakeReminderStore store;
  late DateTime now;
  late bool inAppAvailable;
  late AttendanceReminderCoordinator coordinator;

  Position fix({
    double latitude = 6.0,
    double longitude = 3.0,
    double accuracy = 10,
  }) =>
      Position(
        longitude: longitude,
        latitude: latitude,
        timestamp: DateTime.utc(2026, 9, 24, 8),
        accuracy: accuracy,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        headingAccuracy: 0,
        speed: 0,
        speedAccuracy: 0,
      );

  WorkspaceConfig workspace({bool usable = true}) => WorkspaceConfig(
        id: 8,
        workspaceName: 'Office',
        latitude: 6,
        longitude: 3,
        radiusMeters: 100,
        canBeUsed: usable,
      );

  Future<void> flushEvents() => Future<void>.delayed(Duration.zero);

  setUp(() {
    api = _FakeReminderApi()..workspaces = [workspace()];
    location = _FakeLocationProvider()..firstFix = fix();
    notifier = _FakeNotifier();
    store = _FakeReminderStore();
    inAppAvailable = true;
    now = DateTime(2026, 9, 24, 16, 30);
    coordinator = AttendanceReminderCoordinator(
      api: api,
      location: location,
      notifications: notifier,
      store: store,
      tokenReader: () async => 'test-token',
      now: (offset) => now.add(offset),
      enablePeriodicChecks: false,
      inAppReminder: (title, message) {
        if (!inAppAvailable) return;
        notifier.inAppMessages.add('$title: $message');
      },
    );
  });

  tearDown(() async {
    await coordinator.stop();
    await location.dispose();
  });

  test('requests permissions only on opt-in and deduplicates each arrival',
      () async {
    final permissionOrder = <String>[];
    location.onPermissionRequested = () => permissionOrder.add('location');
    notifier.onPermissionRequested = () => permissionOrder.add('notification');
    expect(location.permissionRequests, 0);
    expect(notifier.permissionRequests, 0);

    expect(await coordinator.enableForUser(42), isTrue);
    expect(permissionOrder, ['notification', 'location']);
    expect(location.permissionRequests, 1);
    expect(notifier.permissionRequests, 1);
    expect(await store.isEnabled(42), isTrue);
    expect(notifier.messages, hasLength(1));
    expect(api.attendanceRequests, greaterThanOrEqualTo(2));

    location.emit(fix(latitude: 6.0001));
    await flushEvents();
    expect(notifier.messages, hasLength(1));

    location.emit(fix(latitude: 6.002));
    await flushEvents();
    location.emit(fix(latitude: 6.0001));
    await flushEvents();
    expect(notifier.messages, hasLength(2));
  });

  test('a prior-day inside state does not suppress today’s arrival alert',
      () async {
    await store.setInside(42, 'id-8', '2026-09-24', true);
    now = DateTime(2026, 9, 25, 8);

    expect(await coordinator.enableForUser(42), isTrue);

    expect(notifier.messages, hasLength(1));
    expect(notifier.messages.single.$1, 'Workspace nearby');
  });

  test('location denial does not enable monitoring', () async {
    location.permissionError = StateError('permission denied');

    expect(await coordinator.enableForUser(42), isFalse);
    expect(await store.isEnabled(42), isFalse);
    expect(coordinator.isEnabled.value, isFalse);
    expect(notifier.messages, isEmpty);
  });

  test('uses an in-app reminder when browser notification permission is denied',
      () async {
    notifier.permissionGranted = false;

    expect(await coordinator.enableForUser(42), isTrue);
    expect(notifier.messages, isEmpty);
    expect(notifier.inAppMessages, hasLength(1));
  });

  test('ignores inaccurate fixes and workspaces the backend marks unusable',
      () async {
    location.firstFix = fix(accuracy: 90);
    api.workspaces = [workspace(usable: false)];

    expect(await coordinator.enableForUser(42), isTrue);
    location.emit(fix(accuracy: 70));
    await flushEvents();

    expect(notifier.messages, isEmpty);
    expect(notifier.inAppMessages, isEmpty);
  });

  test('rechecks workspaces after a temporary workspace-load failure',
      () async {
    api.workspaceFailure = true;

    expect(await coordinator.enableForUser(42), isTrue);
    expect(coordinator.statusMessage.value, contains('approved workspaces'));
    expect(notifier.messages, isEmpty);

    api.workspaceFailure = false;
    await coordinator.retry();
    location.emit(fix());
    await flushEvents();

    expect(notifier.messages, hasLength(1));
  });

  test('sends one 5pm reminder only for an active shift using server time',
      () async {
    now = DateTime(2026, 9, 24, 16, 59);
    api.serverOffset = const Duration(minutes: 2);
    api.attendanceRecords = [
      {'attendance_type': 'CLOCK_IN', 'timestamp': '2026-09-24T07:00:00Z'},
    ];
    location.firstFix = fix(latitude: 6.01);

    expect(await coordinator.enableForUser(42), isTrue);
    await coordinator.checkClockOutReminderNow();

    expect(
        notifier.messages
            .where((message) => message.$1 == 'Clock out reminder'),
        hasLength(1));
    await coordinator.checkClockOutReminderNow();
    expect(
        notifier.messages
            .where((message) => message.$1 == 'Clock out reminder'),
        hasLength(1));
  });

  testWidgets(
      'does not consume the daily clock-out reminder when the PWA is hidden and delivery fails',
      (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    now = DateTime(2026, 9, 24, 17, 1);
    location.firstFix = fix(latitude: 6.01);
    api.attendanceRecords = [
      {'attendance_type': 'CLOCK_IN', 'timestamp': '2026-09-24T07:00:00Z'},
    ];
    notifier.permissionGranted = false;
    inAppAvailable = false;

    expect(await coordinator.enableForUser(42), isTrue);
    expect(notifier.inAppMessages, isEmpty);

    notifier.permissionGranted = true;
    inAppAvailable = true;
    await coordinator.checkClockOutReminderNow();

    expect(
      notifier.messages.where((message) => message.$1 == 'Clock out reminder'),
      hasLength(1),
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
  });

  test('does not remind before 5pm, without clock-in, or after clock-out',
      () async {
    location.firstFix = fix(latitude: 6.01);
    api.attendanceRecords = [
      {'attendance_type': 'CLOCK_IN', 'timestamp': '2026-09-24T07:00:00Z'},
      {'attendance_type': 'CLOCK_OUT', 'timestamp': '2026-09-24T16:00:00Z'},
    ];

    expect(await coordinator.enableForUser(42), isTrue);
    await coordinator.checkClockOutReminderNow();
    expect(notifier.messages, isEmpty);

    now = DateTime(2026, 9, 24, 17, 1);
    api.attendanceRecords = [];
    await coordinator.checkClockOutReminderNow();
    expect(notifier.messages, isEmpty);

    api.attendanceRecords = [
      {'attendance_type': 'CLOCK_IN', 'timestamp': '2026-09-24T07:00:00Z'},
      {'attendance_type': 'CLOCK_OUT', 'timestamp': '2026-09-24T16:00:00Z'},
    ];
    await coordinator.checkClockOutReminderNow();
    expect(notifier.messages, isEmpty);
  });

  test('opt-out stops location monitoring and clears the enabled preference',
      () async {
    await coordinator.enableForUser(42);
    await coordinator.disableForUser(42);

    expect(await store.isEnabled(42), isFalse);
    expect(coordinator.isEnabled.value, isFalse);
    expect(location.cancelled, isTrue);
  });

  test('resuming after 5pm rechecks attendance and sends a missed reminder',
      () async {
    location.firstFix = fix(latitude: 6.01);
    api.attendanceRecords = [
      {'attendance_type': 'CLOCK_IN', 'timestamp': '2026-09-24T07:00:00Z'},
    ];
    await coordinator.enableForUser(42);
    await coordinator.pause();

    location.permissionGranted = false;
    now = DateTime(2026, 9, 24, 17, 10);
    await coordinator.resumeForUser(42);

    expect(
      notifier.messages.where((message) => message.$1 == 'Clock out reminder'),
      hasLength(1),
    );
    expect(location.permissionRequests, 1,
        reason: 'resume must not re-prompt for location permission');
  });

  test('foreground resume rechecks after background execution was throttled',
      () async {
    location.firstFix = fix(latitude: 6.01);
    api.attendanceRecords = [
      {'attendance_type': 'CLOCK_IN', 'timestamp': '2026-09-24T07:00:00Z'},
    ];
    await coordinator.enableForUser(42);

    now = DateTime(2026, 9, 24, 17, 10);
    await coordinator.resumeForUser(42);

    expect(
      notifier.messages.where((message) => message.$1 == 'Clock out reminder'),
      hasLength(1),
    );
  });

  test('does not request permissions when the session token is unavailable',
      () async {
    coordinator = AttendanceReminderCoordinator(
      api: api,
      location: location,
      notifications: notifier,
      store: store,
      tokenReader: () async => null,
      now: (offset) => now.add(offset),
      enablePeriodicChecks: false,
    );

    expect(await coordinator.enableForUser(42), isFalse);
    expect(location.permissionRequests, 0);
    expect(notifier.permissionRequests, 0);
    expect(await store.isEnabled(42), isFalse);
  });
}

class _FakeReminderApi implements AttendanceReminderApi {
  List<WorkspaceConfig> workspaces = [];
  List<Map<String, dynamic>> attendanceRecords = [];
  bool workspaceFailure = false;
  Duration serverOffset = Duration.zero;
  int attendanceRequests = 0;

  @override
  Future<List<WorkspaceConfig>> fetchWorkspaces(String token) async {
    if (workspaceFailure) throw StateError('temporary workspace failure');
    return workspaces;
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAttendanceRecords(
      String token) async {
    attendanceRequests++;
    return attendanceRecords;
  }

  @override
  Future<Duration> fetchServerTimeOffset(String token) async => serverOffset;
}

class _FakeLocationProvider implements AttendanceReminderLocationProvider {
  late final StreamController<Position> _positions =
      StreamController<Position>.broadcast(onCancel: () => cancelled = true);
  int permissionRequests = 0;
  void Function()? onPermissionRequested;
  Position firstFix = Position(
    longitude: 0,
    latitude: 0,
    timestamp: DateTime.utc(2026),
    accuracy: 10,
    altitude: 0,
    altitudeAccuracy: 0,
    heading: 0,
    headingAccuracy: 0,
    speed: 0,
    speedAccuracy: 0,
  );
  Object? permissionError;
  bool permissionGranted = true;
  bool cancelled = false;

  Stream<Position> get positions => _positions.stream;

  void emit(Position position) => _positions.add(position);

  @override
  Future<Position> requestPermissionAndGetPosition() async {
    onPermissionRequested?.call();
    permissionRequests++;
    if (permissionError case final error?) throw error;
    return firstFix;
  }

  @override
  Future<bool> hasExistingPermission() async => permissionGranted;

  @override
  Future<Position> getCurrentPosition() async => firstFix;

  @override
  Stream<Position> watchPositions() => positions;

  Future<void> dispose() => _positions.close();
}

class _FakeNotifier implements AttendanceReminderNotificationProvider {
  int permissionRequests = 0;
  void Function()? onPermissionRequested;
  bool permissionGranted = true;
  final messages = <(String, String)>[];
  final inAppMessages = <String>[];

  @override
  Future<bool> requestPermission() async {
    onPermissionRequested?.call();
    permissionRequests++;
    return permissionGranted;
  }

  @override
  Future<bool> showNotification({
    required String title,
    required String body,
    required String tag,
  }) async {
    if (!permissionGranted) return false;
    messages.add((title, body));
    return true;
  }
}

class _FakeReminderStore implements AttendanceReminderStore {
  final _enabled = <int, bool>{};
  final _inside = <String, (String, bool)>{};
  final _clockOutSent = <String>{};

  @override
  Future<bool> isEnabled(int userId) async => _enabled[userId] ?? false;

  @override
  Future<void> setEnabled(int userId, bool enabled) async =>
      _enabled[userId] = enabled;

  @override
  Future<bool> isInside(int userId, String workspaceKey, String watDate) async {
    final entry = _inside['$userId:$workspaceKey'];
    return entry != null && entry.$1 == watDate && entry.$2;
  }

  @override
  Future<void> setInside(
    int userId,
    String workspaceKey,
    String watDate,
    bool inside,
  ) async =>
      _inside['$userId:$workspaceKey'] = (watDate, inside);

  @override
  Future<bool> wasClockOutReminderSent(int userId, String watDate) async =>
      _clockOutSent.contains('$userId:$watDate');

  @override
  Future<void> markClockOutReminderSent(int userId, String watDate) async =>
      _clockOutSent.add('$userId:$watDate');
}
