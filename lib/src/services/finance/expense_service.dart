import 'dart:developer';

import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/finance/models/expense_model.dart';

class ExpenseService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  ExpenseService({
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

  /// GET /api/v1/expenses — List Expenses
  Future<({List<Expense> items, int total})> getExpenses(
    String token, {
    String? status,
    String? category,
    int? userId,
    int? departmentId,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/expenses/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status != 'All') 'status': status,
          if (category != null && category != 'All') 'category': category,
          if (userId != null) 'user_id': userId,
          if (departmentId != null) 'department_id': departmentId,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => Expense.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      // Fallback: data is a plain list
      final items =
          (data as List).map((json) => Expense.fromJson(json)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/expenses — Create Expense
  Future<Expense> createExpense(String token, Map<String, dynamic> data) async {
    try {
      log("ExpenseService: Creating expense...");
      final response = await _dio.post(
        '/expenses/',
        data: data,
        options: _authOptions(token),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/expenses/{id} — Get Expense
  Future<Expense> getExpenseById(String token, int expenseId) async {
    try {
      final response = await _dio.get(
        '/expenses/$expenseId',
        options: _authOptions(token),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/expenses/{id} — Update Expense
  Future<Expense> updateExpense(
      String token, int expenseId, Map<String, dynamic> data) async {
    try {
      log("ExpenseService: Updating expense $expenseId...");
      final response = await _dio.put(
        '/expenses/$expenseId',
        data: data,
        options: _authOptions(token),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/expenses/{id} — Delete Expense
  Future<void> deleteExpense(String token, int expenseId) async {
    try {
      log("ExpenseService: Deleting expense $expenseId...");
      await _dio.delete(
        '/expenses/$expenseId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/expenses/{id}/approve — Approve Expense
  Future<Expense> approveExpense(String token, int expenseId) async {
    try {
      log("ExpenseService: Approving expense $expenseId...");
      final response = await _dio.post(
        '/expenses/$expenseId/approve',
        options: _authOptions(token),
      );
      return Expense.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/expenses/{id}/reject — Reject Expense
  Future<Expense> rejectExpense(String token, int expenseId) async {
    try {
      log("ExpenseService: Rejecting expense $expenseId...");
      final response = await _dio.post(
        '/expenses/$expenseId/reject',
        options: _authOptions(token),
      );
      return Expense.fromJson(response.data);
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
