import 'package:dio/dio.dart';

import '../../../pages/hr/models/awards_model.dart';

class AwardService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachauth.bgbot.app/api/v1';

  AwardService({
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

  Future<List<Award>> getAwards(
    String token, {
    int? year,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/awards/',
        queryParameters: {
          if (year != null) 'year': year,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      final List<dynamic> list =
          (data is Map && data.containsKey('items')) ? data['items'] : data;

      return list.map((json) => Award.fromJson(json)).toList();
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Award> createAward(String token, Award award) async {
    try {
      final response = await _dio.post(
        '/awards/',
        data: award.toJson(),
        options: _authOptions(token),
      );
      return Award.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Award> getAwardById(String token, String awardId) async {
    try {
      final response = await _dio.get(
        '/awards/$awardId',
        options: _authOptions(token),
      );
      return Award.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<Award> updateAward(String token, String awardId, Award award) async {
    try {
      final response = await _dio.put(
        '/awards/$awardId',
        data: award.toJson(),
        options: _authOptions(token),
      );
      return Award.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteAward(String token, String awardId) async {
    try {
      await _dio.delete(
        '/awards/$awardId',
        options: _authOptions(token),
      );
    } catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      String errorMessage = error.message ?? 'Unknown API error';

      if (error.response?.data != null) {
        final data = error.response!.data;

        if (data is Map<String, dynamic>) {
          errorMessage = data['message'] ?? errorMessage;
        } else if (data is String) {
          errorMessage = data;
        }
      }

      return Exception(
          'API Error: ${error.response?.statusCode} - $errorMessage');
    }
    return Exception('Unexpected error: $error');
  }
}
