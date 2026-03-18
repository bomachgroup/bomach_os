import 'dart:developer';
import 'package:dio/dio.dart';

import '../../../pages/legal/models/compliance_record_model.dart';

class ComplianceService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachauth.bgbot.app/api/v1';

  ComplianceService({
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

  /// GET /api/v1/compliance/compliance-records — List Compliance Records
  Future<({List<ComplianceRecord> items, int total})> getRecords(
    String token, {
    String? search,
    String? complianceType,
    String? dateFrom,
    String? dateTo,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/compliance/compliance-records',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (complianceType != null && complianceType.isNotEmpty)
            'compliance_type': complianceType,
          if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
          if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => ComplianceRecord.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      final items = (data as List)
          .map((json) => ComplianceRecord.fromJson(json))
          .toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/compliance/compliance-records — Create Compliance Record
  Future<ComplianceRecord> createRecord(
      String token, Map<String, dynamic> data) async {
    try {
      log("ComplianceService: Creating record...");
      final response = await _dio.post(
        '/compliance/compliance-records',
        data: data,
        options: _authOptions(token),
      );
      return ComplianceRecord.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/compliance/compliance-records/{id} — Get Record by ID
  Future<ComplianceRecord> getRecordById(String token, int recordId) async {
    try {
      final response = await _dio.get(
        '/compliance/compliance-records/$recordId',
        options: _authOptions(token),
      );
      return ComplianceRecord.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/compliance/compliance-records/{id} — Update Record
  Future<ComplianceRecord> updateRecord(
      String token, int recordId, Map<String, dynamic> data) async {
    try {
      log("ComplianceService: Updating record $recordId...");
      final response = await _dio.put(
        '/compliance/compliance-records/$recordId',
        data: data,
        options: _authOptions(token),
      );
      return ComplianceRecord.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/compliance/compliance-records/{id} — Delete Record
  Future<void> deleteRecord(String token, int recordId) async {
    try {
      log("ComplianceService: Deleting record $recordId...");
      await _dio.delete(
        '/compliance/compliance-records/$recordId',
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
