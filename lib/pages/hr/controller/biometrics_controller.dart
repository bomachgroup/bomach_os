import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import '../../../src/services/biometric_service.dart';
import '../models/attendance_models.dart';

class BiometricsController extends GetxController {
  final BiometricService _biometricService = BiometricService();

  var isLoading = false.obs;
  var isAuthenticating = false.obs;
  var attendanceList = <BiometricAttendanceRecord>[].obs;
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

  Future<void> fetchAttendanceHistory(String token, {int limit = 50}) async {
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

        attendanceList.assignAll(
            list.map((e) => BiometricAttendanceRecord.fromJson(e)).toList());
      }
    } catch (e) {
      _handleError(e);
    } finally {
      isLoading(false);
    }
  }

  Future<bool> biometricClockIn(String token,
      {String attendanceType = "CLOCK_IN"}) async {
    isAuthenticating(true);
    errorMessage('');
    successMessage('');

    try {
      final bioResult = await _biometricService.authenticateWithDetails(
        reason: 'Scan to $attendanceType',
      );

      if (!bioResult.isAuthenticated) {
        errorMessage.value = bioResult.errorMessage ?? "Authentication failed";
        return false;
      }

      final Map<String, dynamic> payload = {
        "biometric_data": "DEVICE_VERIFIED_SECURELY",
        "biometric_type": bioResult.biometricType ?? "FINGERPRINT",
        "attendance_type": attendanceType
      };

      final response = await _dio.post(
        '/api/v1/biometric/clockin',
        data: payload,
        options: _authOptions(token),
      );

      if (response.statusCode == 200) {
        successMessage.value = "Attendance recorded successfully!";
        await fetchAttendanceHistory(token);
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

 

  Future<bool> deleteAttendance(String token, int id) async {
    try {
      isLoading(true);

      final response = await _dio.delete(
        '/api/v1/biometric/attendance/$id',
        options: _authOptions(token),
      );

      if (response.statusCode == 200 || response.statusCode == 204) {
        attendanceList.removeWhere((item) => item.id == id);
        return true;
      }
      return false;
    } catch (e) {
      _handleError(e);
      return false;
    } finally {
      isLoading(false);
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
// class BiometricService {
//   static final BiometricService _instance = BiometricService._internal();
//   factory BiometricService() => _instance;
//   BiometricService._internal();

//   final LocalAuthentication _auth = LocalAuthentication();

//   Future<bool> isBiometricsAvailable() async {
//     try {
//       final bool canAuthenticateWithBiometrics = await _auth.canCheckBiometrics;
//       final bool canAuthenticate =
//           canAuthenticateWithBiometrics || await _auth.isDeviceSupported();
//       return canAuthenticate;
//     } on PlatformException catch (e) {
//       print("Error checking biometrics: $e");
//       return false;
//     }
//   }

//   Future<List<BiometricType>> getAvailableBiometrics() async {
//     try {
//       return await _auth.getAvailableBiometrics();
//     } on PlatformException catch (e) {
//       print("Error getting available biometrics: $e");
//       return <BiometricType>[];
//     }
//   }

//   Future<bool> authenticate({
//     String localizedReason = 'Please authenticate to access the app',
//     bool stickyAuth = true,
//     bool sensitiveTransaction = true,
//   }) async {
//     try {
//       final bool isAvailable = await isBiometricsAvailable();
//       if (!isAvailable) return false;

//       return await _auth.authenticate(
//         localizedReason: localizedReason,
//         options: AuthenticationOptions(
//           stickyAuth: stickyAuth,
//           sensitiveTransaction: sensitiveTransaction,
//           biometricOnly: true,
//         ),
//       );
//     } on PlatformException catch (e) {
//       print("Authentication Error: $e");
//       return false;
//     }
//   }

//   Future<void> cancelAuthentication() async {
//     await _auth.stopAuthentication();
//   }
// }

// class BiometricApiService {
//   final Dio _dio;
//   static const String _baseUrl = 'https://bomachhr.bgbot.app/api/v1';

//   BiometricApiService({Dio? dioOverride})
//       : _dio = dioOverride ??
//             Dio(BaseOptions(
//               baseUrl: _baseUrl,
//               connectTimeout: const Duration(seconds: 15),
//               receiveTimeout: const Duration(seconds: 15),
//               headers: {
//                 'Content-Type': 'application/json',
//                 'Accept': 'application/json'
//               },
//             ));

//   Options _authOptions(String token) =>
//       Options(headers: {'Authorization': 'Bearer $token'});

//   Future<void> logAttendance(String token,
//       {required double lat, required double long}) async {
//     try {
//       await _dio.post(
//         '/attendance/clock-in',
//         data: {
//           'latitude': lat,
//           'longitude': long,
//           'timestamp': DateTime.now().toIso8601String()
//         },
//         options: _authOptions(token),
//       );
//     } catch (e) {
//       throw _handleError(e);
//     }
//   }

//   Exception _handleError(dynamic error) {
//     if (error is DioException) {
//       return Exception(
//           'API Error: ${error.response?.statusCode} - ${error.response?.data}');
//     }
//     return Exception('Unexpected error: $error');
//   }
// }

// class BiometricsController extends GetxController {
//   final LocalAuthentication _auth = LocalAuthentication();
//   final Dio _dio = Dio(BaseOptions(
//     baseUrl: 'https://bomachhr.bgbot.app/api/v1',
//     connectTimeout: const Duration(seconds: 15),
//     receiveTimeout: const Duration(seconds: 15),
//     headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
//   ));

//   var isLoading = false.obs;
//   var isAuthenticating = false.obs;
//   var attendanceList = <AttendanceRecord>[].obs;
//   var errorMessage = ''.obs;
//   var isAuthenticated = false.obs;

//   Future<bool> checkBiometricsAvailable() async {
//     if (kIsWeb) return false;

//     try {
//       final bool canCheckBiometrics = await _auth.canCheckBiometrics;
//       final bool isDeviceSupported = await _auth.isDeviceSupported();
//       return canCheckBiometrics || isDeviceSupported;
//     } on PlatformException catch (e) {
//       debugPrint("Error checking biometrics: $e");
//       return false;
//     }
//   }

//   Future<bool> authenticateUser() async {
//     // TODO: Handle Web Platform
//     if (kIsWeb) {
//       // On web, we cannot scan fingerprints.
//       // We automatically return 'true' to allow testing the API flow.
//       // You could also return 'false' and show a "Not supported on Web" message.
//       debugPrint("Web detected: Skipping biometrics.");
//       return true;
//     }

//     try {
//       isAuthenticating(true);
//       final bool didAuthenticate = await _auth.authenticate(
//         localizedReason: 'Please authenticate to Clock In/Out',
//         options: const AuthenticationOptions(
//           stickyAuth: true,
//           biometricOnly: true,
//         ),
//       );
//       isAuthenticated(didAuthenticate);
//       return didAuthenticate;
//     } on PlatformException catch (e) {
//       debugPrint("Authentication Error: $e");
//       errorMessage.value = "Authentication failed: ${e.message}";
//       return false;
//     } finally {
//       isAuthenticating(false);
//     }
//   }

//   Options _authOptions(String token) =>
//       Options(headers: {'Authorization': 'Bearer $token'});

//   Future<void> fetchAttendanceHistory(String token) async {
//     try {
//       isLoading(true);
//       errorMessage('');

//       final response = await _dio.get(
//         '/attendance/',
//         options: _authOptions(token),
//       );

//       final data = response.data;
//       final List<dynamic> list =
//           (data is Map && data.containsKey('items')) ? data['items'] : data;

//       attendanceList
//           .assignAll(list.map((e) => AttendanceRecord.fromJson(e)).toList());
//     } catch (e) {
//       errorMessage.value = 'Failed to load history: ${_parseError(e)}';
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<bool> logAttendance(String token,
//       {required double lat, required double long}) async {
//     try {
//       isLoading(true);
//       await _dio.post(
//         '/attendance/clock-in',
//         data: {
//           'latitude': lat,
//           'longitude': long,
//           'timestamp': DateTime.now().toIso8601String()
//         },
//         options: _authOptions(token),
//       );
//       await fetchAttendanceHistory(token);
//       return true;
//     } catch (e) {
//       errorMessage.value = _parseError(e);
//       return false;
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<bool> createManualAttendance(
//       String token, AttendanceRecord record) async {
//     try {
//       isLoading(true);
//       await _dio.post(
//         '/attendance/',
//         data: record.toJson(),
//         options: _authOptions(token),
//       );
//       await fetchAttendanceHistory(token);
//       return true;
//     } catch (e) {
//       errorMessage.value = _parseError(e);
//       return false;
//     } finally {
//       isLoading(false);
//     }
//   }

//   Future<bool> deleteAttendance(String token, String id) async {
//     try {
//       await _dio.delete(
//         '/attendance/$id',
//         options: _authOptions(token),
//       );
//       attendanceList.removeWhere((item) => item.id == id);
//       return true;
//     } catch (e) {
//       debugPrint("Delete Error: $e");
//       return false;
//     }
//   }

//   String _parseError(dynamic error) {
//     if (error is DioException) {
//       final data = error.response?.data;
//       if (data == null) return error.message ?? 'Unknown API Error';
//       if (data is Map<String, dynamic>) {
//         return data['message'] ??
//             data['detail'] ??
//             error.message ??
//             'Unknown API Error';
//       }
//       if (data is String) {
//         return data.length > 100 ? data.substring(0, 100) : data;
//       }
//     }
//     return error.toString();
//   }
// }
