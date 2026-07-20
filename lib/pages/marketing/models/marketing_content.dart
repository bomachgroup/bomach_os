import 'package:flutter/material.dart';
import 'marketing_lead.dart';

enum ContentStatus {
  briefed,
  inProgress,
  inReview,
  published,
  overdue;

  String get label {
    switch (this) {
      case ContentStatus.briefed:
        return 'Briefed';
      case ContentStatus.inProgress:
        return 'In progress';
      case ContentStatus.inReview:
        return 'In review';
      case ContentStatus.published:
        return 'Published';
      case ContentStatus.overdue:
        return 'Overdue';
    }
  }

  Color get bgColor {
    switch (this) {
      case ContentStatus.briefed:
        return const Color(0xFFDBEAFE);
      case ContentStatus.inProgress:
        return const Color(0xFFFEF3C7);
      case ContentStatus.inReview:
        return const Color(0xFFEDE9FE);
      case ContentStatus.published:
        return const Color(0xFFD1FAE5);
      case ContentStatus.overdue:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get textColor {
    switch (this) {
      case ContentStatus.briefed:
        return const Color(0xFF1E40AF);
      case ContentStatus.inProgress:
        return const Color(0xFF92400E);
      case ContentStatus.inReview:
        return const Color(0xFF5B21B6);
      case ContentStatus.published:
        return const Color(0xFF065F46);
      case ContentStatus.overdue:
        return const Color(0xFF991B1B);
    }
  }

  Color get borderColor {
    switch (this) {
      case ContentStatus.briefed:
        return const Color(0xFF93C5FD);
      case ContentStatus.inProgress:
        return const Color(0xFFFCD34D);
      case ContentStatus.inReview:
        return const Color(0xFFC4B5FD);
      case ContentStatus.published:
        return const Color(0xFF6EE7B7);
      case ContentStatus.overdue:
        return const Color(0xFFFCA5A5);
    }
  }

  static ContentStatus fromString(String value) {
    final normalized = value.toLowerCase().replaceAll(' ', '');
    return ContentStatus.values.firstWhere(
      (e) => e.name.toLowerCase() == normalized,
      orElse: () => ContentStatus.briefed,
    );
  }
}

class ContentCalendarItem {
  final String title;
  final String format;
  final String platform;
  final MarketingDivision division;
  final String owner;
  final ContentStatus status;
  final String dueDate;

  const ContentCalendarItem({
    required this.title,
    required this.format,
    required this.platform,
    required this.division,
    required this.owner,
    required this.status,
    required this.dueDate,
  });

  factory ContentCalendarItem.fromJson(Map<String, dynamic> json) {
    return ContentCalendarItem(
      title: json['title'] ?? '',
      format: json['fmt'] ?? '',
      platform: json['platform'] ?? '',
      division: MarketingDivision.fromString(json['div'] ?? 're'),
      owner: json['owner'] ?? '',
      status: ContentStatus.fromString(json['status'] ?? 'briefed'),
      dueDate: json['due'] ?? '',
    );
  }
}

class DesignTask {
  final String id;
  final String thumbLabel;
  final Color thumbBg;
  final Color thumbTextColor;
  final String title;
  final String brief;
  final String platform;
  final String dueDate;
  final String status;
  final bool isOverdue;

  const DesignTask({
    required this.id,
    required this.thumbLabel,
    required this.thumbBg,
    required this.thumbTextColor,
    required this.title,
    required this.brief,
    required this.platform,
    required this.dueDate,
    required this.status,
    this.isOverdue = false,
  });

  factory DesignTask.fromJson(Map<String, dynamic> json) {
    return DesignTask(
      id: json['id'] ?? '',
      thumbLabel: json['thumb'] ?? '',
      thumbBg: _parseColor(json['tbg']),
      thumbTextColor: _parseColor(json['ttc']),
      title: json['title'] ?? '',
      brief: json['brief'] ?? '',
      platform: json['platform'] ?? '',
      dueDate: json['due'] ?? '',
      status: json['status'] ?? 'todo',
      isOverdue: json['overdue'] ?? false,
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFFE5E7EB);
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
