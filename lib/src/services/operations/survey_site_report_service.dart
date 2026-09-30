import 'package:bomach_os/pages/operations/models/survey_site_report_model.dart';
import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:dio/dio.dart';

class SurveySiteReportService {
  SurveySiteReportService({Dio? dioOverride})
      : _dio = dioOverride ??
            Dio(BaseOptions(
                baseUrl: ApiConstants.baseUrl,
                connectTimeout: const Duration(seconds: 15),
                receiveTimeout: const Duration(seconds: 15),
                headers: const {
                  'Content-Type': 'application/json',
                  'Accept': 'application/json'
                }));
  final Dio _dio;
  static const _path = '/api/v1/survey-site-reports';
  Options _auth(String token) =>
      Options(headers: {'Authorization': 'Bearer $token'});

  Future<({List<SurveySiteReport> items, int count})> listReports(
      {required String token,
      String? status,
      int? employeeId,
      int? worksiteId,
      int? projectId,
      String? workDataType,
      String? dateFrom,
      String? dateTo,
      int limit = 20,
      int offset = 0}) async {
    final response = await _dio.get(_path,
        queryParameters: {
          if (status != null && status != 'all') 'status': status,
          if (employeeId != null) 'employee_id': employeeId,
          if (worksiteId != null) 'worksite_id': worksiteId,
          if (projectId != null) 'project_id': projectId,
          if (workDataType != null && workDataType != 'all')
            'work_data_type': workDataType,
          if (dateFrom != null && dateFrom.isNotEmpty) 'date_from': dateFrom,
          if (dateTo != null && dateTo.isNotEmpty) 'date_to': dateTo,
          'limit': limit,
          'offset': offset
        },
        options: _auth(token));
    return _page(response.data, SurveySiteReport.fromJson);
  }

  Future<SurveySiteReport> getReport(
          {required String token, required int reportId}) async =>
      SurveySiteReport.fromJson(_map(
          (await _dio.get('$_path/$reportId', options: _auth(token))).data));

  Future<SurveySiteReport> createReport(
          {required String token, required SurveySiteReport report}) async =>
      SurveySiteReport.fromJson(_map(
          (await _dio.post(_path, data: report.toJson(), options: _auth(token)))
              .data));

  Future<SurveySiteReport> updateReport(
          {required String token,
          required int reportId,
          required SurveySiteReport report}) async =>
      SurveySiteReport.fromJson(_map((await _dio.put('$_path/$reportId',
              data: report.toJson(includeWorkDataType: false),
              options: _auth(token)))
          .data));

  Future<void> deleteReport(
          {required String token, required int reportId}) async =>
      _dio.delete('$_path/$reportId', options: _auth(token));

  Future<SurveySiteReport> submitReport(
          {required String token, required int reportId}) async =>
      SurveySiteReport.fromJson(_map(
          (await _dio.post('$_path/$reportId/submit', options: _auth(token)))
              .data));

  Future<SurveySiteReport> approveReport(
          {required String token,
          required int reportId,
          int? rating,
          String? feedback}) async =>
      SurveySiteReport.fromJson(
          _map((await _dio.post('$_path/$reportId/approve',
                  data: {
                    if (rating != null) 'rating': rating,
                    if (feedback != null && feedback.trim().isNotEmpty)
                      'feedback': feedback.trim()
                  },
                  options: _auth(token)))
              .data));

  Future<SurveySiteReport> rejectReport(
          {required String token,
          required int reportId,
          required String feedback}) async =>
      SurveySiteReport.fromJson(_map((await _dio.post('$_path/$reportId/reject',
              data: {'feedback': feedback.trim()}, options: _auth(token)))
          .data));

  Future<({List<SurveyUnifiedReport> items, int count})> listUnifiedReports(
      {required String token, int limit = 100, int offset = 0}) async {
    final response = await _dio.get('/api/v1/reports/',
        queryParameters: {
          'report_type': 'survey_site',
          'limit': limit,
          'offset': offset
        },
        options: _auth(token));
    return _page(response.data, SurveyUnifiedReport.fromJson);
  }

  Future<SurveySiteReport> getUnifiedReport(
          {required String token, required int reportId}) async =>
      SurveySiteReport.fromJson(_map(
          (await _dio.get('/api/v1/reports/$reportId', options: _auth(token)))
              .data));

  static Map<String, dynamic> _map(dynamic value) {
    if (value is Map && value['data'] is Map)
      return Map<String, dynamic>.from(value['data']);
    if (value is Map && value['item'] is Map)
      return Map<String, dynamic>.from(value['item']);
    return value is Map
        ? Map<String, dynamic>.from(value)
        : <String, dynamic>{};
  }

  static ({List<T> items, int count}) _page<T>(
      dynamic data, T Function(Map<String, dynamic>) parse) {
    if (data is Map && data['items'] is List) {
      final items = (data['items'] as List)
          .whereType<Map>()
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList();
      return (
        items: items,
        count: (data['count'] as num?)?.toInt() ?? items.length
      );
    }
    if (data is List) {
      final items = data
          .whereType<Map>()
          .map((e) => parse(Map<String, dynamic>.from(e)))
          .toList();
      return (items: items, count: items.length);
    }
    return (items: <T>[], count: 0);
  }
}
