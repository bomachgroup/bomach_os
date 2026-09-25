import 'dart:async';
import 'dart:developer' as developer;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../pages/hr/models/attendance_models.dart';
import '../../pages/hr/models/workspace_model.dart';
import 'attendance_reminder_contracts.dart';
import 'attendance_reminder_location_stub.dart'
    if (dart.library.js_interop) 'attendance_reminder_location_web.dart'
    as location_platform;
import 'attendance_reminder_notifications_stub.dart'
    if (dart.library.js_interop) 'attendance_reminder_notifications_web.dart'
    as notification_platform;
import 'biometric_api_service.dart';
import '../utils/wat_time.dart';

export 'attendance_reminder_contracts.dart';

/// Opt-in reminders for an active, authenticated BOMACH session.
///
/// Web monitoring is best-effort while the installed app remains running.
/// Browsers may throttle or suspend a background PWA; reliable delivery while
/// suspended requires server-sent Web Push.
class AttendanceReminderCoordinator extends GetxService {
  AttendanceReminderCoordinator({
    AttendanceReminderApi? api,
    AttendanceReminderLocationProvider? location,
    AttendanceReminderNotificationProvider? notifications,
    AttendanceReminderStore? store,
    FlutterSecureStorage? secureStorage,
    AttendanceReminderTokenReader? tokenReader,
    AttendanceReminderClock? now,
    InAppAttendanceReminder? inAppReminder,
    this.enablePeriodicChecks = true,
  })  : _api = api ?? _BiometricAttendanceReminderApi(BiometricApiService()),
        _location = location ??
            location_platform.createAttendanceReminderLocationProvider(),
        _notifications = notifications ??
            notification_platform
                .createAttendanceReminderNotificationProvider(),
        _store = store ?? SharedPreferencesAttendanceReminderStore(),
        _secureStorage = secureStorage ?? const FlutterSecureStorage(),
        _tokenReader = tokenReader,
        _now = now ?? WatTime.now,
        _inAppReminder = inAppReminder ?? _showInAppReminder;

  static const Duration _locationRefreshInterval = Duration(minutes: 15);
  static const Duration _serverTimeRefreshInterval = Duration(minutes: 10);
  static const Duration _clockOutCheckInterval = Duration(minutes: 5);
  static const Duration _periodicTickInterval = Duration(minutes: 1);
  static const double _exitBufferMinimumMeters = 25;
  static const double _maximumReminderAccuracyMeters = 50;
  static const int _minimumEffectiveWorkspaceRadiusMeters = 25;

  final AttendanceReminderApi _api;
  final AttendanceReminderLocationProvider _location;
  final AttendanceReminderNotificationProvider _notifications;
  final AttendanceReminderStore _store;
  final FlutterSecureStorage _secureStorage;
  final AttendanceReminderTokenReader? _tokenReader;
  final AttendanceReminderClock _now;
  final InAppAttendanceReminder _inAppReminder;
  final bool enablePeriodicChecks;

  final RxBool isEnabled = false.obs;
  final RxBool isEnabling = false.obs;
  final RxString statusMessage = ''.obs;

  int? _activeUserId;
  String? _activeToken;
  List<WorkspaceConfig> _usableWorkspaces = const [];
  Duration _serverTimeOffset = Duration.zero;
  DateTime? _lastServerTimeSync;
  DateTime? _lastLocationRefresh;
  DateTime? _lastClockOutCheck;
  StreamSubscription<Position>? _positionSubscription;
  Timer? _periodicTimer;
  bool _paused = false;
  final Set<String> _arrivalChecksInFlight = <String>{};
  final Set<String> _remindersInFlight = <String>{};

  DateTime get trustedTime => _now(_serverTimeOffset);

  /// Enables only after explicit user action and a successful location fix.
  /// Browser notifications are optional; in-app notices remain the fallback.
  Future<bool> enableForUser(int userId) async {
    if (userId <= 0 || isEnabling.value) return false;
    isEnabling.value = true;
    statusMessage.value = '';

    try {
      final token = await _readToken();
      if (token == null) {
        statusMessage.value = 'Please sign in again to enable reminders.';
        return false;
      }

      // Ask for notification permission directly from the toggle gesture,
      // before location permission and GPS acquisition introduce a long await.
      // Browsers may reject notification prompts without recent user activation.
      final notificationsGranted = await _notifications
          .requestPermission()
          .catchError((Object _) => false);
      final initialFix = await _location.requestPermissionAndGetPosition();

      await _store.setEnabled(userId, true);
      isEnabled.value = true;
      _activeUserId = userId;
      await _startMonitoring(userId, token, initialFix: initialFix);

      if (!notificationsGranted) {
        statusMessage.value =
            'Reminders are enabled. Browser notifications are unavailable, so reminders will appear in BOMACH while it is open.';
      } else if (statusMessage.value.isEmpty) {
        statusMessage.value =
            'Reminders are enabled. Background delivery is best-effort because browsers can suspend apps; reopening BOMACH checks for missed reminders.';
      }
      return true;
    } catch (error) {
      developer.log('Attendance reminder opt-in failed: $error');
      await _stopMonitoring();
      isEnabled.value = false;
      statusMessage.value = _locationFailureMessage(error);
      return false;
    } finally {
      isEnabling.value = false;
    }
  }

  /// Restores a prior opt-in after login or app resume. It never prompts for
  /// permission; revoked/unsupported permissions simply stop location checks.
  Future<void> resumeForUser(int userId) async {
    if (userId <= 0) return;
    final enabled = await _store.isEnabled(userId);
    isEnabled.value = enabled;
    if (!enabled) {
      if (_activeUserId == userId) await _stopMonitoring();
      return;
    }
    if (_activeUserId == userId && !_paused && _positionSubscription != null) {
      // A browser may throttle timers while the PWA is hidden without sending
      // a lifecycle transition. Always catch up on return to the foreground.
      await _checkRemindersOnResume(_activeToken!);
      return;
    }

    final token = await _readToken();
    if (token == null) {
      statusMessage.value = 'Please sign in again to resume reminders.';
      return;
    }

    _activeUserId = userId;
    final locationPermissionGranted = await _location.hasExistingPermission();
    await _startMonitoring(
      userId,
      token,
      locationPermissionGranted: locationPermissionGranted,
    );
  }

  Future<void> disableForUser(int userId) async {
    await _store.setEnabled(userId, false);
    if (_activeUserId == userId) {
      await _stopMonitoring();
    }
    isEnabled.value = false;
    statusMessage.value = 'Attendance reminders are off.';
  }

  /// Pauses location and timers while the browser/app is suspended.
  Future<void> pause() async {
    _paused = true;
    _periodicTimer?.cancel();
    _periodicTimer = null;
    await _cancelPositionSubscription();
  }

  /// Stops all active work on logout without removing the user's local opt-in.
  Future<void> stop() async {
    await _stopMonitoring();
    _activeUserId = null;
    _activeToken = null;
    isEnabled.value = false;
    statusMessage.value = '';
  }

  /// Retry action for transient workspace/attendance API failures.
  Future<void> retry() async {
    final userId = _activeUserId;
    final token = _activeToken;
    if (userId == null || token == null) return;
    await _refreshWorkspaces(token);
    await _refreshAttendance(token);
    try {
      final fix = await _location.getCurrentPosition();
      await _handlePosition(fix);
    } catch (error) {
      developer.log('Could not refresh reminder location: $error');
    }
  }

  /// Public for lifecycle hooks and deterministic tests. It always refreshes
  /// today's server attendance immediately before deciding whether to alert.
  Future<void> checkClockOutReminderNow() =>
      _checkClockOutReminder(forceRefresh: true);

  Future<void> _startMonitoring(
    int userId,
    String token, {
    Position? initialFix,
    bool locationPermissionGranted = true,
  }) async {
    await _stopMonitoring();
    _activeUserId = userId;
    _activeToken = token;
    _paused = false;
    isEnabled.value = true;

    await _syncServerTime(token);
    await _refreshWorkspaces(token);
    await _refreshAttendance(token);

    Position? fix = initialFix;
    if (locationPermissionGranted && fix == null) {
      try {
        fix = await _location.getCurrentPosition();
      } catch (error) {
        statusMessage.value =
            'Location reminders are paused because your current location is unavailable.';
        developer.log('Attendance reminder location unavailable: $error');
      }
    }
    if (fix != null) await _handlePosition(fix);

    if (locationPermissionGranted) {
      try {
        _positionSubscription = _location.watchPositions().listen(
          (position) => unawaited(_handlePosition(position)),
          onError: (Object error) {
            statusMessage.value =
                'Location reminders paused: ${_locationFailureMessage(error)}';
          },
        );
      } catch (error) {
        statusMessage.value =
            'Location reminders are unavailable in this browser session.';
        developer.log('Could not start attendance location watch: $error');
      }
    } else {
      statusMessage.value =
          'Location permission is unavailable. Turn reminders off, then enable them again to request access. Clock-out reminders remain active.';
    }

    _lastLocationRefresh = trustedTime;
    if (enablePeriodicChecks) {
      _periodicTimer = Timer.periodic(
        _periodicTickInterval,
        (_) => unawaited(_periodicTick()),
      );
    }
    await _checkClockOutReminder(forceRefresh: true);
  }

  Future<void> _periodicTick() async {
    final token = _activeToken;
    if (token == null || _paused) return;

    final now = trustedTime;
    if (_lastServerTimeSync == null ||
        now.difference(_lastServerTimeSync!) >= _serverTimeRefreshInterval) {
      await _syncServerTime(token);
    }
    if (_lastLocationRefresh == null ||
        trustedTime.difference(_lastLocationRefresh!) >=
            _locationRefreshInterval) {
      await _refreshWorkspaces(token);
      _lastLocationRefresh = trustedTime;
    }
    await _checkClockOutReminder(forceRefresh: false);
  }

  Future<void> _checkRemindersOnResume(String token) async {
    await _syncServerTime(token);
    await _refreshWorkspaces(token);
    try {
      await _handlePosition(await _location.getCurrentPosition());
    } catch (error) {
      developer.log('Could not refresh reminder location on resume: $error');
    }
    await _checkClockOutReminder(forceRefresh: true);
  }

  Future<void> _syncServerTime(String token) async {
    try {
      _serverTimeOffset = await _api.fetchServerTimeOffset(token);
      _lastServerTimeSync = trustedTime;
    } catch (error) {
      // Keep the last verified offset and use the device clock only when no
      // server time has ever been available.
      developer.log('Attendance reminder server-time sync failed: $error');
      _lastServerTimeSync ??= trustedTime;
    }
  }

  Future<void> _refreshWorkspaces(String token) async {
    try {
      final workspaces = await _api.fetchWorkspaces(token);
      final eligible = workspaces.where((workspace) {
        return workspace.canClockIn &&
            workspace.latitude.isFinite &&
            workspace.longitude.isFinite;
      }).toList(growable: false);
      final userId = _activeUserId;
      if (userId != null) {
        final nextKeys = eligible.map(_workspaceKey).toSet();
        for (final previous in _usableWorkspaces) {
          final previousKey = _workspaceKey(previous);
          if (!nextKeys.contains(previousKey)) {
            await _store.setInside(
              userId,
              previousKey,
              _dateKey(trustedTime),
              false,
            );
          }
        }
      }
      _usableWorkspaces = eligible;
      if (statusMessage.value.contains('approved workspaces')) {
        statusMessage.value = '';
      }
      if (_usableWorkspaces.isEmpty && isEnabled.value) {
        statusMessage.value =
            'No approved workspaces are currently eligible for location reminders.';
      }
    } catch (error) {
      _usableWorkspaces = const [];
      statusMessage.value =
          'Could not load approved workspaces for reminders. Select Retry to try again.';
      developer.log('Attendance reminder workspace load failed: $error');
    }
  }

  Future<void> _refreshAttendance(String token) async {
    try {
      await _api.fetchAttendanceRecords(token);
    } catch (error) {
      developer.log('Attendance reminder history preload failed: $error');
    }
  }

  Future<void> _handlePosition(Position position) async {
    final userId = _activeUserId;
    final token = _activeToken;
    if (userId == null || token == null || _paused) return;
    if (!position.accuracy.isFinite ||
        position.accuracy > _maximumReminderAccuracyMeters) {
      return;
    }

    for (final workspace in _usableWorkspaces) {
      final workspaceKey = _workspaceKey(workspace);
      final date = _dateKey(trustedTime);
      final distance = Geolocator.distanceBetween(
        position.latitude,
        position.longitude,
        workspace.latitude,
        workspace.longitude,
      );
      final radius = math
          .max(
            workspace.radiusMeters,
            _minimumEffectiveWorkspaceRadiusMeters,
          )
          .toDouble();
      final wasInside = await _store.isInside(userId, workspaceKey, date);

      if (distance <= radius) {
        if (wasInside) continue;
        if (!_arrivalChecksInFlight.add(workspaceKey)) continue;
        try {
          final state = await _fetchTodayAttendance(token);
          if (state == null) continue;
          if (state.hasClockedIn) {
            await _store.setInside(userId, workspaceKey, date, true);
            continue;
          }
          final delivered = await _notify(
            'workspace:$workspaceKey:$date',
            'Workspace nearby',
            'You are near ${workspace.workspaceName}. Remember to clock in when your workday starts.',
          );
          if (delivered) {
            await _store.setInside(userId, workspaceKey, date, true);
          }
        } finally {
          _arrivalChecksInFlight.remove(workspaceKey);
        }
      } else {
        final exitBuffer = math.max(
          _exitBufferMinimumMeters,
          radius * 0.5,
        );
        if (wasInside && distance > radius + exitBuffer) {
          await _store.setInside(userId, workspaceKey, date, false);
        }
      }
    }
  }

  Future<_TodayAttendanceState?> _fetchTodayAttendance(String token) async {
    try {
      final records = await _api.fetchAttendanceRecords(token);
      if (statusMessage.value.contains('Could not verify today’s attendance')) {
        statusMessage.value = '';
      }
      return _todayStateFrom(records, _dateKey(trustedTime));
    } catch (error) {
      statusMessage.value =
          'Could not verify today’s attendance, so no location reminder was sent.';
      developer.log('Could not verify attendance before reminder: $error');
      return null;
    }
  }

  Future<void> _checkClockOutReminder({required bool forceRefresh}) async {
    final userId = _activeUserId;
    final token = _activeToken;
    if (userId == null || token == null || _paused) return;

    final now = trustedTime;
    if (now.hour < 17) return;
    final date = _dateKey(now);
    final reminderKey = '$userId:$date';
    if (await _store.wasClockOutReminderSent(userId, date) ||
        _remindersInFlight.contains(reminderKey)) {
      return;
    }
    if (!forceRefresh &&
        _lastClockOutCheck != null &&
        now.difference(_lastClockOutCheck!) < _clockOutCheckInterval) {
      return;
    }
    _lastClockOutCheck = now;
    if (!_remindersInFlight.add(reminderKey)) return;

    try {
      final state = await _fetchTodayAttendance(token);
      if (state == null) return;
      if (state.hasClockedIn && state.hasClockedOut) {
        // The shift is complete; there is no clock-out reminder to send today.
        await _store.markClockOutReminderSent(userId, date);
        return;
      }
      if (!state.hasClockedIn) return;

      final delivered = await _notify(
        'clock-out:$date',
        'Clock out reminder',
        'It is after 5:00pm WAT. Please clock out if your workday is finished.',
      );
      if (!delivered) return;
      await _store.markClockOutReminderSent(userId, date);
    } finally {
      _remindersInFlight.remove(reminderKey);
    }
  }

  Future<bool> _notify(
    String tag,
    String title,
    String body,
  ) async {
    var delivered = false;
    try {
      delivered = await _notifications.showNotification(
        title: title,
        body: body,
        tag: tag,
      );
    } catch (error) {
      developer.log('Browser attendance notification failed: $error');
    }
    if (delivered) return true;
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    if (lifecycle == AppLifecycleState.hidden ||
        lifecycle == AppLifecycleState.paused ||
        lifecycle == AppLifecycleState.detached) {
      return false;
    }
    _inAppReminder(title, body);
    return true;
  }

  _TodayAttendanceState _todayStateFrom(
    List<Map<String, dynamic>> rawRecords,
    String dateKey,
  ) {
    var hasClockIn = false;
    var hasClockOut = false;
    for (final raw in rawRecords) {
      final record = BiometricAttendanceRecord.fromJson(raw);
      if (DateFormat('yyyy-MM-dd').format(record.timestamp) != dateKey) {
        continue;
      }
      if (record.attendanceType == 'CLOCK_IN') hasClockIn = true;
      if (record.attendanceType == 'CLOCK_OUT') hasClockOut = true;
    }
    return _TodayAttendanceState(
      hasClockedIn: hasClockIn,
      hasClockedOut: hasClockOut,
    );
  }

  String _dateKey(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  String _workspaceKey(WorkspaceConfig workspace) {
    if (workspace.id != null) return 'id-${workspace.id}';
    return '${workspace.workspaceName}:${workspace.latitude.toStringAsFixed(5)}:${workspace.longitude.toStringAsFixed(5)}';
  }

  Future<String?> _readToken() async {
    final raw = _tokenReader == null
        ? await _secureStorage.read(key: 'access_token')
        : await _tokenReader();
    if (raw == null || raw.trim().isEmpty) return null;
    return raw
        .replaceFirst(RegExp(r'^Bearer\s+', caseSensitive: false), '')
        .replaceAll('"', '')
        .trim();
  }

  String _locationFailureMessage(Object error) {
    final message = error.toString().toLowerCase();
    if (message.contains('denied') || message.contains('permission')) {
      return 'Location permission is needed for workspace reminders. You can enable it in your browser settings and try again.';
    }
    return 'Could not access your location. Check that location is available, then try again.';
  }

  Future<void> _stopMonitoring() async {
    _periodicTimer?.cancel();
    _periodicTimer = null;
    await _cancelPositionSubscription();
    _usableWorkspaces = const [];
    _activeToken = null;
    _paused = true;
  }

  Future<void> _cancelPositionSubscription() async {
    final subscription = _positionSubscription;
    _positionSubscription = null;
    await subscription?.cancel();
  }

  static void _showInAppReminder(String title, String body) {
    Get.snackbar(
      title,
      body,
      snackPosition: SnackPosition.TOP,
      duration: const Duration(seconds: 8),
      margin: const EdgeInsets.all(16),
    );
  }
}

class _TodayAttendanceState {
  const _TodayAttendanceState({
    required this.hasClockedIn,
    required this.hasClockedOut,
  });

  final bool hasClockedIn;
  final bool hasClockedOut;
}

class _BiometricAttendanceReminderApi implements AttendanceReminderApi {
  _BiometricAttendanceReminderApi(this._api);

  final BiometricApiService _api;

  @override
  Future<List<WorkspaceConfig>> fetchWorkspaces(String token) async {
    final rows = await _api.getWorkspaces(token);
    return rows.map(WorkspaceConfig.fromJson).toList(growable: false);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchAttendanceRecords(
    String token,
  ) =>
      _api.getMyAttendanceRecords(token, limit: 100);

  @override
  Future<Duration> fetchServerTimeOffset(String token) async {
    final response = await _api.getRawStatusResponse(token: token);
    final value = response.headers.value('date');
    if (value == null || value.trim().isEmpty) return Duration.zero;
    final serverUtc = DateFormat("EEE, dd MMM yyyy HH:mm:ss 'GMT'", 'en_US')
        .parseUtc(value.trim());
    return serverUtc.difference(DateTime.now().toUtc());
  }
}

class SharedPreferencesAttendanceReminderStore
    implements AttendanceReminderStore {
  SharedPreferencesAttendanceReminderStore({
    Future<SharedPreferences> Function()? preferencesFactory,
  }) : _preferencesFactory =
            preferencesFactory ?? SharedPreferences.getInstance;

  final Future<SharedPreferences> Function() _preferencesFactory;
  Future<SharedPreferences>? _preferences;

  Future<SharedPreferences> get _prefs =>
      _preferences ??= _preferencesFactory();

  @override
  Future<bool> isEnabled(int userId) async =>
      (await _prefs).getBool('attendance_reminders_enabled_$userId') ?? false;

  @override
  Future<void> setEnabled(int userId, bool enabled) async {
    await (await _prefs)
        .setBool('attendance_reminders_enabled_$userId', enabled);
  }

  @override
  Future<bool> isInside(
    int userId,
    String workspaceKey,
    String watDate,
  ) async {
    final prefs = await _prefs;
    return prefs.getString(_insideDateKey(userId, workspaceKey)) == watDate &&
        (prefs.getBool(_insideKey(userId, workspaceKey)) ?? false);
  }

  @override
  Future<void> setInside(
    int userId,
    String workspaceKey,
    String watDate,
    bool inside,
  ) async {
    final prefs = await _prefs;
    await prefs.setString(_insideDateKey(userId, workspaceKey), watDate);
    await prefs.setBool(_insideKey(userId, workspaceKey), inside);
  }

  @override
  Future<bool> wasClockOutReminderSent(int userId, String watDate) async =>
      (await _prefs).getBool(_clockOutKey(userId, watDate)) ?? false;

  @override
  Future<void> markClockOutReminderSent(int userId, String watDate) async {
    await (await _prefs).setBool(_clockOutKey(userId, watDate), true);
  }

  String _insideKey(int userId, String workspaceKey) =>
      'attendance_reminder_inside_${userId}_${Uri.encodeComponent(workspaceKey)}';

  String _insideDateKey(int userId, String workspaceKey) =>
      'attendance_reminder_inside_date_${userId}_${Uri.encodeComponent(workspaceKey)}';

  String _clockOutKey(int userId, String date) =>
      'attendance_clock_out_reminder_${userId}_$date';
}
