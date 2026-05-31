import 'dart:developer';

import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/helper/error_helper.dart';
import 'package:dio/dio.dart';

import '../model/branch_model.dart';

class BranchService {
  final Dio _dio;
  static final baseUrl = ApiConstants.baseUrl;
  BranchService({
    Dio? dioOverride,
  }) : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
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

  // GET ALL BRANCHES (With Filters)
  Future<({List<Branch> items, int total})> getBranches({
    required String accessToken,
    String? country,
    String? state,
    String? city,
    String? search,
    String? operationalStatus,
    String? branchRole,
    bool? isActive,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };

      if (country != null && country.isNotEmpty) {
        queryParams['country'] = country;
      }
      if (state != null && state.isNotEmpty) queryParams['state'] = state;
      if (city != null && city.isNotEmpty) queryParams['city'] = city;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (operationalStatus != null && operationalStatus.isNotEmpty) {
        queryParams['operational_status'] = operationalStatus;
      }
      if (branchRole != null && branchRole.isNotEmpty) {
        queryParams['branch_role'] = branchRole;
      }
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _dio.get(
        '/api/v1/branch/branches',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        final items = (data['items'] as List)
            .map((item) => Branch.fromJson(item))
            .toList();
        final total = data['total'] ?? data['count'] ?? items.length;
        return (items: items, total: total as int);
      }
      return (items: <Branch>[], total: 0);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET SINGLE BRANCH
  Future<Branch> getBranch({
    required String accessToken,
    required int branchId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/branch/branches/$branchId',
        options: _authOptions(accessToken),
      );
      return Branch.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //  CREATE BRANCH
  Future<Branch> createBranch({
    required String accessToken,
    required Map<String, dynamic> branchData,
  }) async {
    try {
      log("BranchService: Creating branch...");
      final response = await _dio.post(
        '/api/v1/branch/branches',
        data: branchData,
        options: _authOptions(accessToken),
      );
      return Branch.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // UPDATE BRANCH
  Future<Branch> updateBranch({
    required String accessToken,
    required int branchId,
    required Map<String, dynamic> updateData,
  }) async {
    try {
      log("BranchService: Updating branch $branchId...");
      final response = await _dio.put(
        '/api/v1/branch/branches/$branchId',
        data: updateData,
        options: _authOptions(accessToken),
      );
      return Branch.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  //  GET FIELD CHOICES
  Future<BranchFieldChoices> getBranchFieldChoices({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/branch/branches/choices/fields',
        options: _authOptions(accessToken),
      );
      return BranchFieldChoices.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET BRANCH PERFORMANCE
  Future<BranchPerformance> getBranchPerformance({
    required String accessToken,
    required int branchId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/branch/branches/$branchId/performance',
        options: _authOptions(accessToken),
      );
      return BranchPerformance.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final msg = ErrorHelper.getReadableErrorMessage(e);
    return Exception(msg);
  }
}
