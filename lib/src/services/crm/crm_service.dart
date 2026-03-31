import 'dart:developer';
import 'package:dio/dio.dart';

class CrmClient {
  final int id;
  final int userId;
  final String firstName;
  final String lastName;
  final String email;
  final String? profilePicture;
  final String? address;
  final String? phoneNumber;
  final String? gender;
  final double balance;
  final String createdAt;
  final String updatedAt;

  CrmClient({
    required this.id,
    required this.userId,
    required this.firstName,
    required this.lastName,
    required this.email,
    this.profilePicture,
    this.address,
    this.phoneNumber,
    this.gender,
    required this.balance,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory CrmClient.fromJson(Map<String, dynamic> json) {
    return CrmClient(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      profilePicture: json['profile_picture'],
      address: json['address'],
      phoneNumber: json['phone_number'],
      gender: json['gender'],
      balance: double.tryParse(json['balance']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class CrmLead {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final String gender;
  final String maritalStatus;
  final String address;
  final String? phoneNumber;
  final String? profilePicture;
  final String source;
  final String status;
  final String? companyName;
  final String interestedServices;
  final String? assignedToName;
  final String notes;
  final String createdAt;
  final String updatedAt;

  CrmLead({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.gender,
    required this.maritalStatus,
    required this.address,
    this.phoneNumber,
    this.profilePicture,
    required this.source,
    required this.status,
    this.companyName,
    required this.interestedServices,
    this.assignedToName,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  String get fullName => '$firstName $lastName';

  factory CrmLead.fromJson(Map<String, dynamic> json) {
    return CrmLead(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      gender: json['gender'] ?? '',
      maritalStatus: json['marital_status'] ?? '',
      address: json['address'] ?? '',
      phoneNumber: json['phone_number'],
      profilePicture: json['profile_picture'],
      source: json['source'] ?? '',
      status: json['status'] ?? '',
      companyName: json['company_name'],
      interestedServices: json['interested_services'] ?? '',
      assignedToName: json['assigned_to_name'],
      notes: json['notes'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class CrmService {
  final Dio _dio;

  static const String _baseUrl = 'https://bomachauth.bgbot.app/api/v1';

  CrmService({Dio? dioOverride})
      : _dio = dioOverride ??
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
    return Options(headers: {'Authorization': 'Bearer $token'});
  }

  // ─── LEADS ────────────────────────────────────────────────────────

  Future<({List<CrmLead> items, int total})> getLeads(
    String token, {
    String? search,
    String? status,
    String? source,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/clients/leads/',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          if (source != null && source.isNotEmpty) 'source': source,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );
      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((j) => CrmLead.fromJson(j))
            .toList();
        return (items: items, total: (data['count'] ?? items.length) as int);
      }
      final items =
          (data as List).map((j) => CrmLead.fromJson(j)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CrmLead> createLead(
      String token, Map<String, dynamic> data) async {
    try {
      log("CrmService: Creating lead...");
      final response = await _dio.post(
        '/clients/leads/',
        data: data,
        options: _authOptions(token),
      );
      return CrmLead.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CrmLead> updateLead(
      String token, int leadId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/clients/leads/$leadId/',
        data: data,
        options: _authOptions(token),
      );
      return CrmLead.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteLead(String token, int leadId) async {
    try {
      await _dio.delete('/clients/leads/$leadId/',
          options: _authOptions(token));
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CrmLead> convertLeadToClient(String token, int leadId) async {
    try {
      final response = await _dio.post(
        '/clients/leads/$leadId/convert-to-client/',
        options: _authOptions(token),
      );
      return CrmLead.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── CLIENTS ──────────────────────────────────────────────────────

  Future<({List<CrmClient> items, int total})> getClients(
    String token, {
    String? search,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/clients/clients/',
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
            .map((j) => CrmClient.fromJson(j))
            .toList();
        return (items: items, total: (data['count'] ?? items.length) as int);
      }
      final items =
          (data as List).map((j) => CrmClient.fromJson(j)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CrmClient> createClient(
      String token, Map<String, dynamic> data) async {
    try {
      log("CrmService: Creating client...");
      final response = await _dio.post(
        '/clients/clients/',
        data: data,
        options: _authOptions(token),
      );
      return CrmClient.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<CrmClient> updateClient(
      String token, int clientId, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/clients/clients/$clientId/',
        data: data,
        options: _authOptions(token),
      );
      return CrmClient.fromJson(response.data);
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
          if (data.containsKey('detail')) {
            msg = data['detail'];
          } else if (data.containsKey('message')) msg = data['message'];
        }
      } else {
        msg = "Connection error. Please check your internet.";
      }
    }
    return Exception(msg);
  }
}
