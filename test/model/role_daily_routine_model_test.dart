import 'package:bomach_os/src/model/role_daily_routine_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('maps the API routine item without fabricating employee reports', () {
    final item = RoleDailyRoutineItem.fromJson({
      'id': 2,
      'role_id': 12,
      'title': 'Run the morning review',
      'description': 'Review priorities.',
      'sequence': 2,
      'time_of_day': '09:00:00',
      'estimated_minutes': 30,
      'is_active': true,
      'created_at': '2026-09-04T08:00:00Z',
      'updated_at': '2026-09-04T08:00:00Z',
    });

    expect(item.id, 2);
    expect(item.roleId, 12);
    expect(item.title, 'Run the morning review');
    expect(item.timeOfDay, '09:00:00');
    expect(item.estimatedMinutes, 30);
    expect(item.isActive, isTrue);
  });
}
