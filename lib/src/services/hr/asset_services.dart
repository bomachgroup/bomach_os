import 'dart:developer';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../../../pages/hr/models/assets_model.dart';

class AssetService {
  final Dio _dio;

  static const String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  AssetService({
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

  /// GET /api/v1/assets/ — List Assets
  Future<({List<Asset> items, int total})> getAssets(
    String token, {
    String? search,
    String? branch,
    String? departmentId,
    String? assetType,
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/assets/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (branch != null && branch != 'All') 'branch': branch,
          if (departmentId != null && departmentId != 'All')
            'department_id': departmentId,
          if (status != null && status != 'All') 'status': status,
          if (assetType != null) 'asset_type': assetType,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => Asset.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      // Fallback: data is a plain list
      final items = (data as List).map((json) => Asset.fromJson(json)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/assets/ — Create Asset
  Future<Asset> createAsset(String token, Map<String, dynamic> data) async {
    try {
      log("AssetService: Creating asset...");
      final response = await _dio.post(
        '/assets/',
        data: data,
        options: _authOptions(token),
      );
      return Asset.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/assets/{asset_id} — Get Asset
  Future<Asset> getAssetById(String token, String assetId) async {
    try {
      final response = await _dio.get(
        '/assets/$assetId',
        options: _authOptions(token),
      );
      return Asset.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/assets/{asset_id} — Update Asset
  Future<Asset> updateAsset(
      String token, String assetId, Map<String, dynamic> data) async {
    try {
      log("AssetService: Updating asset $assetId...");
      final response = await _dio.put(
        '/assets/$assetId',
        data: data,
        options: _authOptions(token),
      );
      return Asset.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/assets/{asset_id} — Delete Asset
  Future<void> deleteAsset(String token, String assetId) async {
    try {
      log("AssetService: Deleting asset $assetId...");
      await _dio.delete(
        '/assets/$assetId',
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
