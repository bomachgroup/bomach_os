import 'dart:developer';
import 'package:dio/dio.dart';

import '../model/branch_model.dart';

class BranchService {
  final Dio _dio;

  BranchService({
    required String baseUrl,
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
            ));

  Options _authOptions(String token) {
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // GET ALL BRANCHES (With Filters)
  Future<List<Branch>> getBranches({
    required String accessToken,
    int? countryId,
    int? stateId,
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

      if (countryId != null) queryParams['country_id'] = countryId;
      if (stateId != null) queryParams['state_id'] = stateId;
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
        return (data['items'] as List)
            .map((item) => Branch.fromJson(item))
            .toList();
      }
      return [];
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

  // GET COUNTRIES
  Future<List<Country>> getCountries({
    required String accessToken,
    bool? isActive,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (isActive != null) queryParams['is_active'] = isActive;

      final response = await _dio.get(
        '/api/v1/branch/countries',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        return (data['items'] as List)
            .map((item) => Country.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET STATES
  Future<List<StateModel>> getStates({
    required String accessToken,
    int? countryId,
    String? search,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (countryId != null) queryParams['country_id'] = countryId;
      if (search != null) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v1/branch/states',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        return (data['items'] as List)
            .map((item) => StateModel.fromJson(item))
            .toList();
      }
      return [];
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

  // GET SINGLE COUNTRY
  Future<Country> getCountry({
    required String accessToken,
    required int countryId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/branch/countries/$countryId',
        options: _authOptions(accessToken),
      );
      return Country.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // GET SINGLE STATE
  Future<StateModel> getState({
    required String accessToken,
    required int stateId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/branch/states/$stateId',
        options: _authOptions(accessToken),
      );
      return StateModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ERROR HANDLER
  Exception _handleError(DioException e) {
    String msg = "An unexpected error occurred";

    if (e.response != null) {
      final data = e.response?.data;
      log("SERVER ERROR: $data");

      if (data is Map<String, dynamic>) {
        // Validation Errors
        if (data['errors'] != null) {
          return Exception("Validation: ${data['errors']}");
        }
        // Generic Messages
        if (data.containsKey('detail')) {
          msg = data['detail'];
        } else if (data.containsKey('message')) {
          msg = data['message'];
        }
      }
    } else {
      msg = "Connection error. Please check your internet.";
    }
    return Exception(msg);
  }
}
