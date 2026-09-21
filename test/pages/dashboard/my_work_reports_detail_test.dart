import 'package:bomach_os/pages/hr/controller/work_report_controller.dart';
import 'package:bomach_os/pages/hr/models/work_report_model.dart';
import 'package:bomach_os/src/services/hr/work_report_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

class _DetailLoadingWorkReportService extends WorkReportService {
  _DetailLoadingWorkReportService(this.detail) : super(dioOverride: Dio());

  final WorkReport detail;
  String? requestedId;

  @override
  Future<WorkReport> getWorkReportById(String token, String reportId) async {
    requestedId = reportId;
    return detail;
  }
}

void main() {
  test('loads the full report before viewing a summary list item', () async {
    final listedReport = WorkReport(
      id: 'report-42',
      employeeId: 7,
      hoursWorked: 8,
      status: 'draft',
    );
    final detailedReport = WorkReport(
      id: 'report-42',
      employeeId: 7,
      hoursWorked: 8,
      status: 'draft',
      operationalBase: 'Head Office',
      workActivities: 'Completed the onboarding checklist',
      taskDetails: 'Resolved the access blocker',
      planNextDay: 'Prepare the weekly status update',
    );
    final service = _DetailLoadingWorkReportService(detailedReport);
    final controller = WorkReportController(service: service);

    final result = await controller.getReportForViewing('token', listedReport);

    expect(service.requestedId, 'report-42');
    expect(result.workActivities, 'Completed the onboarding checklist');
    expect(result.taskDetails, 'Resolved the access blocker');
    expect(result.planNextDay, 'Prepare the weekly status update');
  });
}
