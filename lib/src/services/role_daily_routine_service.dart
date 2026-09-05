import 'package:dio/dio.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/model/role_daily_routine_model.dart';

class RoleDailyRoutineService {
  final Dio _dio;

  RoleDailyRoutineService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
              baseUrl: ApiConstants.baseUrl,
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 15),
              headers: {
                'Content-Type': 'application/json',
                'Accept': 'application/json',
              },
            ));

  Options _authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<({List<RoleDailyRoutineItem> list, int count})> listRoutine(
    String token, {
    required int roleId,
    bool? isActive,
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final queryParameters = <String, dynamic>{
        'limit': limit,
        'offset': offset,
        if (isActive != null) 'is_active': isActive,
        if (search != null && search.isNotEmpty) 'search': search,
      };
      final response = await _dio.get(
        '/api/v1/roles/$roleId/daily-routine',
        queryParameters: queryParameters,
        options: _authOptions(token),
      );
      final data = response.data;
      final items = data is Map
          ? (data['items'] as List? ?? const [])
          : (data as List? ?? const []);
      return (
        list: items
            .map((item) => RoleDailyRoutineItem.fromJson(
                Map<String, dynamic>.from(item as Map)))
            .toList(),
        count: data is Map ? _toInt(data['count'], items.length) : items.length,
      );
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<RoleDailyRoutineItem> createRoutine(
    String token,
    int roleId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.post(
        '/api/v1/roles/$roleId/daily-routine',
        data: payload,
        options: _authOptions(token),
      );
      return RoleDailyRoutineItem.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<RoleDailyRoutineItem> updateRoutine(
    String token,
    int roleId,
    int routineItemId,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await _dio.patch(
        '/api/v1/roles/$roleId/daily-routine/$routineItemId',
        data: payload,
        options: _authOptions(token),
      );
      return RoleDailyRoutineItem.fromJson(
          Map<String, dynamic>.from(response.data as Map));
    } catch (error) {
      throw _handleError(error);
    }
  }

  Future<void> deleteRoutine(
      String token, int roleId, int routineItemId) async {
    try {
      await _dio.delete(
        '/api/v1/roles/$roleId/daily-routine/$routineItemId',
        options: _authOptions(token),
      );
    } catch (error) {
      throw _handleError(error);
    }
  }

  static int _toInt(dynamic value, int fallback) => value is num
      ? value.toInt()
      : int.tryParse(value?.toString() ?? '') ?? fallback;

  Exception _handleError(dynamic error) {
    if (error is DioException) {
      final body = error.response?.data;
      final detail =
          body is Map ? (body['detail'] ?? body['message']) : error.message;
      return Exception('API Error: ${error.response?.statusCode} - $detail');
    }
    return Exception('Unexpected error: $error');
  }
}
