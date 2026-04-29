import 'dart:developer';

import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

class Event {
  final int id;
  final String eventId;
  final String title;
  final String eventType;
  final String eventTimeFrom;
  final String eventTimeTo;
  final String? meetingLocation;
  final List<String> targetAudience;
  final String status;
  final int? reminderOffset;
  final bool isRecurring;
  final String? recurrence;
  final String? organizerName;
  final String createdAt;
  final String updatedAt;

  Event({
    required this.id,
    required this.eventId,
    required this.title,
    required this.eventType,
    required this.eventTimeFrom,
    required this.eventTimeTo,
    this.meetingLocation,
    required this.targetAudience,
    required this.status,
    this.reminderOffset,
    required this.isRecurring,
    this.recurrence,
    this.organizerName,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Event.fromJson(Map<String, dynamic> json) {
    return Event(
      id: json['id'] as int,
      eventId: json['event_id'] as String,
      title: json['title'] as String,
      eventType: json['event_type'] as String,
      eventTimeFrom: json['event_time_from'] as String,
      eventTimeTo: json['event_time_to'] as String,
      meetingLocation: json['meeting_location'] as String?,
      targetAudience: (json['target_audience'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList() ??
          [],
      status: json['status'] as String,
      reminderOffset: json['reminder_offset'] as int?,
      isRecurring: json['is_recurring'] as bool? ?? false,
      recurrence: json['recurrence'] as String?,
      organizerName: json['organizer_name'] as String?,
      createdAt: json['created_at'] as String,
      updatedAt: json['updated_at'] as String,
    );
  }
}

class EventService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  EventService({
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

  /// GET /api/v1/events/ — List Events
  Future<({List<Event> items, int total})> getEvents(
    String token, {
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/events/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => Event.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      // Fallback: data is a plain list
      final items = (data as List).map((json) => Event.fromJson(json)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// POST /api/v1/events/ — Create Event
  Future<Event> createEvent(String token, Map<String, dynamic> data) async {
    try {
      log("EventService: Creating event...");
      final response = await _dio.post(
        '/events/',
        data: data,
        options: _authOptions(token),
      );
      return Event.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// GET /api/v1/events/{id}/ — Get Event by ID
  Future<Event> getEventById(String token, int eventId) async {
    try {
      final response = await _dio.get(
        '/events/$eventId/',
        options: _authOptions(token),
      );
      return Event.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// PUT /api/v1/events/{id}/ — Update Event
  Future<Event> updateEvent(
      String token, int eventId, Map<String, dynamic> data) async {
    try {
      log("EventService: Updating event $eventId...");
      final response = await _dio.put(
        '/events/$eventId/',
        data: data,
        options: _authOptions(token),
      );
      return Event.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// DELETE /api/v1/events/{id}/ — Delete Event
  Future<void> deleteEvent(String token, int eventId) async {
    try {
      log("EventService: Deleting event $eventId...");
      await _dio.delete(
        '/events/$eventId/',
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
