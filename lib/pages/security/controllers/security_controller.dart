import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuditLogEntry {
  final int id;
  final String activity;
  final String auditType;
  final String auditTypeDisplay;
  final String auditStatus;
  final String auditStatusDisplay;
  final String? ipAddress;
  final String? userFullName;
  final String? userEmail;
  final String createdAt;

  AuditLogEntry({
    required this.id,
    required this.activity,
    required this.auditType,
    required this.auditTypeDisplay,
    required this.auditStatus,
    required this.auditStatusDisplay,
    this.ipAddress,
    this.userFullName,
    this.userEmail,
    required this.createdAt,
  });

  factory AuditLogEntry.fromJson(Map<String, dynamic> json) {
    final user = json['user'];
    return AuditLogEntry(
      id: json['id'] ?? 0,
      activity: json['activity'] ?? '',
      auditType: json['audit_type'] ?? '',
      auditTypeDisplay: json['audit_type_display'] ?? json['audit_type'] ?? '',
      auditStatus: json['audit_status'] ?? '',
      auditStatusDisplay:
          json['audit_status_display'] ?? json['audit_status'] ?? '',
      ipAddress: json['ip_address'],
      userFullName: user is Map ? user['full_name'] : null,
      userEmail: user is Map ? user['email'] : null,
      createdAt: json['created_at'] ?? '',
    );
  }
}

class SecurityController extends GetxController {
  final _storage = const FlutterSecureStorage();
  final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://bomachauth.bgbot.app/api/v1',
    connectTimeout: const Duration(seconds: 15),
    receiveTimeout: const Duration(seconds: 15),
    headers: {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    },
  ));

  var isLoading = true.obs;
  var auditLogs = <AuditLogEntry>[].obs;
  var totalLogs = 0.obs;
  var searchQuery = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchAuditLogs();
  }

  Future<void> fetchAuditLogs({bool refresh = false}) async {
    try {
      if (!refresh) isLoading.value = true;
      final token = await _getToken();
      if (token == null) return;

      final response = await _dio.get(
        '/audit-logs/',
        queryParameters: {
          if (searchQuery.value.isNotEmpty) 'search': searchQuery.value,
          'limit': 100,
          'offset': 0,
        },
        options: Options(headers: {'Authorization': 'Bearer $token'}),
      );

      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((j) => AuditLogEntry.fromJson(j))
            .toList();
        auditLogs.assignAll(items);
        totalLogs.value = (data['count'] ?? items.length) as int;
      }
    } catch (e) {
      log("Error fetching audit logs: $e");
    } finally {
      isLoading.value = false;
    }
  }

  void onSearchChanged(String val) {
    searchQuery.value = val;
    fetchAuditLogs();
  }

  Future<String?> _getToken() async {
    String? token = await _storage.read(key: 'access_token');
    if (token == null) return null;
    if (token.startsWith("Bearer ")) {
      token = token.replaceFirst("Bearer ", "");
    }
    return token.replaceAll('"', '').trim();
  }
}
