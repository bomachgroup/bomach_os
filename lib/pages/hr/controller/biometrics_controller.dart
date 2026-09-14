import 'dart:developer';

import 'package:bomach_os/src/services/biometric_api_service.dart';
import 'package:bomach_os/src/services/location_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import 'dart:io';

import '../widget/face_liveness_dialog.dart';

import '../models/attendance_models.dart';
import '../models/workspace_model.dart';
import '../models/clock_in_location_policy.dart';
import '../models/location_verification_result.dart';

class BiometricsController extends GetxController {
  final BiometricApiService _api = BiometricApiService();
  final LocationService _location = LocationService();

  var isLoading = false.obs;
  var isAuthenticating = false.obs;
  var authActionType = ''.obs;

  // Raw logs from API
  var rawRecords = <BiometricAttendanceRecord>[].obs;

  // Processed rows for the UI Table
  var dailyAttendanceList = <DailyAttendance>[].obs;

  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  // Workspaces — full list of the user's submissions (any status).
  var workspaces = <WorkspaceConfig>[].obs;
  var isFetchingWorkspace = false.obs;
  var isSettingUpWorkspace = false.obs;
  var isDeletingWorkspace = false.obs;

  /// First workspace in an approved & active state — the one used for clock-in.
  WorkspaceConfig? get approvedWorkspace =>
      workspaces.firstWhereOrNull((w) => w.canClockIn);

  /// Anything in `PENDING` that hasn't been approved/rejected yet.
  bool get hasPendingSubmission =>
      workspaces.any((w) => w.status == WorkspaceStatus.pending);

  /// True if the clock-in/out buttons should be enabled.
  bool get canClockIn => approvedWorkspace != null;

  /// Returns today's attendance record, or a default empty record if none exists yet.
  DailyAttendance get todayAttendance {
    final todayDateStr = DateFormat('yyyy-MM-dd').format(trustedTime);
    return dailyAttendanceList.firstWhere(
      (r) => r.date == todayDateStr,
      orElse: () => DailyAttendance(date: todayDateStr),
    );
  }

  /// True if the user has already clocked in today.
  bool get hasClockedInToday => todayAttendance.hasClockedIn;

  /// True if the user has already clocked out today.
  bool get hasClockedOutToday => todayAttendance.hasClockedOut;

  // Biometric enrollment status (from GET /biometric/status)
  var hasFace = false.obs;
  var hasFingerprint = false.obs;
  var biometricEnabled = false.obs;
  var isFetchingStatus = false.obs;

  // Clock-in step feedback
  var clockStepMessage = ''.obs;
  // GPS capture progress 0→1; -1 = not capturing (indeterminate/other phase).
  var clockStepProgress = (-1.0).obs;

  // Time synchronization
  var serverTimeOffset = Duration.zero.obs;

  DateTime get trustedTime => DateTime.now().add(serverTimeOffset.value);

  @override
  void onInit() {
    super.onInit();
    // We try to sync time immediately.
    // If it fails, we default to Duration.zero (system time).
    syncTimeWithServer();
  }

  Future<void> syncTimeWithServer() async {
    try {
      // We can fetch the server time from any reliable source.
      // Easiest is to check the 'date' header from your own backend.
      final response = await _api.getRawStatusResponse();
      final dateStr = response.headers.value('date');
      if (dateStr != null) {
        final serverTime = HttpDate.parse(dateStr).toLocal();
        serverTimeOffset.value = serverTime.difference(DateTime.now());
      }
    } catch (e) {
      log('Time synchronization failed: $e');
    }
  }

  // ── Biometric status ──────────────────────────────────────────────────

  Future<void> fetchBiometricStatus(String token) async {
    try {
      isFetchingStatus(true);
      final data = await _api.getBiometricStatus(token);
      hasFace.value = data['has_face'] == true;
      hasFingerprint.value = data['has_fingerprint'] == true;
      biometricEnabled.value = data['biometric_enabled'] == true;
    } catch (e) {
      log('Fetch biometric status error: $e');
    } finally {
      isFetchingStatus(false);
    }
  }

  /// POST /biometric/remove — revokes a biometric enrollment.
  /// biometricType: 'face' or 'fingerprint'.
  Future<bool> removeBiometric(String token, {required String biometricType}) async {
    try {
      await _api.removeBiometric(token, biometricType);
      successMessage.value =
          '${biometricType[0].toUpperCase()}${biometricType.substring(1)} removed.';
      await fetchBiometricStatus(token);
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    }
  }

  // --- Workspace Management ---

  /// Pulls the FULL list of the user's submissions (any status).
  /// UI then renders each with its status chip and chooses clock-in targeting
  /// from [approvedWorkspace].
  Future<void> fetchWorkspaces(String token) async {
    try {
      isFetchingWorkspace(true);
      errorMessage('');
      final list = await _api.getWorkspaces(token);
      workspaces.assignAll(
        list.map((e) => WorkspaceConfig.fromJson(e)).toList(),
      );
    } catch (e) {
      log('Fetch workspaces error: $e');
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      workspaces.clear();
    } finally {
      isFetchingWorkspace(false);
    }
  }

  /// Submit a new workspace for approval. Radius is admin-controlled at
  /// approval time, not sent by the employee. [accuracyMeters] is the settled
  /// fix quality — frontend gates on it, backend keeps it as safety net.
  Future<bool> submitWorkspace(
    String token, {
    required double latitude,
    required double longitude,
    required String workspaceName,
    String locationType = 'branch',
    String? notes,
    double? accuracyMeters,
  }) async {
    try {
      isSettingUpWorkspace(true);
      errorMessage('');

      final result = await _api.submitWorkspace(
        token,
        workspaceName: workspaceName,
        latitude: latitude,
        longitude: longitude,
        locationType: locationType,
        notes: notes,
        accuracyMeters: accuracyMeters,
      );

      // Prepend the newly submitted workspace so the user immediately sees
      // it as PENDING in their list without waiting for a refetch.
      workspaces.insert(0, WorkspaceConfig.fromJson(result));
      successMessage.value = 'Submitted for approval.';
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isSettingUpWorkspace(false);
    }
  }

  /// Delete one of the user's own workspace submissions. The backend allows
  /// this at any status per the approved plan.
  Future<bool> deleteWorkspace(String token, int locationId) async {
    try {
      isDeletingWorkspace(true);
      errorMessage('');

      await _api.deleteWorkspace(token, locationId);
      workspaces.removeWhere((w) => w.id == locationId);
      successMessage.value = 'Workspace removed.';
      return true;
    } catch (e) {
      errorMessage.value = e.toString().replaceFirst('Exception: ', '');
      return false;
    } finally {
      isDeletingWorkspace(false);
    }
  }

  // --- Fetch & Process History ---

  Future<void> fetchAttendanceHistory(String token, {int limit = 100}) async {
    try {
      isLoading(true);
      errorMessage('');

      final records = await _api.getMyAttendanceRecords(token, limit: limit);
      final parsed =
          records.map((e) => BiometricAttendanceRecord.fromJson(e)).toList();
      rawRecords.assignAll(parsed);
      _processDailyAttendance(parsed);
    } catch (e, s) {
      _handleError(e, s);
    } finally {
      isLoading(false);
    }
  }

  void _processDailyAttendance(List<BiometricAttendanceRecord> records) {
    Map<String, List<BiometricAttendanceRecord>> grouped = {};

    for (var r in records) {
      String dateKey = DateFormat('yyyy-MM-dd').format(r.timestamp);
      if (!grouped.containsKey(dateKey)) grouped[dateKey] = [];
      grouped[dateKey]!.add(r);
    }

    List<DailyAttendance> result = [];
    grouped.forEach((date, events) {
      events.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      BiometricAttendanceRecord? inRecord =
          events.firstWhereOrNull((e) => e.attendanceType == 'CLOCK_IN');
      BiometricAttendanceRecord? outRecord =
          events.lastWhereOrNull((e) => e.attendanceType == 'CLOCK_OUT');

      String inTime = inRecord != null
          ? DateFormat('hh:mm a').format(inRecord.timestamp)
          : '--:--';
      String outTime = outRecord != null
          ? DateFormat('hh:mm a').format(outRecord.timestamp)
          : '--:--';

      String duration = '--:--';
      if (inRecord != null && outRecord != null) {
        Duration diff = outRecord.timestamp.difference(inRecord.timestamp);
        duration = "${diff.inHours}h ${diff.inMinutes.remainder(60)}m";
      }

      result.add(DailyAttendance(
        date: date,
        clockInTime: inTime,
        clockOutTime: outTime,
        hoursWorked: duration,
      ));
    });

    result.sort((a, b) => b.date.compareTo(a.date));
    dailyAttendanceList.assignAll(result);
  }

  // --- Clock In / Out with Face + GPS ---

  Future<bool> performClockAction(
    String token, {
    required bool isClockIn,
    required BuildContext context,
  }) async {
    isAuthenticating(true);
    errorMessage('');
    successMessage('');
    clockStepMessage('');
    clockStepProgress(-1);
    final type = isClockIn ? 'clock_in' : 'clock_out';
    authActionType(type);

    try {
      // 0. State validation guards
      if (isClockIn && hasClockedInToday) {
        errorMessage.value = 'You have already clocked in for today.';
        return false;
      }
      if (!isClockIn && !hasClockedInToday) {
        errorMessage.value = 'You must clock in before you can clock out.';
        return false;
      }
      if (!isClockIn && hasClockedOutToday) {
        errorMessage.value = 'You have already clocked out for today.';
        return false;
      }

      // 1. Must have at least one APPROVED + active workspace.
      final ws = approvedWorkspace;
      if (ws == null) {
        errorMessage.value = _noApprovedWorkspaceMessage();
        return false;
      }

      // 2. Settled location — frontend owns accuracy. Sample until the fix
      // converges; show live ±Xm so a tap never dead-ends on one bad fix.
      clockStepMessage.value = 'Acquiring GPS...';

      final hasPermission = await _location.ensurePermission();
      if (!hasPermission) {
        errorMessage.value =
            'Location permission is required. Please enable it in your browser settings.';
        return false;
      }

      late Position position;
      try {
        position = await _location.getSettledPosition(
          targetAccuracy: LocationService.clockInTargetAccuracy,
          onUpdate: (best) {
            clockStepMessage.value =
                'Acquiring GPS ±${best.accuracy.toStringAsFixed(0)}m...';
          },
          onProgress: (p) => clockStepProgress.value = p,
        );
        clockStepProgress(-1);
      } catch (e) {
        clockStepProgress(-1);
        errorMessage.value = 'Unable to get your location. Please try again.';
        return false;
      }

      // Frontend accuracy gate (backend never expands the fence).
      if (position.accuracy > LocationService.clockInMaxAccuracy) {
        errorMessage.value =
            'GPS fix too weak (±${position.accuracy.toStringAsFixed(0)}m). '
            'Step outside / near a window and tap Retry — waiting a few seconds '
            'lets accuracy drop below ±${LocationService.clockInMaxAccuracy.toInt()}m.';
        return false;
      }

      // 3. Soft client pre-check — hard-block only when clearly far (saves
      // the face-capture step). Backend is authoritative for the real fence
      // max(admin_radius, 25m) and handles pending/expired/global cases.
      final effective = _location.effectiveRadius(ws.radiusMeters);
      final distanceToWs =
          _location.getDistance(position, ws.latitude, ws.longitude);
      final farBlockAt = effective >
              LocationService.farBlockThresholdMeters
          ? effective.toDouble()
          : LocationService.farBlockThresholdMeters;
      if (distanceToWs > farBlockAt) {
        errorMessage.value =
            'You are ${distanceToWs.toInt()}m away from your workspace "${ws.workspaceName}". '
            'Get within range to clock ${isClockIn ? 'in' : 'out'}.';
        return false;
      }

      final verification = LocationVerificationResult.fromJson(
        await _api.verifyLocation(
          token,
          latitude: position.latitude,
          longitude: position.longitude,
          accuracyMeters: position.accuracy,
        ),
      );
      if (!ClockInLocationPolicy.canProceed(verification)) {
        errorMessage.value = _verifyFailMessage(verification);
        return false;
      }

      // 4. Capture face (Liveness Dialog)
      clockStepMessage.value = 'Capturing active face...';

      if (!context.mounted) {
        errorMessage.value = 'Page closed. Please try again.';
        return false;
      }

      final base64FaceString = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const FaceLivenessDialog(),
      );

      if (base64FaceString == null || base64FaceString.isEmpty) {
        errorMessage.value = 'Face capture was cancelled.';
        return false;
      }

      // 5. Send to backend
      clockStepMessage.value = 'Verifying...';

      await _api.biometricClockIn(
        token,
        biometricData: base64FaceString,
        biometricType: 'face',
        attendanceType: type,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracyMeters: position.accuracy,
      );

      successMessage.value =
          '${isClockIn ? "Clocked In" : "Clocked Out"} successfully!';
      await fetchAttendanceHistory(token);
      return true;
    } catch (e, s) {
      _handleError(e, s);
      return false;
    } finally {
      isAuthenticating(false);
      authActionType('');
      clockStepMessage('');
      clockStepProgress(-1);
    }
  }

  /// Surfaces the backend hint (effective radius / poor_gps / no location)
  /// so the error is actionable and retryable instead of a bare "Xm away".
  String _verifyFailMessage(LocationVerificationResult verification) {
    final hint = verification.hint;
    if (hint != null && hint.isNotEmpty) {
      if (hint.startsWith('poor_gps')) return hint.substring('poor_gps:'.length).trim();
      if (hint.startsWith('no_usable_location')) {
        return 'No approved workspace found. Your submission may still be pending approval, expired, or inactive.';
      }
      if (hint.startsWith('out_of_range:')) {
        return hint.substring('out_of_range:'.length).trim();
      }
      return hint;
    }
    final distance = verification.distanceMeters;
    final name = verification.locationName;
    if (distance == null) {
      return 'Your current location is not approved for this workspace.';
    }
    final radius = verification.effectiveRadiusMeters;
    if (name != null && radius != null) {
      return 'You are ${distance.toInt()}m from "$name" (allowed ~${radius.toInt()}m). Move closer and tap Retry.';
    }
    return 'You are ${distance.toInt()}m away from an approved workspace.';
  }

  /// Tailored error when the user doesn't have an approved workspace.
  String _noApprovedWorkspaceMessage() {
    if (workspaces.isEmpty) {
      return 'Submit a workspace for approval before clocking in.';
    }
    if (workspaces.every((w) => w.status == WorkspaceStatus.pending)) {
      return 'Your workspace submission is awaiting admin approval.';
    }
    if (workspaces.every((w) => w.status == WorkspaceStatus.rejected)) {
      return 'Your workspace submission was rejected. Delete it and submit a new one.';
    }
    return 'You need an approved workspace to clock in.';
  }

  // --- Face Registration ---
  Future<bool> performFaceSetup(
    String token, {
    required BuildContext context,
  }) async {
    isAuthenticating(true);
    errorMessage('');
    successMessage('');
    clockStepMessage('');

    try {
      clockStepMessage.value = 'Capturing active face for registration...';

      if (!context.mounted) {
        errorMessage.value = 'Page closed. Please try again.';
        return false;
      }

      final base64FaceString = await showDialog<String>(
        context: context,
        barrierDismissible: false,
        builder: (_) => const FaceLivenessDialog(),
      );

      if (base64FaceString == null || base64FaceString.isEmpty) {
        errorMessage.value = 'Face capture was cancelled.';
        return false;
      }

      clockStepMessage.value = 'Registering face...';

      await _api.setupFace(token, base64FaceString);

      successMessage.value = 'Face registered successfully!';
      // Refresh status so the UI reflects has_face=true without a manual reload.
      await fetchBiometricStatus(token);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isAuthenticating(false);
      clockStepMessage('');
    }
  }

  void _handleError(dynamic error, [StackTrace? stackTrace]) {
    if (error is Exception) {
      final msg = error.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg;
    } else {
      errorMessage.value = error.toString();
    }
    debugPrint("BiometricController Error: ${errorMessage.value}\nTrace: ${stackTrace ?? StackTrace.current}");
  }
}
