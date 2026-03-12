import 'package:dio/dio.dart';

import '../model/departments_units_model.dart';
import '../model/employees_model.dart';

class EmployeeService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachauth.bgbot.app';

  EmployeeService({
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

  // ─── EMPLOYEES ──────────────────────────────────────────────────────

  Future<({List<Employee> list, int count})> getEmployees(
    String token, {
    bool? isActive,
    String? employmentType,
    String? departmentId,
    String? branchId,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/employees/employees',
        queryParameters: {
          if (isActive != null) 'is_active': isActive,
          if (employmentType != null) 'employment_type': employmentType,
          if (departmentId != null) 'department_id': departmentId,
          if (branchId != null) 'branch_id': branchId,
          if (search != null) 'search': search,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return (
        list: list.map((json) => Employee.fromJson(json)).toList(),
        count: data['count'] as int
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Employee> createEmployee(String token, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/api/v1/employees/employees',
        data: data,
        options: _authOptions(token),
      );
      return Employee.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Employee> getEmployeeById(String token, String userId) async {
    try {
      final response = await _dio.get(
        '/api/v1/employees/employees/$userId',
        options: _authOptions(token),
      );
      return Employee.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Employee> updateEmployee(
      String token, String userId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/api/v1/employees/employees/$userId',
        data: data,
        options: _authOptions(token),
      );
      return Employee.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── DEPARTMENTS ────────────────────────────────────────────────────

  Future<List<Department>> getDepartments(
    String token, {
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/employees/department',
        queryParameters: {
          if (search != null) 'search': search,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => Department.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Department> createDepartment(
      String token, String name, String description) async {
    try {
      final response = await _dio.post(
        '/api/v1/employees/department',
        data: {
          'name': name,
          'description': description,
        },
        options: _authOptions(token),
      );
      return Department.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Department> updateDepartment(String token, String departmentId,
      String name, String description) async {
    try {
      final response = await _dio.put(
        '/api/v1/employees/department/$departmentId',
        data: {
          'name': name,
          'description': description,
        },
        options: _authOptions(token),
      );
      return Department.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── DEPARTMENT UNITS ───────────────────────────────────────────────

  Future<List<DepartmentUnit>> getDepartmentUnits(
    String token, {
    String? departmentId,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/employees/unit',
        queryParameters: {
          if (departmentId != null) 'department_id': departmentId,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => DepartmentUnit.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DepartmentUnit> createDepartmentUnit(
      String token, DepartmentUnit unit) async {
    try {
      final response = await _dio.post(
        '/api/v1/employees/unit',
        data: unit.toJson(),
        options: _authOptions(token),
      );
      return DepartmentUnit.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<DepartmentUnit> updateDepartmentUnit(
      String token, String unitId, DepartmentUnit unit) async {
    try {
      final response = await _dio.put(
        '/api/v1/employees/unit/$unitId',
        data: unit.toJson(),
        options: _authOptions(token),
      );
      return DepartmentUnit.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── EMPLOYEE LEVELS ────────────────────────────────────────────────

  Future<List<dynamic>> getEmployeeLevels(
    String token, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/employees/employee-levels',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );
      final data = response.data;
      return (data is Map && data.containsKey('items')) ? data['items'] : data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── EMPLOYEE DOCUMENTS ─────────────────────────────────────────────

  Future<List<dynamic>> getEmployeeDocuments(String token, String userId) async {
    try {
      final response = await _dio.get(
        '/api/v1/employees/employees/$userId/documents',
        options: _authOptions(token),
      );
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data.containsKey('items')) return data['items'];
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> uploadEmployeeDocument(
      String token, String userId, FormData formData) async {
    try {
      final response = await _dio.post(
        '/api/v1/employees/employees/$userId/documents',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',
          },
        ),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteEmployeeDocument(
      String token, String userId, String docId) async {
    try {
      await _dio.delete(
        '/api/v1/employees/employees/$userId/documents/$docId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── EMPLOYEE REVIEWS ───────────────────────────────────────────────

  Future<List<dynamic>> getEmployeeReviews(String token, String userId) async {
    try {
      final response = await _dio.get(
        '/api/v1/employees/employees/$userId/reviews',
        options: _authOptions(token),
      );
      final data = response.data;
      if (data is List) return data;
      if (data is Map && data.containsKey('items')) return data['items'];
      return [];
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> createEmployeeReview(
      String token, String userId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        '/api/v1/employees/employees/$userId/reviews',
        data: data,
        options: _authOptions(token),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<dynamic> updateEmployeeReview(
      String token, String reviewId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/api/v1/employees/reviews/$reviewId',
        data: data,
        options: _authOptions(token),
      );
      return response.data;
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteEmployeeReview(String token, String reviewId) async {
    try {
      await _dio.delete(
        '/api/v1/employees/reviews/$reviewId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ERROR HANDLER ──────────────────────────────────────────────────

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage = error.response?.data?['message'] ??
          error.response?.data?['detail'] ??
          error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
