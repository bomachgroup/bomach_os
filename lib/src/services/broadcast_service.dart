import 'dart:developer';
import 'package:dio/dio.dart';

import '../model/broadcast_model.dart';

class BroadcastService {
  final Dio _dio;
  static const baseUrl = "https://bomachauth.bgbot.app";

  BroadcastService({
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
    return Options(headers: {
      'Authorization': 'Bearer $token',
    });
  }

  // ─── ANNOUNCEMENT CHOICES ─────────────────────────────────────

  /// GET /api/v1/announcements/choices
  Future<AnnouncementFieldChoices> getAnnouncementChoices({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/announcements/choices',
        options: _authOptions(accessToken),
      );
      return AnnouncementFieldChoices.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ANNOUNCEMENTS CRUD ───────────────────────────────────────

  /// GET /api/v1/announcements/ — List Announcements
  Future<({List<Announcement> items, int total})> getAnnouncements({
    required String accessToken,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v1/announcements/',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        final items = (data['items'] as List)
            .map((item) => Announcement.fromJson(item))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }
      return (items: <Announcement>[], total: 0);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/announcements/ — Create Announcement
  Future<Announcement> createAnnouncement({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("BroadcastService: Creating announcement...");
      final response = await _dio.post(
        '/api/v1/announcements/',
        data: data,
        options: _authOptions(accessToken),
      );
      return Announcement.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/announcements/{id} — Get Announcement
  Future<Announcement> getAnnouncement({
    required String accessToken,
    required int id,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/announcements/$id',
        options: _authOptions(accessToken),
      );
      return Announcement.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/announcements/{id} — Update Announcement
  Future<Announcement> updateAnnouncement({
    required String accessToken,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("BroadcastService: Updating announcement $id...");
      final response = await _dio.put(
        '/api/v1/announcements/$id',
        data: data,
        options: _authOptions(accessToken),
      );
      return Announcement.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/announcements/{id} — Delete Announcement
  Future<void> deleteAnnouncement({
    required String accessToken,
    required int id,
  }) async {
    try {
      log("BroadcastService: Deleting announcement $id...");
      await _dio.delete(
        '/api/v1/announcements/$id',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── EVENTS CRUD ──────────────────────────────────────────────

  /// GET /api/v1/events/ — List Events
  Future<({List<BroadcastEvent> items, int total})> getEvents({
    required String accessToken,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {
        'limit': limit,
        'offset': offset,
      };
      if (search != null && search.isNotEmpty) queryParams['search'] = search;

      final response = await _dio.get(
        '/api/v1/events/',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        final items = (data['items'] as List)
            .map((item) => BroadcastEvent.fromJson(item))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }
      return (items: <BroadcastEvent>[], total: 0);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/events/ — Create Event
  Future<BroadcastEvent> createEvent({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("BroadcastService: Creating event...");
      final response = await _dio.post(
        '/api/v1/events/',
        data: data,
        options: _authOptions(accessToken),
      );
      return BroadcastEvent.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/events/{id} — Get Event
  Future<BroadcastEvent> getEvent({
    required String accessToken,
    required int id,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/events/$id',
        options: _authOptions(accessToken),
      );
      return BroadcastEvent.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/events/{id} — Update Event
  Future<BroadcastEvent> updateEvent({
    required String accessToken,
    required int id,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("BroadcastService: Updating event $id...");
      final response = await _dio.put(
        '/api/v1/events/$id',
        data: data,
        options: _authOptions(accessToken),
      );
      return BroadcastEvent.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/events/{id} — Delete Event
  Future<void> deleteEvent({
    required String accessToken,
    required int id,
  }) async {
    try {
      log("BroadcastService: Deleting event $id...");
      await _dio.delete(
        '/api/v1/events/$id',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ERROR HANDLER ────────────────────────────────────────────

  Exception _handleError(DioException e) {
    String msg = "An unexpected error occurred";

    if (e.response != null) {
      final data = e.response?.data;
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
    return Exception(msg);
  }
}
