import 'package:dio/dio.dart';

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

  Future<List<Employee>> getEmployees(
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

      return list.map((json) => Employee.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Employee> createEmployee(String token, Employee employee,
      {String? password}) async {
    try {
      final data = employee.toJson();
      if (password != null) {
        data['password'] = password;
      }

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
      String token, String userId, Employee employee) async {
    try {
      final response = await _dio.put(
        '/api/v1/employees/employees/$userId',
        data: employee.toJson(),
        options: _authOptions(token),
      );
      return Employee.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

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
