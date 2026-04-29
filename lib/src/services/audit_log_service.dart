  import 'dart:developer';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

class AuditLogUser {
  final int id;
  final String email;
  final String fullName;

  AuditLogUser({
    required this.id,
    required this.email,
    required this.fullName,
  });

  factory AuditLogUser.fromJson(Map<String, dynamic> json) {
    return AuditLogUser(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      fullName: json['full_name'] ?? '',
    );
  }
}

class AuditLogResponse {
  final int id;
  final String activity;
  final String auditType;
  final String auditTypeDisplay;
  final String auditStatus;
  final String auditStatusDisplay;
  final String? ipAddress;
  final Map<String, dynamic>? metadata;
  final AuditLogUser? user;
  final String createdAt;
  final String updatedAt;

  AuditLogResponse({
    required this.id,
    required this.activity,
    required this.auditType,
    required this.auditTypeDisplay,
    required this.auditStatus,
    required this.auditStatusDisplay,
    this.ipAddress,
    this.metadata,
    this.user,
    required this.createdAt,
    required this.updatedAt,
  });

  factory AuditLogResponse.fromJson(Map<String, dynamic> json) {
    return AuditLogResponse(
      id: json['id'] ?? 0,
      activity: json['activity'] ?? '',
      auditType: json['audit_type'] ?? '',
      auditTypeDisplay: json['audit_type_display'] ?? '',
      auditStatus: json['audit_status'] ?? '',
      auditStatusDisplay: json['audit_status_display'] ?? '',
      ipAddress: json['ip_address'],
      metadata: json['metadata'] != null
          ? Map<String, dynamic>.from(json['metadata'])
          : null,
      user: json['user'] != null ? AuditLogUser.fromJson(json['user']) : null,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class AuditLogService {
  final Dio _dio;

  static final String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  AuditLogService({
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

  /// GET /api/v1/audit-logs/ — List Audit Logs
  Future<({List<AuditLogResponse> items, int total})> getAuditLogs(
    String token, {
    String? search,
    String? userId,
    String? auditType,
    String? auditStatus,
    String? startDate,
    String? endDate,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/audit-logs/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (userId != null && userId.isNotEmpty) 'user_id': userId,
          if (auditType != null && auditType.isNotEmpty)
            'audit_type': auditType,
          if (auditStatus != null && auditStatus.isNotEmpty)
            'audit_status': auditStatus,
          if (startDate != null && startDate.isNotEmpty)
            'start_date': startDate,
          if (endDate != null && endDate.isNotEmpty) 'end_date': endDate,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((json) => AuditLogResponse.fromJson(json))
            .toList();
        final total = data['count'] ?? data['total'] ?? items.length;
        return (items: items, total: total as int);
      }

      // Fallback: data is a plain list
      final items = (data as List)
          .map((json) => AuditLogResponse.fromJson(json))
          .toList();
      return (items: items, total: items.length);
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
