import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:collection/collection.dart';

import '../models/attendance_models.dart';

class BiometricsController extends GetxController {
  var isLoading = false.obs;
  var isAuthenticating = false.obs;

  // Raw logs from API
  var rawRecords = <BiometricAttendanceRecord>[].obs;

  // Processed rows for the UI Table
  var dailyAttendanceList = <DailyAttendance>[].obs;

  var errorMessage = ''.obs;
  var successMessage = ''.obs;

  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://bomachauth.bgbot.app',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));

  Options _authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // --- Fetch & Process History ---
  Future<void> fetchAttendanceHistory(String token, {int limit = 100}) async {
    try {
      isLoading(true);
      errorMessage('');

      final response = await _dio.get(
        '/api/v1/biometric/attendance/my-records',
        queryParameters: {'limit': limit},
        options: _authOptions(token),
      );

      if (response.statusCode == 200) {
        final data = response.data;
        final List<dynamic> list = (data is Map && data.containsKey('items'))
            ? data['items']
            : (data is List ? data : []);

        final records =
            list.map((e) => BiometricAttendanceRecord.fromJson(e)).toList();
        rawRecords.assignAll(records);

        _processDailyAttendance(records);
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  // Group raw logs by Date to create Table Rows (Clock In + Clock Out)
  void _processDailyAttendance(List<BiometricAttendanceRecord> records) {
    Map<String, List<BiometricAttendanceRecord>> grouped = {};

    // Group by YYYY-MM-DD
    for (var r in records) {
      String dateKey = DateFormat('yyyy-MM-dd').format(r.timestamp);
      if (!grouped.containsKey(dateKey)) grouped[dateKey] = [];
      grouped[dateKey]!.add(r);
    }

    List<DailyAttendance> result = [];
    grouped.forEach((date, events) {
      // Sort by time to find first and last
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

      // Calculate Hours
      String duration = '--:--';
      if (inRecord != null && outRecord != null) {
        Duration diff = outRecord.timestamp.difference(inRecord.timestamp);
        duration = "${diff.inHours}h ${diff.inMinutes.remainder(60)}m";
      }

      result.add(DailyAttendance(
        date: date,
        employeeName: "Current User",
        role: "Software Engineer",
        clockInTime: inTime,
        clockOutTime: outTime,
        hoursWorked: duration,
      ));
    });

    // Sort by date descending
    result.sort((a, b) => b.date.compareTo(a.date));
    dailyAttendanceList.assignAll(result);
  }

  // --- Clock In / Out Action (Manual) ---
  Future<bool> performClockAction(String token,
      {required bool isClockIn}) async {
    isAuthenticating(true);
    errorMessage('');
    successMessage('');

    String type = isClockIn ? "clock_in" : "clock_out";

    try {
      // Payload for Manual Entry
      final Map<String, dynamic> payload = {
        "biometric_data": "MANUAL_ENTRY", // Explicit manual data
        "biometric_type": "face", // Explicit type
        "attendance_type": type
      };

      final response = await _dio.post(
        '/api/v1/biometric/clockin',
        data: payload,
        options: _authOptions(token),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        successMessage.value =
            "${isClockIn ? "Clocked In" : "Clocked Out"} successfully!";
        await fetchAttendanceHistory(token); // Refresh table
        return true;
      } else {
        errorMessage.value = "Server rejected request";
        return false;
      }
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isAuthenticating(false);
    }
  }

  void _handleError(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data != null && data is Map) {
        errorMessage.value = data['detail'] ?? data['message'] ?? 'API Error';
      } else {
        errorMessage.value = error.message ?? 'Connection Error';
      }
    } else {
      errorMessage.value = error.toString();
    }
    debugPrint("BiometricController Error: ${errorMessage.value}");
  }
}
