import 'dart:developer';

import 'package:bms_front_end/src/services/biometric_api_service.dart';
import 'package:bms_front_end/src/services/location_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';

import '../widget/face_liveness_dialog.dart';

import '../models/attendance_models.dart';
import '../models/workspace_model.dart';

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

  // Workspace
  var workspace = Rxn<WorkspaceConfig>();
  var isFetchingWorkspace = false.obs;
  var isSettingUpWorkspace = false.obs;

  // Clock-in step feedback
  var clockStepMessage = ''.obs;

  // --- Workspace Management ---

  Future<void> fetchWorkspace(String token) async {
    try {
      isFetchingWorkspace(true);
      final data = await _api.getWorkspace(token);
      if (data != null) {
        workspace.value = WorkspaceConfig.fromJson(data);
      } else {
        workspace.value = null;
      }
    } catch (e) {
      log('Fetch workspace error: $e');
      workspace.value = null;
    } finally {
      isFetchingWorkspace(false);
    }
  }

  Future<bool> saveWorkspace(
    String token, {
    required double latitude,
    required double longitude,
    required String workspaceName,
    required int radiusMeters,
  }) async {
    try {
      isSettingUpWorkspace(true);
      errorMessage('');

      Map<String, dynamic> result;
      if (workspace.value != null && workspace.value!.id != null) {
        result = await _api.updateWorkspace(
          token,
          locationId: workspace.value!.id!,
          latitude: latitude,
          longitude: longitude,
          workspaceName: workspaceName,
          radiusMeters: radiusMeters,
        );
      } else {
        result = await _api.setupWorkspace(
          token,
          latitude: latitude,
          longitude: longitude,
          workspaceName: workspaceName,
          radiusMeters: radiusMeters,
        );
      }

      workspace.value = WorkspaceConfig.fromJson(result);
      return true;
    } catch (e) {
      errorMessage.value = e.toString();
      return false;
    } finally {
      isSettingUpWorkspace(false);
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
        employeeName: "Current User",
        role: "Employee",
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

    final type = isClockIn ? 'clock_in' : 'clock_out';
    authActionType(type);

    try {
      // 1. Check workspace
      if (workspace.value == null) {
        errorMessage.value = 'Please set up your workspace location first.';
        return false;
      }

      // 2. Get location
      clockStepMessage.value = 'Getting your location...';

      final hasPermission = await _location.ensurePermission();
      if (!hasPermission) {
        errorMessage.value =
            'Location permission is required. Please enable it in your browser settings.';
        return false;
      }

      late Position position;
      try {
        position = await _location.getCurrentPosition();
      } catch (e) {
        errorMessage.value = 'Unable to get your location. Please try again.';
        return false;
      }

      // 3. Client-side geofence check
      final ws = workspace.value!;
      final withinRange = _location.isWithinRadius(
        position,
        ws.latitude,
        ws.longitude,
        ws.radiusMeters,
      );

      if (!withinRange) {
        final distance =
            _location.getDistance(position, ws.latitude, ws.longitude);
        errorMessage.value =
            'You are ${distance.toInt()}m away from your workspace "${ws.workspaceName}". '
            'You need to be within ${ws.radiusMeters}m to clock ${isClockIn ? 'in' : 'out'}.';
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
    }
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
