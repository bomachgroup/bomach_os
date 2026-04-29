import 'dart:developer';

import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

import '../model/board_model.dart';

class BoardService {
  final Dio _dio;
  static final baseUrl = ApiConstants.baseUrl;

  BoardService({
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

  // ─── MEETING CHOICES ───────────────────────────────────────────

  /// GET /api/v1/meetings/choices
  Future<MeetingFieldChoices> getMeetingChoices({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/meetings/choices',
        options: _authOptions(accessToken),
      );
      return MeetingFieldChoices.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── MEETINGS CRUD ─────────────────────────────────────────────

  /// GET /api/v1/meetings/ — List Meetings
  Future<({List<BoardMeeting> items, int total})> getMeetings({
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
        '/api/v1/meetings/',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        final items = (data['items'] as List)
            .map((item) => BoardMeeting.fromJson(item))
            .toList();
        final total = data['total'] ?? data['count'] ?? items.length;
        return (items: items, total: total as int);
      }
      return (items: <BoardMeeting>[], total: 0);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/meetings/{meeting_id} — Get Meeting
  Future<BoardMeeting> getMeeting({
    required String accessToken,
    required int meetingId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/meetings/$meetingId',
        options: _authOptions(accessToken),
      );
      return BoardMeeting.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/meetings/ — Create Meeting
  /// Body: { title, agenda, meeting_date, meeting_time, duration_minutes,
  ///         status, location_type, location, attendee_ids, notes, file_url }
  Future<BoardMeeting> createMeeting({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("BoardService: Creating meeting...");
      final response = await _dio.post(
        '/api/v1/meetings/',
        data: data,
        options: _authOptions(accessToken),
      );
      return BoardMeeting.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/meetings/{meeting_id} — Update Meeting
  Future<BoardMeeting> updateMeeting({
    required String accessToken,
    required int meetingId,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("BoardService: Updating meeting $meetingId...");
      final response = await _dio.put(
        '/api/v1/meetings/$meetingId',
        data: data,
        options: _authOptions(accessToken),
      );
      return BoardMeeting.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/meetings/{meeting_id} — Cancel Meeting
  Future<void> cancelMeeting({
    required String accessToken,
    required int meetingId,
  }) async {
    try {
      log("BoardService: Cancelling meeting $meetingId...");
      await _dio.delete(
        '/api/v1/meetings/$meetingId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── RESOLUTION CHOICES ────────────────────────────────────────

  /// GET /api/v1/board-resolutions/choices
  Future<ResolutionFieldChoices> getResolutionChoices({
    required String accessToken,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/board-resolutions/choices',
        options: _authOptions(accessToken),
      );
      return ResolutionFieldChoices.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── RESOLUTIONS CRUD ──────────────────────────────────────────

  /// GET /api/v1/board-resolutions/ — List Board Resolutions
  Future<({List<BoardResolution> items, int total})> getResolutions({
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
        '/api/v1/board-resolutions/',
        queryParameters: queryParams,
        options: _authOptions(accessToken),
      );

      final data = response.data;
      if (data != null && data['items'] is List) {
        final items = (data['items'] as List)
            .map((item) => BoardResolution.fromJson(item))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }
      return (items: <BoardResolution>[], total: 0);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/board-resolutions/{resolution_id} — Get Board Resolution
  Future<BoardResolution> getResolution({
    required String accessToken,
    required int resolutionId,
  }) async {
    try {
      final response = await _dio.get(
        '/api/v1/board-resolutions/$resolutionId',
        options: _authOptions(accessToken),
      );
      return BoardResolution.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/board-resolutions/ — Create Board Resolution
  Future<BoardResolution> createResolution({
    required String accessToken,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("BoardService: Creating resolution...");
      final response = await _dio.post(
        '/api/v1/board-resolutions/',
        data: data,
        options: _authOptions(accessToken),
      );
      return BoardResolution.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/board-resolutions/{resolution_id} — Update Board Resolution
  Future<BoardResolution> updateResolution({
    required String accessToken,
    required int resolutionId,
    required Map<String, dynamic> data,
  }) async {
    try {
      log("BoardService: Updating resolution $resolutionId...");
      final response = await _dio.put(
        '/api/v1/board-resolutions/$resolutionId',
        data: data,
        options: _authOptions(accessToken),
      );
      return BoardResolution.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/board-resolutions/{resolution_id} — Archive Board Resolution
  Future<void> archiveResolution({
    required String accessToken,
    required int resolutionId,
  }) async {
    try {
      log("BoardService: Archiving resolution $resolutionId...");
      await _dio.delete(
        '/api/v1/board-resolutions/$resolutionId',
        options: _authOptions(accessToken),
      );
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/board-resolutions/{resolution_id}/approve — Approve Board Resolution
  Future<BoardResolution> approveResolution({
    required String accessToken,
    required int resolutionId,
  }) async {
    try {
      log("BoardService: Approving resolution $resolutionId...");
      final response = await _dio.post(
        '/api/v1/board-resolutions/$resolutionId/approve',
        options: _authOptions(accessToken),
      );
      return BoardResolution.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  // ─── ERROR HANDLER ─────────────────────────────────────────────

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
