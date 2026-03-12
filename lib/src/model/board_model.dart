/// Model for a Board Meeting from /api/v1/meetings/
class BoardMeeting {
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
  final String location;
  final List<MeetingAttendee> attendees;
  final int attendeeCount;
  final int organizerId;
  final String organizerName;
  final String? fileUrl;
  final String? notes;
  final String createdAt;
  final String updatedAt;

  BoardMeeting({
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
    required this.location,
    required this.attendees,
    required this.attendeeCount,
    required this.organizerId,
    required this.organizerName,
    this.fileUrl,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BoardMeeting.fromJson(Map<String, dynamic> json) {
    return BoardMeeting(
      id: json['id'] ?? 0,
      meetingId: json['meeting_id'] ?? '',
      title: json['title'] ?? '',
      agenda: json['agenda'] ?? '',
      meetingDate: json['meeting_date'] ?? '',
      meetingTime: json['meeting_time'] ?? '',
      durationMinutes: json['duration_minutes'] ?? 0,
      durationDisplay: json['duration_display'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? json['status'] ?? '',
      locationType: json['location_type'] ?? '',
      locationTypeDisplay:
          json['location_type_display'] ?? json['location_type'] ?? '',
      location: json['location'] ?? '',
      attendees: (json['attendees'] as List?)
              ?.map((e) => MeetingAttendee.fromJson(e))
              .toList() ??
          [],
      attendeeCount: json['attendee_count'] ?? 0,
      organizerId: json['organizer_id'] ?? 0,
      organizerName: json['organizer_name'] ?? '',
      fileUrl: json['file_url'],
      notes: json['notes'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

class MeetingAttendee {
  final int id;
  final String name;
  final String? email;

  MeetingAttendee({
    required this.id,
    required this.name,
    this.email,
  });

  factory MeetingAttendee.fromJson(Map<String, dynamic> json) {
    return MeetingAttendee(
      id: json['user_id'] ?? json['id'] ?? 0,
      name: json['full_name'] ?? json['name'] ?? '',
      email: json['email'],
    );
  }
}

/// Model for a Board Resolution from /api/v1/board-resolutions/
class BoardResolution {
  final int id;
  final String resolutionId;
  final String title;
  final String description;
  final String resolutionType;
  final String resolutionTypeDisplay;
  final String status;
  final String statusDisplay;
  final String resolutionDate;
  final String? attachmentUrl;
  final String? notes;
  final int createdById;
  final String createdByName;
  final int? approvedById;
  final String? approvedByName;
  final String? approvedAt;
  final String createdAt;
  final String updatedAt;

  BoardResolution({
    required this.id,
    required this.resolutionId,
    required this.title,
    required this.description,
    required this.resolutionType,
    required this.resolutionTypeDisplay,
    required this.status,
    required this.statusDisplay,
    required this.resolutionDate,
    this.attachmentUrl,
    this.notes,
    required this.createdById,
    required this.createdByName,
    this.approvedById,
    this.approvedByName,
    this.approvedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory BoardResolution.fromJson(Map<String, dynamic> json) {
    return BoardResolution(
      id: json['id'] ?? 0,
      resolutionId: json['resolution_id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      resolutionType: json['resolution_type'] ?? '',
      resolutionTypeDisplay:
          json['resolution_type_display'] ?? json['resolution_type'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['status_display'] ?? json['status'] ?? '',
      resolutionDate: json['resolution_date'] ?? '',
      attachmentUrl: json['attachment_url'],
      notes: json['notes'],
      createdById: json['created_by_id'] ?? 0,
      createdByName: json['created_by_name'] ?? '',
      approvedById: json['approved_by_id'],
      approvedByName: json['approved_by_name'],
      approvedAt: json['approved_at'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

/// Choices for meeting fields from /api/v1/meetings/choices
class MeetingFieldChoices {
  final List<BoardFieldOption> statuses;
  final List<BoardFieldOption> locationTypes;

  MeetingFieldChoices({
    required this.statuses,
    required this.locationTypes,
  });

  factory MeetingFieldChoices.fromJson(Map<String, dynamic> json) {
    return MeetingFieldChoices(
      statuses: (json['statuses'] as List?)
              ?.map((e) => BoardFieldOption.fromJson(e))
              .toList() ??
          [],
      locationTypes: (json['location_types'] as List?)
              ?.map((e) => BoardFieldOption.fromJson(e))
              .toList() ??
          [],
    );
  }
}

/// Choices for resolution fields from /api/v1/board-resolutions/choices
class ResolutionFieldChoices {
  final List<BoardFieldOption> resolutionTypes;
  final List<BoardFieldOption> statuses;

  ResolutionFieldChoices({
    required this.resolutionTypes,
    required this.statuses,
  });

  factory ResolutionFieldChoices.fromJson(Map<String, dynamic> json) {
    return ResolutionFieldChoices(
      resolutionTypes: (json['resolution_types'] as List?)
              ?.map((e) => BoardFieldOption.fromJson(e))
              .toList() ??
          [],
      statuses: (json['statuses'] as List?)
              ?.map((e) => BoardFieldOption.fromJson(e))
              .toList() ??
          [],
    );
  }
}

class BoardFieldOption {
  final String value;
  final String label;

  BoardFieldOption({required this.value, required this.label});

  factory BoardFieldOption.fromJson(Map<String, dynamic> json) {
    return BoardFieldOption(
      value: json['value'] ?? '',
      label: json['label'] ?? json['display'] ?? '',
    );
  }
}
