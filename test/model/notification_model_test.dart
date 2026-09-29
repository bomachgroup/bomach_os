import 'package:bomach_os/src/model/broadcast_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('notification parser preserves unread state and structured context', () {
    final notification = NotificationItem.fromJson({
      'id': 91,
      'title': 'Work location extension requested',
      'message': 'Ada requested an extension for Enugu office.',
      'notification_type': 'work_location',
      'event_type': 'work_location_extension_requested',
      'priority': 'high',
      'is_read': false,
      'link': '/work-locations/18',
      'action': 'review',
      'entity_type': 'work_location',
      'entity_id': '18',
      'metadata': {'location_id': 18, 'requested_expires_at': '2026-12-31'},
      'created_at': '2026-09-29T09:00:00Z',
    });

    expect(notification.id, 91);
    expect(notification.category, 'Work locations');
    expect(notification.isRead, isFalse);
    expect(notification.metadata['location_id'], 18);
    expect(notification.action, 'review');
    expect(notification.copyWith(isRead: true).isRead, isTrue);
  });
}
