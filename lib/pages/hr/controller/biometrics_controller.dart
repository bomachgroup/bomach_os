import 'dart:convert';
import 'dart:developer';

import 'package:bms_front_end/src/services/biometric_api_service.dart';
import 'package:bms_front_end/src/services/location_service.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../models/attendance_models.dart';
import '../models/workspace_model.dart';

class BiometricsController extends GetxController {
  final BiometricApiService _api = BiometricApiService();
  final LocationService _location = LocationService();
  final ImagePicker _picker = ImagePicker();

  var isLoading = false.obs;
  var isAuthenticating = false.obs;

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
      if (workspace.value != null) {
        result = await _api.updateWorkspace(
          token,
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
    } catch (e) {
      _handleError(e);
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

  Future<bool> performClockAction(String token,
      {required bool isClockIn}) async {
    isAuthenticating(true);
    errorMessage('');
    successMessage('');
    clockStepMessage('');

    final type = isClockIn ? 'clock_in' : 'clock_out';

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

      // 4. Capture face
      clockStepMessage.value = 'Capturing face...';

      final photo = await _picker.pickImage(
        source: ImageSource.camera,
        preferredCameraDevice: CameraDevice.front,
        maxWidth: 640,
        maxHeight: 480,
        imageQuality: 80,
      );

      if (photo == null) {
        errorMessage.value = 'Face capture was cancelled.';
        return false;
      }

      // 5. Encode
      clockStepMessage.value = 'Processing...';
      final bytes = await photo.readAsBytes();
      final base64Face = base64Encode(bytes);

      // 6. Send to backend
      clockStepMessage.value = 'Verifying...';

      await _api.biometricClockIn(
        token,
        biometricData: base64Face,
        biometricType: 'face',
        attendanceType: type,
        latitude: position.latitude,
        longitude: position.longitude,
      );

      successMessage.value =
          '${isClockIn ? "Clocked In" : "Clocked Out"} successfully!';
      await fetchAttendanceHistory(token);
      return true;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isAuthenticating(false);
      clockStepMessage('');
    }
  }

  void _handleError(dynamic error) {
    if (error is Exception) {
      final msg = error.toString().replaceFirst('Exception: ', '');
      errorMessage.value = msg;
    } else {
      errorMessage.value = error.toString();
    }
    debugPrint("BiometricController Error: ${errorMessage.value}");
  }
}
