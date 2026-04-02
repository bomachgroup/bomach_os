import 'dart:developer';
import 'package:bms_front_end/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

class MarketingCampaign {
  final int id;
  final String name;
  final String? description;
  final String status;
  final String channel;
  final int impressions;
  final String ctr;
  final String roi;
  final String progressPercentage;
  final String budgetAllocated;
  final String budgetSpent;
  final String budgetRemaining;
  final double budgetUtilizationPercentage;
  final bool isOverBudget;
  final int clicks;
  final String? startDate;
  final String? endDate;
  final String createdAt;
  final String updatedAt;

  MarketingCampaign({
    required this.id,
    required this.name,
    this.description,
    required this.status,
    required this.channel,
    required this.impressions,
    required this.ctr,
    required this.roi,
    required this.progressPercentage,
    required this.budgetAllocated,
    required this.budgetSpent,
    required this.budgetRemaining,
    required this.budgetUtilizationPercentage,
    required this.isOverBudget,
    required this.clicks,
    this.startDate,
    this.endDate,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketingCampaign.fromJson(Map<String, dynamic> json) {
    return MarketingCampaign(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      status: json['status'] ?? '',
      channel: json['channel'] ?? '',
      impressions: json['impressions'] ?? 0,
      ctr: json['ctr']?.toString() ?? '0.00',
      roi: json['roi']?.toString() ?? '0.00',
      progressPercentage: json['progress_percentage']?.toString() ?? '0.00',
      budgetAllocated: json['budget_allocated']?.toString() ?? '0.00',
      budgetSpent: json['budget_spent']?.toString() ?? '0.00',
      budgetRemaining: json['budget_remaining']?.toString() ?? '0.00',
      budgetUtilizationPercentage: double.tryParse(
              json['budget_utilization_percentage']?.toString() ?? '0') ??
          0,
      isOverBudget: json['is_over_budget'] ?? false,
      clicks: json['clicks'] ?? 0,
      startDate: json['start_date'],
      endDate: json['end_date'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class MarketingContent {
  final int id;
  final String title;
  final String contentType;
  final String status;
  final String platform;
  final String body;
  final String excerpt;
  final int views;
  final int likes;
  final int shares;
  final int comments;
  final bool isFeatured;
  final bool isPublished;
  final String createdAt;
  final String updatedAt;

  MarketingContent({
    required this.id,
    required this.title,
    required this.contentType,
    required this.status,
    required this.platform,
    required this.body,
    required this.excerpt,
    required this.views,
    required this.likes,
    required this.shares,
    required this.comments,
    required this.isFeatured,
    required this.isPublished,
    required this.createdAt,
    required this.updatedAt,
  });

  factory MarketingContent.fromJson(Map<String, dynamic> json) {
    return MarketingContent(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      contentType: json['content_type'] ?? '',
      status: json['status'] ?? '',
      platform: json['platform'] ?? '',
      body: json['body'] ?? '',
      excerpt: json['excerpt'] ?? '',
      views: json['views'] ?? 0,
      likes: json['likes'] ?? 0,
      shares: json['shares'] ?? 0,
      comments: json['comments'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      isPublished: json['is_published'] ?? false,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class MarketingService {
  final Dio _dio;

  static const String _baseUrl = '${ApiConstants.baseUrl}/api/v1';

  MarketingService({Dio? dioOverride})
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

  Options _authOptions(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  // ─── CAMPAIGNS ────────────────────────────────────────────────────

  Future<({List<MarketingCampaign> items, int total})> getCampaigns(
    String token, {
    String? search,
    String? status,
    String? channel,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/marketing-campaigns',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          if (channel != null && channel.isNotEmpty) 'channel': channel,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );
      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((j) => MarketingCampaign.fromJson(j))
            .toList();
        return (items: items, total: (data['count'] ?? items.length) as int);
      }
      final items =
          (data as List).map((j) => MarketingCampaign.fromJson(j)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MarketingCampaign> createCampaign(
      String token, Map<String, dynamic> data) async {
    try {
      log("MarketingService: Creating campaign...");
      final response = await _dio.post(
        '/marketing-campaigns',
        data: data,
        options: _authOptions(token),
      );
      return MarketingCampaign.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MarketingCampaign> updateCampaign(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/marketing-campaigns/$id',
        data: data,
        options: _authOptions(token),
      );
      return MarketingCampaign.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteCampaign(String token, int id) async {
    try {
      await _dio.delete('/marketing-campaigns/$id',
          options: _authOptions(token));
    } catch (e) {
      throw _handleError(e);
    }
  }

  // ─── CONTENT ──────────────────────────────────────────────────────

  Future<({List<MarketingContent> items, int total})> getContent(
    String token, {
    String? search,
    String? status,
    String? contentType,
    String? platform,
    int limit = 100,
    int offset = 0,
  }) async {
    try {
      final response = await _dio.get(
        '/content',
        queryParameters: {
          if (search != null && search.isNotEmpty) 'search': search,
          if (status != null && status.isNotEmpty) 'status': status,
          if (contentType != null && contentType.isNotEmpty)
            'content_type': contentType,
          if (platform != null && platform.isNotEmpty) 'platform': platform,
          'limit': limit,
          'offset': offset,
        },
        options: _authOptions(token),
      );
      final data = response.data;
      if (data is Map && data.containsKey('items')) {
        final items = (data['items'] as List)
            .map((j) => MarketingContent.fromJson(j))
            .toList();
        return (items: items, total: (data['count'] ?? items.length) as int);
      }
      final items =
          (data as List).map((j) => MarketingContent.fromJson(j)).toList();
      return (items: items, total: items.length);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MarketingContent> createContent(
      String token, Map<String, dynamic> data) async {
    try {
      log("MarketingService: Creating content...");
      final response = await _dio.post(
        '/content',
        data: data,
        options: _authOptions(token),
      );
      return MarketingContent.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<MarketingContent> updateContent(
      String token, int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '/content/$id',
        data: data,
        options: _authOptions(token),
      );
      return MarketingContent.fromJson(response.data);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> deleteContent(String token, int id) async {
    try {
      await _dio.delete('/content/$id', options: _authOptions(token));
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
