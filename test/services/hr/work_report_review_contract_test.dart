import 'dart:io';

import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/hr/work_report_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late WorkReportService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = WorkReportService(dioOverride: dio);
  });

  test('approve uses the dedicated work-report approve action', () async {
    const payload = {'rating': 4, 'feedback': 'Good detail'};
    adapter.onPost(
      '/work-reports/report-1/approve',
      (server) => server.reply(200, {
        'id': 'report-1',
        'employee_id': 8,
        'hours_worked': 8,
        'status': 'approved',
        'feedback': 'Good detail',
        'rating': 4,
      }),
      data: payload,
    );

    final result = await service.approveWorkReport(
      'token',
      'report-1',
      rating: 4,
      feedback: 'Good detail',
    );

    expect(result.status, 'approved');
    expect(result.rating, 4);
  });

  test('reject requires feedback and uses the dedicated reject action', () async {
    adapter.onPost(
      '/work-reports/report-1/reject',
      (server) => server.reply(200, {
        'id': 'report-1',
        'employee_id': 8,
        'hours_worked': 8,
        'status': 'rejected',
        'feedback': 'Please add the next-day plan',
      }),
      data: {'feedback': 'Please add the next-day plan'},
    );

    final result = await service.rejectWorkReport(
      'token',
      'report-1',
      feedback: 'Please add the next-day plan',
    );

    expect(result.status, 'rejected');
    expect(result.feedback, 'Please add the next-day plan');
  });

  test('review dialog does not emulate review with a general update', () {
    final source = File('lib/pages/hr/widget/work_report_review_dialog.dart').readAsStringSync();
    expect(source, contains('approveReport'));
    expect(source, contains('rejectReport'));
    expect(source, isNot(contains('updateReport')));
    expect(source, isNot(contains('? 5')));
  });

  test('work-report responses retain reviewer metadata', () {
    final source = File('lib/pages/hr/models/work_report_model.dart').readAsStringSync();
    expect(source, contains('reviewedBy'));
    expect(source, contains("json['reviewed_by']"));
  });
}
