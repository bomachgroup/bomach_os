import 'dart:developer';
import 'package:bms_front_end/components/feedback/app_toast.dart';

import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';

import '../models/department_model.dart';

class DepartmentController extends GetxController {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  final Dio _dio = Dio(BaseOptions(
    baseUrl: ApiConstants.baseUrl,
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  var isLoading = false.obs;
  var isSaving = false.obs;
  var departments = <Department>[].obs;
  var searchQuery = ''.obs;

  Future<void> fetchDepartments(BuildContext context, {String? search}) async {
    try {
      isLoading.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      final response = await _dio.get(
        '/api/v1/employees/department',
        queryParameters: {
          'limit': 100,
          'offset': 0,
          if (search != null && search.isNotEmpty) 'search': search,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      List<dynamic> list = [];

      if (data is Map<String, dynamic> && data.containsKey('items')) {
        list = data['items'];
      } else if (data is List) {
        list = data;
      }

      final depts = list.map((json) => Department.fromJson(json)).toList();

      // Fetch first 3 employees for each department
      for (final dept in depts) {
        try {
          final empResponse = await _dio.get(
            '/api/v1/employees/employees',
            queryParameters: {
              'department_id': dept.id,
              'limit': 3,
              'offset': 0,
            },
            options: Options(headers: {'Authorization': 'Bearer $token'}),
          );

          final empData = empResponse.data;
          List<dynamic> empList = [];
          int count = 0;

          if (empData is Map<String, dynamic>) {
            if (empData.containsKey('items')) empList = empData['items'];
            if (empData.containsKey('count')) {
              count = empData['count'] is int ? empData['count'] : 0;
            }
          } else if (empData is List) {
            empList = empData;
            count = empList.length;
          }

          dept.employees =
              empList.map((j) => DepartmentEmployee.fromJson(j)).toList();
          dept.employeeCount = count;
        } catch (e) {
          log("Failed to fetch employees for dept ${dept.id}: $e");
        }
      }

      departments.assignAll(depts);
    } catch (e) {
      log("Fetch Departments Error: $e");
      if (context.mounted) {
        _showSnackBar(context, _errorMessage(e), isError: true);
      }
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> createDepartment(
    BuildContext context, {
    required String name,
    required String description,
  }) async {
    try {
      isSaving.value = true;

      final token = await _getToken(context);
      if (token == null) return;

      await _dio.post(
        '/api/v1/employees/department',
        data: {
          'name': name,
          'description': description,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      if (context.mounted) {
        Navigator.of(context).pop();
        _showSnackBar(context, "Department created successfully");
      }

      if (!context.mounted) return;
      await fetchDepartments(context);
    } catch (e) {
      log("Create Department Error: $e");
      if (context.mounted) {
        _showSnackBar(context, _errorMessage(e), isError: true);
      }
    } finally {
      isSaving.value = false;
    }
  }

  void onSearch(BuildContext context, String query) {
    searchQuery.value = query;
    fetchDepartments(context, search: query.isEmpty ? null : query);
  }

  Future<String?> _getToken(BuildContext context) async {
    String? token = await _storage.read(key: 'access_token');

    if (token == null) {
      if (context.mounted) {
        _showSnackBar(context, "Authentication Error: Please login again",
            isError: true);
      }
      return null;
    }

    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    token = token.replaceAll('"', '').trim();

    return token;
  }

  String _errorMessage(dynamic error) {
    if (error is DioException && error.response?.data is Map<String, dynamic>) {
      final data = error.response!.data as Map<String, dynamic>;
      return data['detail'] ?? data['message'] ?? 'An unknown error occurred';
    }
    return 'An unknown error occurred';
  }

  void _showSnackBar(BuildContext context, String message,
      {bool isError = false}) {
    if (!context.mounted) return;
    AppToast.info(context, message);
  }
}
