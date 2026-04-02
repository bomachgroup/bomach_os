import 'dart:developer';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/finance/models/budget_model.dart';

class BudgetService {
  final Dio _dio;

  static const String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  BudgetService({
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

  /// GET /api/v1/budgets — List Budgets
  Future<({List<Budget> items, int total})> getBudgets(
    String token, {
    String? fiscalPeriod,
    String? department,
    String? branch,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/budgets/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (fiscalPeriod != null && fiscalPeriod.isNotEmpty)
            'fiscal_period': fiscalPeriod,
          if (department != null && department != 'All')
            'department': department,
          if (branch != null && branch != 'All') 'branch': branch,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => Budget.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      // Fallback: data is a plain list
      final items =
          (data as List).map((json) => Budget.fromJson(json)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/budgets — Create Budget
  Future<Budget> createBudget(String token, Map<String, dynamic> data) async {
    try {
      log("BudgetService: Creating budget...");
      final response = await _dio.post(
        '/budgets/',
        data: data,
        options: _authOptions(token),
      );
      return Budget.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/budgets/{id} — Get Budget
  Future<Budget> getBudgetById(String token, int budgetId) async {
    try {
      final response = await _dio.get(
        '/budgets/$budgetId',
        options: _authOptions(token),
      );
      return Budget.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/budgets/{id} — Update Budget
  Future<Budget> updateBudget(
      String token, int budgetId, Map<String, dynamic> data) async {
    try {
      log("BudgetService: Updating budget $budgetId...");
      final response = await _dio.put(
        '/budgets/$budgetId',
        data: data,
        options: _authOptions(token),
      );
      return Budget.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/budgets/{id} — Delete Budget
  Future<void> deleteBudget(String token, int budgetId) async {
    try {
      log("BudgetService: Deleting budget $budgetId...");
      await _dio.delete(
        '/budgets/$budgetId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    String msg = "An unexpected error occurred";

    if (error is DioException) {
      if (error.response != null) {
        final data = error.response?.data;
        log("SERVER ERROR: $data");

        if (data is Map<String, dynamic>) {
          if (data['errors'] != null) {
            return Exception("Validation: ${data['errors']}");
          }
          if (data.containsKey('detail')) {
            msg = data['detail'];
          } else if (data.containsKey('message')) {
            msg = data['message'];
          }
        }
      } else {
        msg = "Connection error. Please check your internet.";
      }
    }
    return Exception(msg);
  }
}
