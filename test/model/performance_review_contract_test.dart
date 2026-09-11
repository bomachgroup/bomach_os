import 'dart:io';

import 'package:bomach_os/pages/hr/models/performance_review.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final review = PerformanceReview(
    id: '9',
    employeeId: '8',
    reviewerId: '2',
    reviewDate: DateTime(2026, 9, 11),
    reviewPeriod: 'Q3 2026',
    overallRating: 4,
    strengths: 'Reliable',
    areasForImprovement: 'Delegation',
    feedback: 'Keep it up',
    employeeComments: 'Noted',
  );

  test('create payload uses the published singular employee_comment field', () {
    final payload = review.toCreateJson();
    expect(payload['employee_id'], 8);
    expect(payload['reviewer_id'], 2);
    expect(payload['review_date'], '2026-09-11');
    expect(payload['employee_comment'], 'Noted');
    expect(payload, isNot(contains('employee_comments')));
  });

  test('update payload excludes create-only employee and reviewer identity', () {
    final payload = review.toUpdateJson();
    expect(payload, isNot(contains('employee_id')));
    expect(payload, isNot(contains('reviewer_id')));
    expect(payload['employee_comment'], 'Noted');
  });

  test('employee appraisal submits quarter and year instead of unsupported rating fields', () {
    final source = File('lib/pages/hr/widget/add_employee_appraisal.dart').readAsStringSync();
    expect(source, contains("'quarter'"));
    expect(source, contains("'year'"));
    expect(source, isNot(contains("'review_period'")));
    expect(source, isNot(contains("'overall_rating'")));
    expect(source, isNot(contains("'rating'")));
  });

  test('performance review form requires contract fields and uses a date picker', () {
    final source =
        File('lib/pages/hr/widget/add_performance_review_dialog.dart')
            .readAsStringSync();
    expect(source, contains('Review date is required'));
    expect(source, contains('Review period is required'));
    expect(source, contains('Overall rating is required'));
    expect(source, contains('showDatePicker'));
  });
}
