import 'package:bomach_os/pages/dashboad/models/dashboard_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps the API punctuality_score into the progress value', () {
    final report = PunctualityReport.fromJson({
      'total_days': 20,
      'on_time_days': 15,
      'late_days': 3,
      'absent_days': 2,
      'punctuality_score': 75,
    });

    expect(report.score, 75);
  });
}
