import 'dart:developer';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:dio/dio.dart';

class SiteEquipmentService {
  final Dio _dio;

  SiteEquipmentService({
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
            )) {
    _dio.interceptors.add(LogInterceptor(
      request: true,
      requestHeader: true,
      responseBody: true,
      responseHeader: false,
    ));
  }

  Options _authOptions(String token) {
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  Future<List<SiteEquipment>> getSiteEquipment({
    required String accessToken,
    int? worksiteId,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      if (worksiteId != null) queryParams['worksite_id'] = worksiteId;
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v1/site-equipment',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        return (data['items'] as List)
            .map((item) => SiteEquipment.fromJson(item))
            .toList();
      }
      return [];
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<SiteEquipment> createSiteEquipment({
    required String accessToken,
    required SiteEquipment equipment,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/site-equipment',
        data: equipment.toJson(),
        options: _authOptions(accessToken),
      );
      return SiteEquipment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<SiteEquipment> getSiteEquipmentById({
    required String accessToken,
    required int equipmentId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/site-equipment/$equipmentId',
        options: _authOptions(accessToken),
      );
      return SiteEquipment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<SiteEquipment> updateSiteEquipment({
    required String accessToken,
    required int equipmentId,
    required SiteEquipment equipment,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/site-equipment/$equipmentId',
        data: equipment.toUpdateJson(),
        options: _authOptions(accessToken),
      );
      return SiteEquipment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<SiteEquipment> adjustSiteEquipment({
    required String accessToken,
    required int equipmentId,
    required String quantityDelta,
    required String reason,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/site-equipment/$equipmentId/adjust',
        data: {
          'quantity_delta': quantityDelta,
          'reason': reason.trim(),
        },
        options: _authOptions(accessToken),
      );
      return SiteEquipment.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteSiteEquipment({
    required String accessToken,
    required int equipmentId,
  }) async {
    try {
      await _dio.delete(
        '/api/v1/site-equipment/$equipmentId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    String msg = 'An unknown error occurred.';
    if (e.response != null) {
      final data = e.response?.data;
      log("SiteEquipment Service Error: $data");
      if (data is Map<String, dynamic>) {
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
