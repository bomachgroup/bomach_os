import 'package:bomach_os/pages/hr/models/work_report_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkReport reviewer metadata', () {
    test('maps the API reviewer object to a readable name', () {
      final report = WorkReport.fromJson({
        'id': 42,
        'employee_id': 7,
        'day': '2026-09-21',
        'hours_worked': 8,
        'status': 'approved',
        'reviewed_by_id': 3,
        'reviewed_by': {
          'id': 3,
          'email': 'reviewer@example.test',
          'first_name': 'Ada',
          'last_name': 'Lovelace',
        },
      });

      expect(report.reviewedBy, 'Ada Lovelace');
    });

    test('continues to accept a legacy reviewer string', () {
      final report = WorkReport.fromJson({
        'id': 42,
        'employee_id': 7,
        'day': '2026-09-21',
        'hours_worked': 8,
        'status': 'approved',
        'reviewed_by': 'Ada Lovelace',
      });

      expect(report.reviewedBy, 'Ada Lovelace');
    });
  });
}
