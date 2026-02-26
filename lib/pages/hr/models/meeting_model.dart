class MeetingAttendee {
  final int userId;
  final String fullName;
  final String email;

  MeetingAttendee({
    required this.userId,
    required this.fullName,
    required this.email,
  });

  factory MeetingAttendee.fromJson(Map<String, dynamic> json) {
    return MeetingAttendee(
      userId: int.tryParse(json['user_id']?.toString() ?? '0') ?? 0,
      fullName: json['full_name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
    );
  }
}

class Meeting {
  final int id;
  final String meetingId;
  final String title;
  final String agenda;
  final String meetingDate;
  final String meetingTime;
  final int durationMinutes;
  final String durationDisplay;
  final String status;
  final String statusDisplay;
  final String locationType;
  final String locationTypeDisplay;
  final String? location;
  final List<MeetingAttendee> attendees;
  // IDs used when creating / updating
  final List<int> attendeeIds;
  final int attendeeCount;
  final int? organizerId;
  final String? organizerName;
  final String? notes;
  final String createdAt;

  Meeting({
    required this.id,
    required this.meetingId,
    required this.title,
    required this.agenda,
    required this.meetingDate,
    required this.meetingTime,
    required this.durationMinutes,
    required this.durationDisplay,
    required this.status,
    required this.statusDisplay,
    required this.locationType,
    required this.locationTypeDisplay,
    this.location,
    required this.attendees,
    List<int>? attendeeIds,
    required this.attendeeCount,
    this.organizerId,
    this.organizerName,
    this.notes,
    required this.createdAt,
  }) : attendeeIds = attendeeIds ?? attendees.map((a) => a.userId).toList();

  factory Meeting.fromJson(Map<String, dynamic> json) {
    final List<dynamic> attendeeList = json['attendees'] ?? [];
    final parsedAttendees =
        attendeeList.map((a) => MeetingAttendee.fromJson(a)).toList();
    return Meeting(
      id: int.tryParse(json['id']?.toString() ?? '0') ?? 0,
      meetingId: json['meeting_id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      agenda: json['agenda']?.toString() ?? '',
      meetingDate: json['meeting_date']?.toString() ?? '',
      meetingTime: json['meeting_time']?.toString() ?? '',
      durationMinutes:
          int.tryParse(json['duration_minutes']?.toString() ?? '0') ?? 0,
      durationDisplay: json['duration_display']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      statusDisplay: json['status_display']?.toString() ?? '',
      locationType: json['location_type']?.toString() ?? '',
      locationTypeDisplay: json['location_type_display']?.toString() ?? '',
      location: json['location']?.toString(),
      attendees: parsedAttendees,
      attendeeIds: parsedAttendees.map((a) => a.userId).toList(),
      attendeeCount:
          int.tryParse(json['attendee_count']?.toString() ?? '0') ?? 0,
      organizerId: json['organizer_id'] != null
          ? int.tryParse(json['organizer_id'].toString())
          : null,
      organizerName: json['organizer_name']?.toString(),
      notes: json['notes']?.toString(),
      createdAt: json['created_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'agenda': agenda,
      'meeting_date': meetingDate,
      'meeting_time': meetingTime,
      'duration_minutes': durationMinutes,
      'status': status,
      'location_type': locationType,
      if (location != null && location!.isNotEmpty) 'location': location,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
      'attendee_ids': attendeeIds,
    };
  }
}
