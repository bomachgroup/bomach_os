import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  late Map<String, dynamic> contract;
  late Map<String, dynamic> paths;
  late Map<String, dynamic> schemas;

  setUpAll(() {
    contract = jsonDecode(File('openapi_schema.json').readAsStringSync())
        as Map<String, dynamic>;
    paths = contract['paths'] as Map<String, dynamic>;
    schemas = (contract['components'] as Map<String, dynamic>)['schemas']
        as Map<String, dynamic>;
  });

  test('supported employee workflow APIs remain in the checked-in contract',
      () {
    for (final path in [
      '/api/v1/my-tasks',
      '/api/v1/my-tasks/{task_id}/status',
      '/api/v1/work-reports/',
      '/api/v1/work-reports/{report_id}',
      '/api/v1/worksites',
      '/api/v1/tasks',
      '/api/v1/leave-requests/',
      '/api/v1/monthly-scorecards/employee/{employee_id}',
    ]) {
      expect(paths, contains(path), reason: 'Expected supported path $path');
    }
  });

  test('work reports do not claim task, project, or work-site associations',
      () {
    final report = schemas['WorkReportOut'] as Map<String, dynamic>;
    final properties = report['properties'] as Map<String, dynamic>;

    for (final field in ['task_id', 'project_id', 'worksite_id']) {
      expect(properties, isNot(contains(field)), reason: 'Unexpected $field');
    }
  });

  test('work-site creation currently requires a project association', () {
    final worksite = schemas['WorksiteCreateSchema'] as Map<String, dynamic>;
    expect(worksite['required'], contains('project_id'));
  });

  test('scorecard contract fields are not mistaken for meeting criteria', () {
    final scorecard =
        schemas['ScorecardResponseSchema'] as Map<String, dynamic>;
    final properties = scorecard['properties'] as Map<String, dynamic>;

    expect(
        properties.keys,
        containsAll([
          'attendance_score',
          'task_delivery_score',
          'report_accuracy_score',
          'brand_contribution_score',
          'training_progress_score',
        ]));
    expect(properties.keys, isNot(contains('colleague_rating')));
    expect(properties.keys, isNot(contains('clocking_quality_score')));
  });

  test('meeting follow-up capability record documents verified gaps', () {
    final document = File(
      'docs/meeting-followups/2026-09-21-in-house-work-performance.md',
    ).readAsStringSync();

    expect(document, contains('backend dependency'));
    expect(document, contains('project_id'));
    expect(document, contains('scoring criteria'));
    expect(document, contains('No data deletion'));
  });
}
