import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/helper/error_helper.dart';
import 'package:bomach_os/src/model/broadcast_model.dart';
import 'package:dio/dio.dart';

class NotificationService {
  final Dio _dio;

  NotificationService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: '${ApiConstants.baseUrl}/api/v1',
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: const {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

  Options _auth(String token) => Options(
        headers: {'Authorization': 'Bearer $token'},
      );

  Future<({List<NotificationItem> items, int total})> list({
    required String token,
    bool? isRead,
    int limit = 50,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/notifications/',
        queryParameters: {
          'limit': limit,
          'offset': offset,
          if (isRead != null) 'is_read': isRead,
        },
        options: _auth(token),
      );
      final data = response.data;
      final rawItems = data is List
          ? data
          : data is Map && data['items'] is List
              ? data['items'] as List
              : const <dynamic>[];
      final items = rawItems
          .whereType<Map>()
          .map((item) => NotificationItem.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList();
      final total = data is Map
          ? (data['count'] ?? data['total'] ?? items.length)
          : items.length;
      return (
        items: items,
        total: total is int ? total : int.tryParse('$total') ?? items.length,
      );
    } on DioException catch (e) {
      throw Exception(ErrorHelper.getReadableErrorMessage(e));
    }
  }

  Future<int> unreadCount({required String token}) async {
    try {
      final response = await _dio.get(
        '/notifications/stats',
        options: _auth(token),
      );
      final count =
          response.data is Map ? (response.data['unread_count'] ?? 0) : 0;
      return count is int ? count : int.tryParse('$count') ?? 0;
    } on DioException catch (e) {
      throw Exception(ErrorHelper.getReadableErrorMessage(e));
    }
  }

  Future<NotificationItem> markRead({
    required String token,
    required int notificationId,
  }) async {
    try {
      final response = await _dio.patch(
        '/notifications/$notificationId/read',
        options: _auth(token),
      );
      return NotificationItem.fromJson(
        Map<String, dynamic>.from(response.data),
      );
    } on DioException catch (e) {
      throw Exception(ErrorHelper.getReadableErrorMessage(e));
    }
  }

  Future<void> markAllRead({required String token}) async {
    try {
      await _dio.post('/notifications/read-all', options: _auth(token));
    } on DioException catch (e) {
      throw Exception(ErrorHelper.getReadableErrorMessage(e));
    }
  }
}
