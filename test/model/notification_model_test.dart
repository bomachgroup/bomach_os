import 'package:bomach_os/src/model/broadcast_model.dart';
import 'package:bomach_os/src/utils/notification_destination.dart';
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

  test('leave submission notice uses metadata for category and review link',
      () {
    final notification = NotificationItem.fromJson({
      'id': 92,
      'title': 'Leave request for review',
      'message': 'A staff member submitted a request.',
      'notification_type': 'info',
      'event_type': '',
      'entity_type': '',
      'entity_id': '',
      'metadata': {
        'event': 'leave_request_submitted',
        'entity_type': 'leave_request',
        'entity_id': 42,
      },
    });

    expect(notification.category, 'Leave');
    expect(notification.entityType, 'leave_request');
    expect(notification.entityId, '42');
    expect(
      NotificationDestination.routeFor(notification),
      '/hr/leave-request?request_id=42',
    );
  });

  test('leave decision notice opens the employee request from metadata', () {
    final notification = NotificationItem.fromJson({
      'id': 93,
      'title': 'Leave request approved',
      'message': 'Your request was approved.',
      'notification_type': 'success',
      'metadata': {
        'event': 'leave_request_decided',
        'entity_type': 'leave_request',
        'entity_id': '43',
      },
    });

    expect(notification.category, 'Leave');
    expect(
      NotificationDestination.routeFor(notification),
      '/hr/leaves?request_id=43',
    );
  });

  test('legacy leave links remain usable without metadata', () {
    final notification = NotificationItem.fromJson({
      'id': 94,
      'title': 'Leave update',
      'message': 'A leave request was updated.',
      'link': '/leave/44',
      'notification_type': 'info',
    });

    expect(
      NotificationDestination.routeFor(notification),
      '/hr/leaves?request_id=44',
    );
  });

  test('unassigned reviewer alert does not open the recipient personal record',
      () {
    final notification = NotificationItem.fromJson({
      'id': 95,
      'title': 'Leave review coverage needs attention',
      'message': 'Assign an eligible reviewer.',
      'notification_type': 'warning',
      'link': '/admin/hr/leaverequest/45/change/',
      'metadata': {
        'event': 'leave_request_reviewer_unassigned',
        'entity_type': 'leave_request',
        'entity_id': 45,
      },
    });

    expect(NotificationDestination.routeFor(notification), isNull);
  });
}
