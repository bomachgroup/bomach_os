import 'package:dio/dio.dart';

import '../../../pages/hr/models/assets_model.dart';

class AssetService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachhr.bgbot.app/api/v1';

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

  Future<List<Asset>> getAssets(
    String token, {
    String? search,
    String? branch,
    String? assetType,
    String? status,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/assets/',
        queryParameters: {
          if (search != null) 'search': search,
          if (branch != null) 'branch': branch,
          if (assetType != null) 'asset_type': assetType,
          if (status != null) 'status': status,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => Asset.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Asset> createAsset(String token, Asset asset) async {
    try {
      final response = await _dio.post(
        '/assets/',
        data: asset.toJson(),
        options: _authOptions(token),
      );
      return Asset.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

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

  Future<Asset> updateAsset(String token, String assetId, Asset asset) async {
    try {
      final response = await _dio.put(
        '/assets/$assetId',
        data: asset.toJson(),
        options: _authOptions(token),
      );
      return Asset.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteAsset(String token, String assetId) async {
    try {
      await _dio.delete(
        '/assets/$assetId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final errorMessage = error.response?.data?['message'] ?? error.message;
      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
