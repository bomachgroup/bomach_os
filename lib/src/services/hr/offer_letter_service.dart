import 'package:dio/dio.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';

import '../../../pages/hr/models/offer_letter_model.dart';

class OfferLetterService {
  final Dio _dio;

  static const String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  OfferLetterService({
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

  /// GET /applicants/{applicantId}/offer-letters/ — list offer letters for an applicant
  Future<({List<OfferLetter> items, int count})> getOfferLetters(
    String token,
    int applicantId, {
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/applicants/$applicantId/offer-letters/',
        queryParameters: {
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final dynamic data = response.data;
      List<dynamic> list = [];
      int count = 0;

      if (data is Map<String, dynamic>) {
        if (data.containsKey('items')) list = data['items'];
        if (data.containsKey('count')) {
          count = data['count'] is int ? data['count'] : 0;
        }
      } else if (data is List) {
        list = data;
        count = list.length;
      }

      final items = list.map((json) => OfferLetter.fromJson(json)).toList();
      return (items: items, count: count);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /applicants/{applicantId}/offer-letters/ — create an offer letter
  Future<OfferLetter> createOfferLetter(
    String token,
    int applicantId,
    OfferLetter offerLetter,
  ) async {
    try {
      final response = await _dio.post(
        '/applicants/$applicantId/offer-letters/',
        data: offerLetter.toCreateJson(),
        options: _authOptions(token),
      );
      return OfferLetter.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /applicants/{applicantId}/offer-letters/{offerId} — get a single offer letter
  Future<OfferLetter> getOfferLetterById(
    String token,
    int applicantId,
    int offerId,
  ) async {
    try {
      final response = await _dio.get(
        '/applicants/$applicantId/offer-letters/$offerId',
        options: _authOptions(token),
      );
      return OfferLetter.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PATCH /applicants/{applicantId}/offer-letters/{offerId} — update an offer letter
  Future<OfferLetter> updateOfferLetter(
    String token,
    int applicantId,
    int offerId,
    OfferLetter offerLetter,
  ) async {
    try {
      final response = await _dio.patch(
        '/applicants/$applicantId/offer-letters/$offerId',
        data: offerLetter.toUpdateJson(),
        options: _authOptions(token),
      );
      return OfferLetter.fromJson(response.data);
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
