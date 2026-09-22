import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/employee_target_model.dart';
import 'package:bomach_os/src/model/target_report_model.dart';
import 'package:dio/dio.dart';

class TargetReportService {
  final Dio _dio;

  TargetReportService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<List<EmployeeTarget>> listMyAssignedTargets(String token) async {
    try {
      final response = await _dio.get(
        '/api/v1/employees/me/targets',
        queryParameters: {'is_active': true, 'limit': 100, 'offset': 0},
        options: _auth(token),
      );
      final data = response.data;
      final items = data is Map
          ? (data['items'] as List? ?? const [])
          : (data as List? ?? const []);

      return items
          .map((item) =>
              EmployeeTarget.fromJson(Map<String, dynamic>.from(item as Map)))
          .where((target) => target.isActive)
          .toList();
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<({List<TargetReport> list, int count})> listMine(
    String token, {
    int? employeeTargetId,
    String? status,
    String? periodStart,
    String? periodEnd,
    String? submittedFrom,
    String? submittedTo,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    return _list(
      token,
      '/api/v1/target-reports/me',
      employeeTargetId: employeeTargetId,
      status: status,
      periodStart: periodStart,
      periodEnd: periodEnd,
      submittedFrom: submittedFrom,
      submittedTo: submittedTo,
      search: search,
      limit: limit,
      offset: offset,
    );
  }

  Future<({List<TargetReport> list, int count})> listAll(
    String token, {
    int? employeeTargetId,
    int? employeeUserId,
    String? status,
    String? periodStart,
    String? periodEnd,
    String? submittedFrom,
    String? submittedTo,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    return _list(
      token,
      '/api/v1/target-reports/',
      employeeTargetId: employeeTargetId,
      employeeUserId: employeeUserId,
      status: status,
      periodStart: periodStart,
      periodEnd: periodEnd,
      submittedFrom: submittedFrom,
      submittedTo: submittedTo,
      search: search,
      limit: limit,
      offset: offset,
    );
  }

  Future<({List<TargetReport> list, int count})> _list(
    String token,
    String path, {
    int? employeeTargetId,
    int? employeeUserId,
    String? status,
    String? periodStart,
    String? periodEnd,
    String? submittedFrom,
    String? submittedTo,
    String? search,
    required int limit,
    required int offset,
  }) async {
    try {
      final query = <String, dynamic>{
        if (employeeTargetId != null) 'employee_target_id': employeeTargetId,
        if (employeeUserId != null) 'employee_user_id': employeeUserId,
        if (status != null) 'status': status,
        if (periodStart != null) 'period_start': periodStart,
        if (periodEnd != null) 'period_end': periodEnd,
        if (submittedFrom != null) 'submitted_from': submittedFrom,
        if (submittedTo != null) 'submitted_to': submittedTo,
        if (search != null && search.isNotEmpty) 'search': search,
        'limit': limit,
        'offset': offset,
      };
      final response = await _dio.get(
        path,
        queryParameters: query,
        options: _auth(token),
      );
      final data = response.data;
      final items = data is Map
          ? (data['items'] as List? ?? const [])
          : (data as List? ?? const []);
      return (
        list: items
            .map((item) =>
                TargetReport.fromJson(Map<String, dynamic>.from(item as Map)))
            .toList(),
        count: data is Map ? _toInt(data['count'], items.length) : items.length,
      );
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<TargetReport> create(
    String token, {
    required int employeeTargetId,
    required String summary,
    required num progressValue,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/target-reports/',
        data: {
          'employee_target_id': employeeTargetId,
          'summary': summary,
          'progress_value': progressValue,
        },
        options: _auth(token),
      );
      return TargetReport.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<TargetReport> approve(String token, int reportId) async {
    try {
      final response = await _dio.post(
        '/api/v1/target-reports/$reportId/approve',
        options: _auth(token),
      );
      return TargetReport.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<TargetReport> reject(
      String token, int reportId, String rejectionReason) async {
    try {
      final response = await _dio.post(
        '/api/v1/target-reports/$reportId/reject',
        data: {'rejection_reason': rejectionReason},
        options: _auth(token),
      );
      return TargetReport.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _handleError(error);
    }
  }

  static int _toInt(dynamic value, int fallback) => value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '') ?? fallback;

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final body = error.response?.data;
      final detail =
          body is Map ? (body['detail'] ?? body['message']) : error.message;
      return Exception('API Error: ${error.response?.statusCode} - $detail');
    }
    return Exception('Unexpected error: $error');
  }
}
