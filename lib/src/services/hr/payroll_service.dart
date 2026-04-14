import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/hr/models/payroll_model.dart';

class PayrollService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  PayrollService({
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

  Future<List<Payroll>> getPayrolls(
    String token, {
    String? search,
    String? employeeId,
    String? payrollPeriod,
    String? status,
    String? disbursementDateFrom,
    String? disbursementDateTo,
    double? minNetSalary,
    double? maxNetSalary,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/payroll/',
        queryParameters: {
          if (search != null) 'search': search,
          if (employeeId != null) 'employee_id': employeeId,
          if (payrollPeriod != null) 'payroll_period': payrollPeriod,
          if (status != null) 'status': status,
          if (disbursementDateFrom != null)
            'disbursement_date_from': disbursementDateFrom,
          if (disbursementDateTo != null)
            'disbursement_date_to': disbursementDateTo,
          if (minNetSalary != null) 'min_net_salary': minNetSalary,
          if (maxNetSalary != null) 'max_net_salary': maxNetSalary,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => Payroll.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Payroll> createPayroll(String token, Payroll payroll) async {
    try {
      final response = await _dio.post(
        '/payroll/',
        data: payroll.toJson(),
        options: _authOptions(token),
      );
      return Payroll.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Payroll> getPayrollById(String token, String payrollId) async {
    try {
      final response = await _dio.get(
        '/payroll/$payrollId',
        options: _authOptions(token),
      );
      return Payroll.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Payroll> updatePayroll(
      String token, String payrollId, Payroll payroll) async {
    try {
      final response = await _dio.put(
        '/payroll/$payrollId',
        data: payroll.toJson(),
        options: _authOptions(token),
      );
      return Payroll.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deletePayroll(String token, String payrollId) async {
    try {
      await _dio.delete(
        '/payroll/$payrollId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Payroll> updatePayrollStatus(
      String token, String payrollId, String status) async {
    try {
      final response = await _dio.patch(
        '/payroll/$payrollId/status',
        queryParameters: {'status': status},
        options: _authOptions(token),
      );
      return Payroll.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> processBatch(
    String token, {
    required String periodDate,
  }) async {
    try {
      final response = await _dio.post(
        '/payroll/process-batch',
        data: {'period_date': periodDate},
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> makePayment(
    String token, {
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dio.get(
        '/payroll/make-payment/$year/$month',
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Map<String, dynamic>> authorizePayroll(
    String token, {
    required int year,
    required int month,
  }) async {
    try {
      final response = await _dio.post(
        '/payroll/make-payment/$year/$month/authorize',
        options: _authOptions(token),
      );
      return Map<String, dynamic>.from(response.data);
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
