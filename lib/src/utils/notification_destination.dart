import '../app_routes/app_route_constants.dart';
import '../model/broadcast_model.dart';

class NotificationDestination {
  static String? routeFor(NotificationItem item) {
    final metadata = item.metadata;
    final event =
        (metadata['event'] ?? item.eventType ?? '').toString().toLowerCase();
    final entityType =
        (item.entityType.isNotEmpty ? item.entityType : metadata['entity_type'])
            ?.toString()
            .toLowerCase();
    var requestId = int.tryParse(item.entityId);

    // Older leave notices only have a legacy `/leave/{id}` link.
    if (requestId == null) {
      final match = RegExp(r'/leave/(\d+)(?:/|$)').firstMatch(item.link);
      requestId = int.tryParse(match?.group(1) ?? '');
    }

    final isLegacyLeaveLink = RegExp(r'/leave/\d+(?:/|$)').hasMatch(item.link);
    if (event == 'leave_request_reviewer_unassigned') return null;
    final isLeaveRequest = entityType == 'leave_request' ||
        event.contains('leave_request') ||
        event.startsWith('leave_') ||
        isLegacyLeaveLink;
    if (!isLeaveRequest || requestId == null) return null;

    final isReviewAction = item.action.toLowerCase().contains('review');
    if (event != 'leave_request_submitted' &&
        event != 'leave_request_decided' &&
        !isReviewAction &&
        !isLegacyLeaveLink) {
      return null;
    }
    final destination = event == 'leave_request_submitted' || isReviewAction
        ? RouteConstants.leaveRequest
        : RouteConstants.leaves;
    return Uri(
      path: destination,
      queryParameters: {'request_id': requestId.toString()},
    ).toString();
  }
}
