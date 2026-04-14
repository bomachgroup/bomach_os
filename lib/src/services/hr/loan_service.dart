import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/hr/models/loans_model.dart';

class LoanService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  LoanService({
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

  /// GET /loans — list with filters, returns paginated {items, count}
  Future<({List<LoanRequest> items, int count})> getLoans(
    String token, {
    String? status,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/loans',
        queryParameters: {
          if (status != null) 'status': status,
          if (search != null) 'search': search,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final dynamic data = response.data;
      List<dynamic> list = [];
      int count = 0;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('items')) list = data['items'];
        if (data.containsKey('count')) {
          count = data['count'] is int ? data['count'] : 0;
        }
      } else if (data is List) {
        list = data;
        count = list.length;
      }

      final items = list.map((json) => LoanRequest.fromJson(json)).toList();
      return (items: items, count: count);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /loans — create a new loan request
  Future<LoanRequest> createLoan(String token, LoanRequest loan) async {
    try {
      final response = await _dio.post(
        '/loans',
        data: loan.toCreateJson(),
        options: _authOptions(token),
      );
      return LoanRequest.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /loans/{id} — get a single loan by id
  Future<LoanRequest> getLoanById(String token, int id) async {
    try {
      final response = await _dio.get(
        '/loans/$id',
        options: _authOptions(token),
      );
      return LoanRequest.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /loans/{id}/approve — approve a loan
  Future<LoanRequest> approveLoan(String token, int id) async {
    try {
      final response = await _dio.post(
        '/loans/$id/approve',
        options: _authOptions(token),
      );
      return LoanRequest.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /loans/{id}/reject — reject a loan
  Future<LoanRequest> rejectLoan(String token, int id) async {
    try {
      final response = await _dio.post(
        '/loans/$id/reject',
        options: _authOptions(token),
      );
      return LoanRequest.fromJson(response.data);
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
