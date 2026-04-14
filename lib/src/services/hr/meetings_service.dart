import 'package:bms_front_end/pages/hr/models/meeting_model.dart';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

class MeetingsService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  MeetingsService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: _baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<({List<Meeting> items, int count})> getMeetings(
    String token, {
    String? status,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/meetings/',
        queryParameters: {
          if (status != null) 'status': status,
          if (search != null && search.isNotEmpty) 'search': search,
          'limit': limit,
          'offset': offset,
        },
        options: _auth(token),
      );
      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        return (
          items:
              (data['items'] as List).map((j) => Meeting.fromJson(j)).toList(),
          count: (data['count'] as num?)?.toInt() ?? 0,
        );
      }
      final list = data as List<dynamic>;
      return (
        items: list.map((j) => Meeting.fromJson(j)).toList(),
        count: list.length,
      );
    } catch (e) {
      throw _handle(e);
    }
  }

  Future<Meeting> createMeeting(String token, Meeting meeting) async {
    try {
      final response = await _dio.post(
        '/meetings/',
        data: meeting.toJson(),
        options: _auth(token),
      );
      return Meeting.fromJson(response.data);
    } catch (e) {
      throw _handle(e);
    }
  }

  Future<Meeting> updateMeeting(String token, int id, Meeting meeting) async {
    try {
      final response = await _dio.put(
        '/meetings/$id',
        data: meeting.toJson(),
        options: _auth(token),
      );
      return Meeting.fromJson(response.data);
    } catch (e) {
      throw _handle(e);
    }
  }

  Future<void> deleteMeeting(String token, int id) async {
    try {
      await _dio.delete('/meetings/$id', options: _auth(token));
    } catch (e) {
      throw _handle(e);
    }
  }

  Exception _handle(dynamic error) {
    if (error is DioException) {
      final data = error.response?.data;
      String msg = error.message ?? 'Unknown error';
      if (data is Map<String, dynamic>) msg = data['message'] ?? msg;
      return Exception('API Error: ${error.response?.statusCode} - $msg');
    }
    return Exception('Unexpected error: $error');
  }
}
