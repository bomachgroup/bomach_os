import 'package:bomach_os/src/model/target_report_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps nested target and employee details from the API', () {
    final report = TargetReport.fromJson({
      'id': 9,
      'employee_target_id': 4,
      'employee_target': {
        'id': 4,
        'title': 'Close qualified leads',
        'target_value': '20',
        'unit': 'leads',
        'period': 'monthly',
        'period_start': '2026-09-01',
        'period_end': '2026-09-30',
      },
      'employee': {'id': 7, 'user_id': 8, 'employee_id': 'EMP-007'},
      'summary': 'Closed 12 qualified leads.',
      'progress_value': '12',
      'status': 'submitted',
      'rejection_reason': '',
      'created_at': '2026-09-04T10:00:00Z',
      'updated_at': '2026-09-04T10:00:00Z',
    });

    expect(report.id, 9);
    expect(report.employeeTargetId, 4);
    expect(report.targetTitle, 'Close qualified leads');
    expect(report.progressValue, 12);
    expect(report.employeeCode, 'EMP-007');
    expect(report.status, 'submitted');
  });
}
