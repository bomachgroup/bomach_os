import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/hr/models/leave_request_model.dart';

class LeaveRequestService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  LeaveRequestService({
    Dio? dioOverride,
  }) : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: false,
    ));
  }

  Options _authOptions(String token) {
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  Future<({List<LeaveRequest> items, int count})> getLeaveRequests(
    String token, {
    String? search,
    String? employeeId,
    String? leaveType,
    String? status,
    String? startDateFrom,
    String? startDateTo,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/leave-requests/',
        queryParameters: {
          if (search != null) 'search': search,
          if (employeeId != null) 'employee_id': employeeId,
          if (leaveType != null) 'leave_type': leaveType,
          if (status != null) 'status': status,
          if (startDateFrom != null) 'start_date_from': startDateFrom,
          if (startDateTo != null) 'start_date_to': startDateTo,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      //
      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return (
        items: list.map((json) => LeaveRequest.fromJson(json)).toList(),
        count: (data['count'] as int?) ?? 0
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<LeaveRequest> createLeaveRequest(
      String token, LeaveRequest request) async {
    try {
      final response = await _dio.post(
        '/leave-requests/',
        data: request.toJson(),
        options: _authOptions(token),
      );
      return LeaveRequest.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<LeaveRequest> getLeaveRequestById(String token, String id) async {
    try {
      final response = await _dio.get(
        '/leave-requests/$id',
        options: _authOptions(token),
      );
      return LeaveRequest.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<LeaveRequest> updateLeaveRequest(
      String token, String id, LeaveRequest request) async {
    try {
      final response = await _dio.put(
        '/leave-requests/$id',
        data: request.toJson(),
        options: _authOptions(token),
      );
      return LeaveRequest.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteLeaveRequest(String token, String id) async {
    try {
      await _dio.delete(
        '/leave-requests/$id',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<LeaveRequest> updateLeaveRequestStatus(
    String token,
    String id, {
    required String status,
    String? rejectionReason,
    String? approvedBy,
  }) async {
    try {
      final response = await _dio.patch(
        '/leave-requests/$id/status',
        data: {
          'status': status,
          if (rejectionReason != null) 'rejection_reason': rejectionReason,
          if (approvedBy != null) 'approved_by': approvedBy,
        },
        options: _authOptions(token),
      );
      return LeaveRequest.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> getLeaveRequestsSummary(String token) async {
    try {
      final response = await _dio.get(
        '/leave-requests/stats/summary',
        options: _authOptions(token),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> getEmployeeLeaveStats(String token, String employeeId) async {
    try {
      final response = await _dio.get(
        '/leave-requests/stats/by-employee/$employeeId',
        options: _authOptions(token),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage = error.response?.data?['message'] ?? error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
