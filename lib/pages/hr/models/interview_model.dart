class Interview {
  final int? id;
  final int applicantId;
  final int interviewerId;
  final String scheduledAt;
  final String? meetingLink;
  final String? feedback;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  Interview({
    this.id,
    required this.applicantId,
    required this.interviewerId,
    required this.scheduledAt,
    this.meetingLink,
    this.feedback,
    this.status = 'scheduled',
    this.createdAt,
    this.updatedAt,
  });

  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      applicantId: json['applicant_id'] is int
          ? json['applicant_id']
          : int.tryParse(json['applicant_id']?.toString() ?? '') ?? 0,
      interviewerId: json['interviewer_id'] is int
          ? json['interviewer_id']
          : int.tryParse(json['interviewer_id']?.toString() ?? '') ?? 0,
      scheduledAt: json['scheduled_at']?.toString() ?? '',
      meetingLink: json['meeting_link']?.toString(),
      feedback: json['feedback']?.toString(),
      status: json['status']?.toString() ?? 'scheduled',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// JSON for creating a new interview.
  Map<String, dynamic> toCreateJson() {
    return {
      'interviewer_id': interviewerId,
      'scheduled_at': scheduledAt,
      if (meetingLink != null && meetingLink!.isNotEmpty)
        'meeting_link': meetingLink,
    };
  }

  /// JSON for updating an interview.
  Map<String, dynamic> toUpdateJson() {
    return {
      if (interviewerId != 0) 'interviewer_id': interviewerId,
      'scheduled_at': scheduledAt,
      if (meetingLink != null) 'meeting_link': meetingLink,
      if (status.isNotEmpty) 'status': status,
    };
  }

  /// JSON for submitting feedback.
  Map<String, dynamic> toFeedbackJson() {
    return {
      if (feedback != null) 'feedback': feedback,
      if (status.isNotEmpty) 'status': status,
    };
  }
}
