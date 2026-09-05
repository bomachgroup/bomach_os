import 'package:bomach_os/src/constants/api_constants.dart';
import 'package:bomach_os/src/services/target_report_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late TargetReportService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: ApiConstants.baseUrl));
    adapter = DioAdapter(dio: dio);
    service = TargetReportService(dioOverride: dio);
  });

  test('lists my target reports with supported filters', () async {
    adapter.onGet(
      '/api/v1/target-reports/me',
      (server) => server.reply(200, {
        'items': [
          {
            'id': 9,
            'employee_target_id': 4,
            'employee_target': {
              'id': 4,
              'title': 'Close qualified leads',
              'target_value': 20,
              'unit': 'leads',
              'period': 'monthly',
              'period_start': '2026-09-01',
              'period_end': '2026-09-30',
            },
            'employee': {
              'id': 7,
              'user_id': 8,
              'employee_id': 'EMP-007',
            },
            'summary': 'Closed 12 qualified leads.',
            'progress_value': 12,
            'status': 'submitted',
            'reviewed_by_id': null,
            'reviewed_by': null,
            'reviewed_at': null,
            'rejection_reason': '',
            'created_at': '2026-09-04T10:00:00Z',
            'updated_at': '2026-09-04T10:00:00Z',
          },
        ],
        'count': 1,
      }),
      queryParameters: {'status': 'submitted', 'limit': 20, 'offset': 5},
    );

    final result = await service.listMine(
      'token',
      status: 'submitted',
      limit: 20,
      offset: 5,
    );

    expect(result.count, 1);
    expect(result.list.single.targetTitle, 'Close qualified leads');
    expect(result.list.single.progressValue, 12);
  });

  test('creates and rejects using the exact published request bodies',
      () async {
    adapter.onPost(
      '/api/v1/target-reports/',
      (server) => server.reply(201, _reportJson(10)),
      data: {
        'employee_target_id': 4,
        'summary': 'Closed 15 qualified leads.',
        'progress_value': 15,
      },
    );
    adapter.onPost(
      '/api/v1/target-reports/10/reject',
      (server) => server.reply(200, _reportJson(10)),
      data: {'rejection_reason': 'Include the supporting evidence.'},
    );

    final created = await service.create(
      'token',
      employeeTargetId: 4,
      summary: 'Closed 15 qualified leads.',
      progressValue: 15,
    );
    final rejected = await service.reject(
      'token',
      10,
      'Include the supporting evidence.',
    );

    expect(created.id, 10);
    expect(rejected.status, 'rejected');
  });
}

Map<String, dynamic> _reportJson(int id) => {
      'id': id,
      'employee_target_id': 4,
      'employee_target': {
        'id': 4,
        'title': 'Close qualified leads',
        'target_value': 20,
        'unit': 'leads',
        'period': 'monthly',
        'period_start': '2026-09-01',
        'period_end': '2026-09-30',
      },
      'employee': {'id': 7, 'user_id': 8, 'employee_id': 'EMP-007'},
      'summary': 'Closed leads.',
      'progress_value': 15,
      'status': id == 10 ? 'rejected' : 'submitted',
      'reviewed_by_id': null,
      'reviewed_by': null,
      'reviewed_at': null,
      'rejection_reason': id == 10 ? 'Include the supporting evidence.' : '',
      'created_at': '2026-09-04T10:00:00Z',
      'updated_at': '2026-09-04T10:00:00Z',
    };
