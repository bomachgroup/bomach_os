import 'dart:developer';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/operations/models/models.dart';

class LegalContractService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  LegalContractService({
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

  Future<({List<Contract> items, int total})> getContracts(
    String token, {
    String? search,
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/contracts/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => Contract.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      final items =
          (data as List).map((json) => Contract.fromJson(json)).toList();
      return (items: items, total: items.length);
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
          if (data['errors'] != null) return Exception("Validation: ${data['errors']}");
          if (data.containsKey('detail')) msg = data['detail'];
          else if (data.containsKey('message')) msg = data['message'];
        }
      } else {
        msg = "Connection error. Please check your internet.";
      }
    }
    return Exception(msg);
  }
}
