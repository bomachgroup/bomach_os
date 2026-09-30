import 'package:bomach_os/pages/operations/models/engineering_site_report_model.dart';
import 'package:bomach_os/pages/operations/models/models.dart';
import 'package:bomach_os/src/services/operations/engineering_site_report_service.dart';
import 'package:bomach_os/src/services/operations/site_equipment_services.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late EngineeringSiteReportService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    adapter = DioAdapter(dio: dio);
    service = EngineeringSiteReportService(dioOverride: dio);
  });

  test('list uses documented filters and pagination', () async {
    adapter.onGet(
      '/api/v1/engineering-site-reports/',
      (server) => server.reply(200, {
        'items': [
          {
            'id': 101,
            'employee_id': 8,
            'employee_name': 'A. Builder',
            'status': 'submitted',
            'payload': {'worksite_id': 12, 'date': '2026-09-25'},
          }
        ],
        'count': 1,
        'limit': 10,
        'offset': 20,
      }),
      queryParameters: {
        'status': 'submitted',
        'employee_id': 8,
        'worksite_id': 12,
        'project_id': 4,
        'date_from': '2026-09-01',
        'date_to': '2026-09-30',
        'limit': 10,
        'offset': 20,
      },
    );

    final result = await service.listReports(
      accessToken: 'token',
      status: 'submitted',
      employeeId: 8,
      worksiteId: 12,
      projectId: 4,
      dateFrom: '2026-09-01',
      dateTo: '2026-09-30',
      limit: 10,
      offset: 20,
    );

    expect(result.count, 1);
    expect(result.items.single.worksiteId, 12);
    expect(result.items.single.employeeName, 'A. Builder');
  });

  test('report JSON keeps material payload to equipment ID and quantity', () {
    const report = EngineeringSiteReport(
      id: 0,
      employeeId: 0,
      employeeName: '',
      status: 'draft',
      worksiteId: 12,
      worksiteName: '',
      projectId: 4,
      taskId: null,
      date: '2026-09-25',
      tomorrowActivities: '',
      commentsSuggestions: '',
      submissionVersion: 0,
      activities: [
        EngineeringReportActivity(
          activityType: 'concrete_work',
          description: 'Poured footing.',
        ),
      ],
      expenses: [],
      materialsUsed: [
        EngineeringReportMaterial(
          equipmentId: 31,
          quantityUsed: '2.500',
          name: 'Cement',
          unit: 'bags',
        ),
      ],
      attachments: ['https://example.test/photo.jpg'],
      createdAt: '',
      updatedAt: '',
    );

    final json = report.toJson();
    expect(json['activities'], [
      {'activity_type': 'concrete_work', 'description': 'Poured footing.'}
    ]);
    expect(json['materials_used'], [
      {'equipment_id': 31, 'quantity_used': '2.500'}
    ]);
    expect(json['attachments'], ['https://example.test/photo.jpg']);
    expect((json['materials_used'] as List).single, isNot(contains('name')));
    expect((json['materials_used'] as List).single, isNot(contains('unit')));
    expect(json, isNot(contains('employee_id')));
  });

  test('attachment validation accepts URLs only and requires an activity', () {
    expect(isValidEngineeringAttachmentUrl('https://example.test/site.jpg'),
        isTrue);
    expect(isValidEngineeringAttachmentUrl('http://example.test/site.jpg'),
        isTrue);
    expect(isValidEngineeringAttachmentUrl('/tmp/site.jpg'), isFalse);
    expect(isValidEngineeringAttachmentUrl('javascript:alert(1)'), isFalse);
    expect(
      hasValidEngineeringActivity(const [
        EngineeringReportActivity(
            activityType: 'concrete_work', description: 'Foundation poured'),
      ]),
      isTrue,
    );
    expect(
      hasValidEngineeringActivity(const [
        EngineeringReportActivity(
            activityType: 'concrete_work', description: ' '),
      ]),
      isFalse,
    );
  });

  test('submit sends an empty body to the report submit action', () async {
    adapter.onPost(
      '/api/v1/engineering-site-reports/101/submit',
      (server) => server.reply(200, {
        'id': 101,
        'employee_id': 8,
        'employee_name': 'A. Builder',
        'status': 'submitted',
        'payload': {'worksite_id': 12, 'submission_version': 1},
      }),
      data: <String, dynamic>{},
    );

    final report =
        await service.submitReport(accessToken: 'token', reportId: 101);
    expect(report.status, 'submitted');
    expect(report.submissionVersion, 1);
  });

  test('site inventory update JSON never sends quantity', () {
    final item = SiteEquipment(
      id: 31,
      worksiteId: 12,
      name: 'Cement',
      unit: 'bags',
      quantity: '25.000',
      createdAt: '',
      updatedAt: '',
    );

    expect(item.toJson()['quantity'], '25.000');
    expect(item.toUpdateJson(), {
      'worksite_id': 12,
      'name': 'Cement',
      'unit': 'bags',
    });
  });

  test('report mutations use their documented HTTP actions and bodies',
      () async {
    final reportBody = {
      'worksite_id': 12,
      'date': '2026-09-25',
      'tomorrow_activities': '',
      'comments_suggestions': '',
      'activities': [
        {'activity_type': 'water_supply', 'description': 'Set up a water line.'}
      ],
      'expenses': [],
      'materials_used': [],
      'attachments': [],
    };
    final response = {
      'id': 101,
      'employee_id': 8,
      'employee_name': 'A. Builder',
      'status': 'draft',
      'payload': {'worksite_id': 12, 'date': '2026-09-25'},
    };

    adapter.onPost('/api/v1/engineering-site-reports/',
        (server) => server.reply(201, response),
        data: reportBody);
    adapter.onPut('/api/v1/engineering-site-reports/101',
        (server) => server.reply(200, response),
        data: reportBody);
    adapter.onPost('/api/v1/engineering-site-reports/101/approve',
        (server) => server.reply(200, {...response, 'status': 'approved'}),
        data: {'rating': 5});
    adapter.onPost('/api/v1/engineering-site-reports/101/reject',
        (server) => server.reply(200, {...response, 'status': 'rejected'}),
        data: {'feedback': 'Correct the quantities.'});
    adapter.onDelete('/api/v1/engineering-site-reports/101',
        (server) => server.reply(204, null));

    const report = EngineeringSiteReport(
      id: 0,
      employeeId: 0,
      employeeName: '',
      status: 'draft',
      worksiteId: 12,
      worksiteName: '',
      date: '2026-09-25',
      tomorrowActivities: '',
      commentsSuggestions: '',
      submissionVersion: 0,
      activities: [
        EngineeringReportActivity(
            activityType: 'water_supply', description: 'Set up a water line.')
      ],
      expenses: [],
      materialsUsed: [],
      attachments: [],
      createdAt: '',
      updatedAt: '',
    );
    await service.createReport(accessToken: 'token', report: report);
    await service.updateReport(
        accessToken: 'token', reportId: 101, report: report);
    await service.approveReport(accessToken: 'token', reportId: 101, rating: 5);
    await service.rejectReport(
        accessToken: 'token',
        reportId: 101,
        feedback: 'Correct the quantities.');
    await service.deleteReport(accessToken: 'token', reportId: 101);
  });

  test('inventory adjustment uses the adjustment endpoint and signed delta',
      () async {
    adapter.onPost(
      '/api/v1/site-equipment/31/adjust',
      (server) => server.reply(200, {
        'id': 31,
        'worksite_id': 12,
        'name': 'Cement',
        'unit': 'bags',
        'quantity': '23.000',
      }),
      data: {'quantity_delta': '-2.000', 'reason': 'Damaged bags removed.'},
    );
    final item = await SiteEquipmentService(
            baseUrl: 'https://example.test', dioOverride: dio)
        .adjustSiteEquipment(
            accessToken: 'token',
            equipmentId: 31,
            quantityDelta: '-2.000',
            reason: 'Damaged bags removed.');
    expect(item.quantity, '23.000');
  });

  test('inventory create, get, update, and delete use documented endpoints',
      () async {
    final inventory =
        SiteEquipmentService(baseUrl: 'https://example.test', dioOverride: dio);
    const row = {
      'id': 31,
      'worksite_id': 12,
      'name': 'Cement',
      'unit': 'bags',
      'quantity': '25.000',
    };
    adapter.onPost('/api/v1/site-equipment', (server) => server.reply(201, row),
        data: {
          'worksite_id': 12,
          'name': 'Cement',
          'unit': 'bags',
          'quantity': '25.000',
        });
    adapter.onGet(
        '/api/v1/site-equipment/31', (server) => server.reply(200, row));
    adapter.onPut(
        '/api/v1/site-equipment/31', (server) => server.reply(200, row),
        data: {
          'worksite_id': 12,
          'name': 'Cement',
          'unit': 'bags',
        });
    adapter.onDelete(
        '/api/v1/site-equipment/31', (server) => server.reply(204, null));

    final item = SiteEquipment(
      id: 31,
      worksiteId: 12,
      name: 'Cement',
      unit: 'bags',
      quantity: '25.000',
      createdAt: '',
      updatedAt: '',
    );
    await inventory.createSiteEquipment(accessToken: 'token', equipment: item);
    expect(
      (await inventory.getSiteEquipmentById(
              accessToken: 'token', equipmentId: 31))
          .quantity,
      '25.000',
    );
    await inventory.updateSiteEquipment(
        accessToken: 'token', equipmentId: 31, equipment: item);
    await inventory.deleteSiteEquipment(accessToken: 'token', equipmentId: 31);
  });
}
