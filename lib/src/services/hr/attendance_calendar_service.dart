import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

class AttendanceCalendarEntry {
  final int id;
  final String name;
  final String kind;
  final DateTime startDate;
  final DateTime endDate;
  final String reason;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? createdByName;
  final String? updatedByName;

  const AttendanceCalendarEntry({
    required this.id,
    required this.name,
    required this.kind,
    required this.startDate,
    required this.endDate,
    required this.reason,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdByName,
    this.updatedByName,
  });

  factory AttendanceCalendarEntry.fromJson(Map<String, dynamic> json) {
    return AttendanceCalendarEntry(
      id: json['id'] as int,
      name: json['name'] as String,
      kind: json['kind'] as String,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      reason: json['reason'] as String,
      isActive: json['is_active'] as bool,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      createdByName: json['created_by_name'] as String?,
      updatedByName: json['updated_by_name'] as String?,
    );
  }
}

class AttendanceCalendarService {
  final Dio _dio;

  AttendanceCalendarService({Dio? dio})
      : _dio = dio ??
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

  Future<List<AttendanceCalendarEntry>> list(String token) async {
    final response = await _dio.get(
      '/organization/non-working-days',
      queryParameters: {'include_inactive': true},
      options: _auth(token),
    );
    final items = response.data as List<dynamic>;
    return items
        .map((item) => AttendanceCalendarEntry.fromJson(
            Map<String, dynamic>.from(item as Map)))
        .toList();
  }

  Future<AttendanceCalendarEntry> create(
    String token, {
    required String name,
    required String kind,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final response = await _dio.post(
      '/organization/non-working-days',
      data: {
        'name': name,
        'kind': kind,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      },
      options: _auth(token),
    );
    return AttendanceCalendarEntry.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  Future<AttendanceCalendarEntry> update(
    String token,
    int id, {
    required String name,
    required String kind,
    required String startDate,
    required String endDate,
    required String reason,
  }) async {
    final response = await _dio.patch(
      '/organization/non-working-days/$id',
      data: {
        'name': name,
        'kind': kind,
        'start_date': startDate,
        'end_date': endDate,
        'reason': reason,
      },
      options: _auth(token),
    );
    return AttendanceCalendarEntry.fromJson(
        Map<String, dynamic>.from(response.data as Map));
  }

  Future<void> deactivate(String token, int id) async {
    await _dio.post(
      '/organization/non-working-days/$id/deactivate',
      options: _auth(token),
    );
  }
}
