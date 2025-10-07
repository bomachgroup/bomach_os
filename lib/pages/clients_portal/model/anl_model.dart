
class ActivityItem {
  final String title;
  final String metadata;
  final String type;
  final String status;

  ActivityItem({
    required this.title,
    required this.metadata,
    required this.type,
    required this.status,
  });
}

final List<ActivityItem> mockActivities = [
  ActivityItem(
    title: 'Project Update: Lekki Survey Progress',
    metadata: 'Lagos Property Development Ltd • 7 Feb 2024',
    type: 'Update',
    status: 'Delivered',
  ),
  ActivityItem(
    title: 'Document Review Required',
    metadata: 'Abuja Infrastructure Company • 6 Feb 2024',
    type: 'Review',
    status: 'Delivered',
  ),
  ActivityItem(
    title: 'New Portal Features Available',
    metadata: 'All Clients • 5 Feb 2024',
    type: 'Feature',
    status: 'Delivered',
  ),
  ActivityItem(
    title: 'Payment Due Reminder',
    metadata: 'Lagos Property Development Ltd • 4 Feb 2024',
    type: 'Reminder',
    status: 'Delivered',
  ),
  ActivityItem(
    title: 'Welcome to Bomach Survey Portal',
    metadata: 'Rivers State Development Company • 1 Feb 2024',
    type: 'Welcome',
    status: 'Delivered',
  ),
];
