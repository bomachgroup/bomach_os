import 'package:bomach_os/src/model/board_model.dart';
import 'package:intl/intl.dart';

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
    final rawId = json['id'];
    int parsedId = 0;
    if (rawId is int) {
      parsedId = rawId;
    } else if (rawId is String) {
      parsedId = int.tryParse(rawId) ?? 0;
    }
    if (parsedId == 0) {
      // Generate a consistent unique integer hash to prevent GlobalKey collisions in lists
      final uniqueStr =
          "${json['title']}_${json['created_at']}_${json['date_sent']}";
      parsedId = uniqueStr.hashCode;
    }

    // Resilient fallback when event_time_from/to are missing from the GET list serializer
    final timeFrom = json['event_time_from'] ??
        json['date_sent'] ??
        json['created_at'] ??
        '';
    final timeTo = json['event_time_to'] ?? timeFrom;

    return BroadcastEvent(
      id: parsedId,
      title: json['title'] ?? '',
      eventType: json['event_type'] ?? '',
      eventTypeDisplay: json['event_type_display'] ?? json['event_type'] ?? '',
      eventTimeFrom: timeFrom,
      eventTimeTo: timeTo,
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

/// Persisted notification returned by the system inbox API.
class NotificationItem {
  final int? id;
  final String title;
  final String subtitle;
  final String description;
  final String time;
  final String category;
  final bool isRead;
  final String notificationType;
  final String? eventType;
  final String priority;
  final String link;
  final String action;
  final String entityType;
  final String entityId;
  final Map<String, dynamic> metadata;
  final String createdAt;

  NotificationItem({
    this.id,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.time,
    this.category = 'General',
    this.isRead = false,
    this.notificationType = '',
    this.eventType,
    this.priority = 'normal',
    this.link = '',
    this.action = '',
    this.entityType = '',
    this.entityId = '',
    this.metadata = const {},
    this.createdAt = '',
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    final createdAt = json['created_at']?.toString() ?? '';
    final eventType = json['event_type']?.toString();
    return NotificationItem(
      id: json['id'] is int ? json['id'] : int.tryParse('${json['id']}'),
      title: json['title']?.toString() ?? 'Notification',
      subtitle: eventType ?? json['notification_type']?.toString() ?? 'Update',
      description: json['message']?.toString() ?? '',
      time: createdAt,
      category: _notificationCategory(
          eventType ?? json['notification_type']?.toString() ?? ''),
      isRead: json['is_read'] == true,
      notificationType: json['notification_type']?.toString() ?? '',
      eventType: eventType,
      priority: json['priority']?.toString() ?? 'normal',
      link: json['link']?.toString() ?? '',
      action: json['action']?.toString() ?? '',
      entityType: json['entity_type']?.toString() ?? '',
      entityId: json['entity_id']?.toString() ?? '',
      metadata: json['metadata'] is Map
          ? Map<String, dynamic>.from(json['metadata'] as Map)
          : const {},
      createdAt: createdAt,
    );
  }

  NotificationItem copyWith({bool? isRead}) => NotificationItem(
        id: id,
        title: title,
        subtitle: subtitle,
        description: description,
        time: time,
        category: category,
        isRead: isRead ?? this.isRead,
        notificationType: notificationType,
        eventType: eventType,
        priority: priority,
        link: link,
        action: action,
        entityType: entityType,
        entityId: entityId,
        metadata: metadata,
        createdAt: createdAt,
      );
}

String _notificationCategory(String eventType) {
  final type = eventType.toLowerCase();
  if (type.contains('work_location')) return 'Work locations';
  if (type.contains('attendance')) return 'Attendance';
  if (type.contains('task')) return 'Tasks';
  if (type.contains('leave')) return 'Leave';
  if (type.contains('payment') || type.contains('invoice')) return 'Finance';
  return 'General';
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

DateTime? parseApiDateTime(String dateStr) {
  if (dateStr.isEmpty) return null;

  // Try standard ISO 8601 first (handles 2026-07-09T11:00:00.000Z etc.)
  final isoParsed = DateTime.tryParse(dateStr);
  if (isoParsed != null) return isoParsed;

  // Try parsing the backend custom display formats
  try {
    // Format: dd-MM-yyyy, hh:mm a (e.g. 09-07-2026, 11:00 AM)
    final normalized =
        dateStr.trim().replaceAll(RegExp(r'\s+'), ' ').toUpperCase();
    return DateFormat('dd-MM-yyyy, hh:mm a').parse(normalized);
  } catch (_) {}

  try {
    // Format: dd-MM-yyyy, HH:mm
    final normalized = dateStr.trim().replaceAll(RegExp(r'\s+'), ' ');
    return DateFormat('dd-MM-yyyy, HH:mm').parse(normalized);
  } catch (_) {}

  return null;
}
