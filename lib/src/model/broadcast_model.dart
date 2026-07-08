import 'package:bomach_os/src/model/board_model.dart';

// ─── ANNOUNCEMENT MODEL ─────────────────────────────────────────

/// Model for an Announcement from /api/v1/announcements/
/// Matches API schema: title, content, announcement_type, priority,
/// branch_ids, department_ids, is_active, publish_at, expires_at
class Announcement {
  final int id;
  final String title;
  final String content;
  final String announcementType;
  final String announcementTypeDisplay;
  final String priority;
  final String priorityDisplay;
  final String destination; // email, in_app, or both
  final List<int> branchIds;
  final List<int> departmentIds;
  final bool isActive;
  final String publishAt;
  final String expiresAt;
  final String createdAt;
  final String updatedAt;

  Announcement({
    required this.id,
    required this.title,
    required this.content,
    required this.announcementType,
    required this.announcementTypeDisplay,
    required this.priority,
    required this.priorityDisplay,
    required this.destination,
    required this.branchIds,
    required this.departmentIds,
    required this.isActive,
    required this.publishAt,
    required this.expiresAt,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    List<int> parseIntList(dynamic raw) {
      if (raw is List) {
        return raw
            .map((e) => e is int ? e : int.tryParse(e.toString()) ?? 0)
            .toList();
      }
      return [];
    }

    return Announcement(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      announcementType: json['announcement_type'] ?? '',
      announcementTypeDisplay:
          json['announcement_type_display'] ?? json['announcement_type'] ?? '',
      priority: json['priority'] ?? '',
      priorityDisplay: json['priority_display'] ?? json['priority'] ?? '',
      destination: json['destination'] ?? 'both',
      branchIds: parseIntList(json['branch_ids']),
      departmentIds: parseIntList(json['department_ids']),
      isActive: json['is_active'] ?? true,
      publishAt: json['publish_at'] ?? '',
      expiresAt: json['expires_at'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

// ─── BROADCAST EVENT MODEL ──────────────────────────────────────

/// Model for an Event from /api/v1/events/
/// Matches API schema: title, event_type, event_time_from, event_time_to,
/// meeting_location, target_all_branches, target_all_departments,
/// target_associates, target_investors, target_partners,
/// reminder_offset, recurrence
class BroadcastEvent {
  final int id;
  final String title;
  final String eventType;
  final String eventTypeDisplay;
  final String eventTimeFrom;
  final String eventTimeTo;
  final String meetingLocation;
  final bool targetAllBranches;
  final bool targetAllDepartments;
  final bool targetAssociates;
  final bool targetInvestors;
  final bool targetPartners;
  final int reminderOffset;
  final String recurrence;
  final String createdAt;
  final String updatedAt;

  BroadcastEvent({
    required this.id,
    required this.title,
    required this.eventType,
    required this.eventTypeDisplay,
    required this.eventTimeFrom,
    required this.eventTimeTo,
    required this.meetingLocation,
    required this.targetAllBranches,
    required this.targetAllDepartments,
    required this.targetAssociates,
    required this.targetInvestors,
    required this.targetPartners,
    required this.reminderOffset,
    required this.recurrence,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Build a list of audience labels for display
  List<String> get targetAudienceLabels {
    final labels = <String>[];
    if (targetAllBranches) labels.add('All Branches');
    if (targetAllDepartments) labels.add('All Departments');
    if (targetAssociates) labels.add('Associates');
    if (targetInvestors) labels.add('Investors');
    if (targetPartners) labels.add('Partners');
    return labels;
  }

  factory BroadcastEvent.fromJson(Map<String, dynamic> json) {
    return BroadcastEvent(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      eventType: json['event_type'] ?? '',
      eventTypeDisplay: json['event_type_display'] ?? json['event_type'] ?? '',
      eventTimeFrom: json['event_time_from'] ?? '',
      eventTimeTo: json['event_time_to'] ?? '',
      meetingLocation: json['meeting_location'] ?? '',
      targetAllBranches: json['target_all_branches'] ?? false,
      targetAllDepartments: json['target_all_departments'] ?? false,
      targetAssociates: json['target_associates'] ?? false,
      targetInvestors: json['target_investors'] ?? false,
      targetPartners: json['target_partners'] ?? false,
      reminderOffset: _parseReminderOffset(json['reminder_offset']) ?? 0,
      recurrence: json['recurrence'] ?? '',
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }
}

int? _parseReminderOffset(dynamic val) {
  if (val == null) return null;
  if (val is num) return val.toInt();
  if (val is String) {
    final clean = val.trim().toLowerCase();
    if (clean.contains('no reminder') || clean == 'none') {
      return 0;
    }
    final parsed = int.tryParse(clean);
    if (parsed != null) return parsed;

    if (clean.contains('hour')) {
      final hours = int.tryParse(clean.split(' ').first);
      if (hours != null) return hours * 60;
    }
    if (clean.contains('day')) {
      final days = int.tryParse(clean.split(' ').first);
      if (days != null) return days * 1440;
    }
    if (clean.contains('minute')) {
      final minutes = int.tryParse(clean.split(' ').first);
      if (minutes != null) return minutes;
    }
  }
  return 0;
}

// ─── NOTIFICATION ITEM (UI-only) ────────────────────────────────

/// Display model for notification cards. No API endpoint available yet.
class NotificationItem {
  final String title;
  final String subtitle;
  final String description;
  final String time;
  final String category; // Admin, Staff, Associate, Investor
  final bool isRead;

  NotificationItem({
    required this.title,
    required this.subtitle,
    required this.description,
    required this.time,
    this.category = 'Admin',
    this.isRead = false,
  });
}

// ─── ANNOUNCEMENT FIELD CHOICES ─────────────────────────────────

/// Choices returned by GET /api/v1/announcements/choices
class AnnouncementFieldChoices {
  final List<BoardFieldOption> announcementTypes;
  final List<BoardFieldOption> priorities;

  AnnouncementFieldChoices({
    required this.announcementTypes,
    required this.priorities,
  });

  factory AnnouncementFieldChoices.fromJson(Map<String, dynamic> json) {
    List<BoardFieldOption> parseOptions(dynamic raw) {
      if (raw is List) {
        return raw.map((e) {
          if (e is Map<String, dynamic>) {
            return BoardFieldOption(
              value: e['value']?.toString() ?? '',
              label: e['label']?.toString() ?? e['display']?.toString() ?? '',
            );
          }
          // If it's a list of strings
          final str = e.toString();
          return BoardFieldOption(value: str, label: str);
        }).toList();
      }
      return [];
    }

    return AnnouncementFieldChoices(
      announcementTypes:
          parseOptions(json['announcement_types'] ?? json['announcement_type']),
      priorities: parseOptions(json['priorities'] ?? json['priority']),
    );
  }
}
