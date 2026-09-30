import 'package:bomach_os/pages/operations/models/survey_site_report_model.dart';
import 'package:bomach_os/pages/finance/models/expense_model.dart';
import 'package:bomach_os/src/services/operations/survey_site_report_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http_mock_adapter/http_mock_adapter.dart';

void main() {
  late Dio dio;
  late DioAdapter adapter;
  late SurveySiteReportService service;

  setUp(() {
    dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    adapter = DioAdapter(dio: dio);
    service = SurveySiteReportService(dioOverride: dio);
  });

  test('list sends documented filters and parses pagination', () async {
    adapter.onGet(
        '/api/v1/survey-site-reports',
        (s) => s.reply(200, {
              'items': [
                {
                  'id': 9,
                  'report_type': 'survey_site',
                  'employee_id': 4,
                  'employee_name': 'Ada Example',
                  'status': 'submitted',
                  'worksite_id': 12,
                  'date': '2026-09-28',
                  'work_data_type': 'bearing_distance'
                }
              ],
              'count': 1,
              'limit': 20,
              'offset': 0,
            }),
        queryParameters: {
          'status': 'submitted',
          'employee_id': 4,
          'worksite_id': 12,
          'project_id': 6,
          'work_data_type': 'bearing_distance',
          'date_from': '2026-09-01',
          'date_to': '2026-09-30',
          'limit': 20,
          'offset': 0,
        });
    final result = await service.listReports(
        token: 'token',
        status: 'submitted',
        employeeId: 4,
        worksiteId: 12,
        projectId: 6,
        workDataType: 'bearing_distance',
        dateFrom: '2026-09-01',
        dateTo: '2026-09-30');
    expect(result.count, 1);
    expect(result.items.single.employeeName, 'Ada Example');
    expect(result.items.single.workDataType, 'bearing_distance');
  });

  test(
      'create serializes selected format, decimals, inventory and URL attachments',
      () async {
    const report = SurveySiteReport(
        id: 0,
        reportType: 'survey_site',
        employeeId: 0,
        employeeName: '',
        status: 'draft',
        worksiteId: 12,
        worksiteName: 'Site A',
        date: '2026-09-28',
        workDataType: 'bearing_distance',
        measurementUnit: 'metres',
        coordinateSystem: 'UTM',
        datum: 'WGS84',
        coordinateZone: '32N',
        activities: [SurveyActivity(description: 'Recorded boundary points')],
        expenses: [
          SurveyExpenseLine(
              category: 'labour',
              name: 'Assistant',
              amount: '25000.50',
              description: 'Site support')
        ],
        materialsUsed: [
          SurveyMaterialUsed(
              equipmentId: 19, quantityUsed: '4.00', name: 'Peg', unit: 'pcs')
        ],
        attachments: [
          SurveyAttachment(
              url: 'https://files.example.test/a.jpg',
              description: 'North boundary')
        ],
        bearingDistancePoints: [
          BearingDistancePoint(
              pointNumber: 1,
              azimuthDegrees: 45,
              azimuthMinutes: 30,
              azimuthSeconds: '15.50',
              distance: '125.40')
        ],
        xyzPoints: [],
        submissionVersion: 0,
        createdAt: '',
        updatedAt: '');
    adapter.onPost(
        '/api/v1/survey-site-reports',
        (s) => s.reply(201, {
              'id': 9,
              'employee_id': 4,
              'status': 'draft',
              'report_type': 'survey_site',
              'payload': report.toJson()
            }),
        data: report.toJson());
    await service.createReport(token: 'token', report: report);
    final body = report.toJson();
    expect(body['work_data_type'], 'bearing_distance');
    expect(body['bearing_distance_points'], [
      {
        'point_number': 1,
        'azimuth_degrees': 45,
        'azimuth_minutes': 30,
        'azimuth_seconds': '15.50',
        'distance': '125.40'
      }
    ]);
    expect(body['xyz_points'], isEmpty);
    expect(body['expenses'].single['amount'], '25000.50');
    expect(body['materials_used'], [
      {'equipment_id': 19, 'quantity_used': '4.00'}
    ]);
    expect(body['attachments'], [
      {
        'url': 'https://files.example.test/a.jpg',
        'description': 'North boundary'
      }
    ]);
  });

  test('update omits immutable work_data_type and replaces all supplied arrays',
      () async {
    const report = SurveySiteReport(
        id: 9,
        reportType: 'survey_site',
        employeeId: 4,
        employeeName: '',
        status: 'draft',
        worksiteId: 12,
        worksiteName: '',
        date: '2026-09-29',
        workDataType: 'site_points_xyz',
        measurementUnit: 'feet',
        coordinateSystem: '',
        datum: '',
        coordinateZone: '',
        activities: [SurveyActivity(description: 'Updated')],
        expenses: [],
        materialsUsed: [],
        attachments: [],
        bearingDistancePoints: [],
        xyzPoints: [
          XyzSurveyPoint(
              pointNumber: 1, northing: '2.1', easting: '3.2', elevation: '4.3')
        ],
        submissionVersion: 1,
        createdAt: '',
        updatedAt: '');
    adapter.onPut(
        '/api/v1/survey-site-reports/9',
        (s) => s.reply(200, {
              'id': 9,
              'employee_id': 4,
              'status': 'draft',
              'payload': report.toJson(includeWorkDataType: false)
            }),
        data: report.toJson(includeWorkDataType: false));
    await service.updateReport(token: 'token', reportId: 9, report: report);
    final body = report.toJson(includeWorkDataType: false);
    expect(body, isNot(contains('work_data_type')));
    expect(body['bearing_distance_points'], isEmpty);
    expect(body['xyz_points'], hasLength(1));
  });

  test('unified feed is filtered to survey_site', () async {
    adapter.onGet(
        '/api/v1/reports/',
        (s) => s.reply(200, {
              'items': [
                {
                  'id': 9,
                  'report_type': 'survey_site',
                  'status': 'approved',
                  'employee_id': 4,
                  'employee_name': 'Ada'
                }
              ],
              'count': 1
            }),
        queryParameters: {
          'report_type': 'survey_site',
          'limit': 10,
          'offset': 0
        });
    final page = await service.listUnifiedReports(token: 'token', limit: 10);
    expect(page.items.single.reportType, 'survey_site');
    expect(page.items.single.employeeName, 'Ada');
  });

  test('lifecycle uses the documented submit, review and delete actions',
      () async {
    const base = {'id': 9, 'employee_id': 4, 'report_type': 'survey_site'};
    adapter.onPost('/api/v1/survey-site-reports/9/submit',
        (s) => s.reply(200, {...base, 'status': 'submitted'}),
        data: null);
    adapter.onPost('/api/v1/survey-site-reports/9/approve',
        (s) => s.reply(200, {...base, 'status': 'approved'}),
        data: {'rating': 5});
    adapter.onPost('/api/v1/survey-site-reports/9/reject',
        (s) => s.reply(200, {...base, 'status': 'rejected'}),
        data: {'feedback': 'Check point 3.'});
    adapter.onDelete(
        '/api/v1/survey-site-reports/9', (s) => s.reply(204, null));

    expect((await service.submitReport(token: 'token', reportId: 9)).status,
        'submitted');
    expect(
        (await service.approveReport(token: 'token', reportId: 9, rating: 5))
            .status,
        'approved');
    expect(
        (await service.rejectReport(
                token: 'token', reportId: 9, feedback: 'Check point 3.'))
            .status,
        'rejected');
    await service.deleteReport(token: 'token', reportId: 9);
  });

  test(
      'validates point ranges, sequential numbering, activities and paired GPS',
      () {
    expect(
        hasValidSurveyActivities(
            const [SurveyActivity(description: 'Boundary survey')]),
        isTrue);
    expect(hasValidSurveyActivities(const [SurveyActivity(description: ' ')]),
        isFalse);
    expect(
        hasValidBearingDistancePoints(const [
          BearingDistancePoint(
              pointNumber: 1,
              azimuthDegrees: 359,
              azimuthMinutes: 59,
              azimuthSeconds: '59.99',
              distance: '0.01')
        ]),
        isTrue);
    expect(
        hasValidBearingDistancePoints(const [
          BearingDistancePoint(
              pointNumber: 2,
              azimuthDegrees: 360,
              azimuthMinutes: 0,
              azimuthSeconds: '0',
              distance: '1')
        ]),
        isFalse);
    expect(
        hasValidXyzPoints(const [
          XyzSurveyPoint(
              pointNumber: 1, northing: '1.2', easting: '2.3', elevation: '3.4')
        ]),
        isTrue);
    expect(
        hasValidXyzPoints(const [
          XyzSurveyPoint(
              pointNumber: 2, northing: '1.2', easting: 'x', elevation: '3.4')
        ]),
        isFalse);
    expect(hasPairedGpsCoordinates('6.52', '3.37'), isTrue);
    expect(hasPairedGpsCoordinates('6.52', null), isFalse);
    expect(isValidSurveyAttachmentUrl('https://files.example.test/site.jpg'),
        isTrue);
    expect(isValidSurveyAttachmentUrl('/local/site.jpg'), isFalse);
  });

  test('Finance expense model retains survey audit linkage', () {
    final expense = Expense.fromJson({
      'id': 21,
      'survey_expense_line_id': '6',
      'survey_report_version': 2,
    });
    expect(expense.surveyExpenseLineId, 6);
    expect(expense.surveyReportVersion, 2);
  });
}
