class Communication {
  final String title;
  final String content;
  final String type;
  final String priority;
  final String status;
  final String recipient;
  final String sender;
  final String date;
  final int attachments;

  Communication({
    required this.title,
    required this.content,
    required this.type,
    required this.priority,
    required this.status,
    required this.recipient,
    required this.sender,
    required this.date,
    this.attachments = 0,
  });
}

final List<Communication> mockCommunications = [
  Communication(
    title: 'Project Update: Lekki Survey Progress',
    content:
        'The Lekki Phase 2 survey project has reached 75% completion. Preliminary results are now available for review.',
    type: 'Notification',
    priority: 'Normal',
    status: 'Delivered',
    recipient: 'Lagos Property Development Ltd',
    sender: 'John Doe',
    date: '7 Feb 2024',
  ),
  Communication(
    title: 'Document Review Required',
    content:
        'Please review the attached contract amendment and provide your feedback by end of week.',
    type: 'Message',
    priority: 'High',
    status: 'Unread',
    recipient: 'Abuja Infrastructure Company',
    sender: 'Grace Adebayo',
    date: '6 Feb 2024',
    attachments: 1,
  ),
  Communication(
    title: 'New Portal Features Available',
    content:
        'We\'ve added new features to the client portal including real-time project tracking and mobile notifications.',
    type: 'Announcement',
    priority: 'Low',
    status: 'Delivered',
    recipient: 'All Clients',
    sender: 'System Administrator',
    date: '5 Feb 2024',
  ),
  Communication(
    title: 'Payment Due Reminder',
    content:
        'Your invoice for January 2024 services is due for payment. Please process payment to avoid service interruption.',
    type: 'Reminder',
    priority: 'High',
    status: 'Delivered',
    recipient: 'Lagos Property Development Ltd',
    sender: 'Grace Adebayo',
    date: '4 Feb 2024',
  ),
  Communication(
    title: 'Welcome to Bomach Survey Portal',
    content:
        'Welcome to our client portal! Here you can access project updates, documents, and communicate with our team.',
    type: 'Welcome',
    priority: 'Normal',
    status: 'Delivered',
    recipient: 'Rivers State Development Company',
    sender: 'System Administrator',
    date: '1 Feb 2024',
  ),
];
