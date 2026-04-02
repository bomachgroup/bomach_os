import 'package:dio/dio.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';

import '../model/partner_model.dart';

class PartnerService {
  final Dio _dio;
  static const baseUrl = ApiConstants.baseUrl;

  PartnerService({
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

  // ─── PARTNERS ─────────────────────────────────────────────────

  Future<({List<Partner> items, int count})> getPartners({
    required String accessToken,
    String? category,
    String? status,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (category != null) params['category'] = category;
      if (status != null) params['status'] = status;
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response = await _dio.get(
        '/api/v1/partners/',
        queryParameters: params,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      final items =
          (data['items'] as List).map((e) => Partner.fromJson(e)).toList();
      return (items: items, count: (data['count'] as int?) ?? 0);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['detail'] ?? 'Failed to fetch partners');
    }
  }

  Future<Partner> getPartner({
    required String accessToken,
    required int partnerId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/partners/$partnerId',
        options: _authOptions(accessToken),
      );
      return Partner.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(e.response?.data?['detail'] ?? 'Failed to fetch partner');
    }
  }

  Future<Partner> createPartner({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/partners/',
        data: data,
        options: _authOptions(accessToken),
      );
      return Partner.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['detail'] ?? 'Failed to create partner');
    }
  }

  Future<Partner> updatePartner({
    required String accessToken,
    required int partnerId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/partners/$partnerId',
        data: data,
        options: _authOptions(accessToken),
      );
      return Partner.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['detail'] ?? 'Failed to update partner');
    }
  }

  Future<void> deletePartner({
    required String accessToken,
    required int partnerId,
  }) async {
    try {
      await _dio.delete(
        '/api/v1/partners/$partnerId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['detail'] ?? 'Failed to delete partner');
    }
  }

  // ─── AGREEMENTS ───────────────────────────────────────────────

  Future<({List<PartnerAgreement> items, int count})> getAgreements({
    required String accessToken,
    required int partnerId,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final params = <String, dynamic>{
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.isNotEmpty) params['search'] = search;

      final response = await _dio.get(
        '/api/v1/partners/$partnerId/agreements',
        queryParameters: params,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      final items = (data['items'] as List)
          .map((e) => PartnerAgreement.fromJson(e))
          .toList();
      return (items: items, count: (data['count'] as int?) ?? 0);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['detail'] ?? 'Failed to fetch agreements');
    }
  }

  Future<PartnerAgreement> createAgreement({
    required String accessToken,
    required int partnerId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.post(
        '/api/v1/partners/$partnerId/agreements',
        data: data,
        options: _authOptions(accessToken),
      );
      return PartnerAgreement.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['detail'] ?? 'Failed to create agreement');
    }
  }

  Future<PartnerAgreement> updateAgreement({
    required String accessToken,
    required int partnerId,
    required int agreementId,
    required Map<String, dynamic> data,
  }) async {
    try {
      final response = await _dio.put(
        '/api/v1/partners/$partnerId/agreements/$agreementId',
        data: data,
        options: _authOptions(accessToken),
      );
      return PartnerAgreement.fromJson(response.data);
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['detail'] ?? 'Failed to update agreement');
    }
  }

  Future<void> deleteAgreement({
    required String accessToken,
    required int partnerId,
    required int agreementId,
  }) async {
    try {
      await _dio.delete(
        '/api/v1/partners/$partnerId/agreements/$agreementId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw Exception(
          e.response?.data?['detail'] ?? 'Failed to delete agreement');
    }
  }
}
