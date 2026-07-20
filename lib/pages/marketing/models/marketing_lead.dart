import 'package:flutter/material.dart';

enum LeadStage {
  newLead,
  contacted,
  qualified,
  proposal,
  negotiation,
  won,
  lost;

  String get label {
    switch (this) {
      case LeadStage.newLead:
        return 'New';
      case LeadStage.contacted:
        return 'Contacted';
      case LeadStage.qualified:
        return 'Qualified';
      case LeadStage.proposal:
        return 'Proposal sent';
      case LeadStage.negotiation:
        return 'Negotiation';
      case LeadStage.won:
        return 'Won';
      case LeadStage.lost:
        return 'Lost';
    }
  }

  Color get pillColor {
    switch (this) {
      case LeadStage.newLead:
        return const Color(0xFFDBEAFE);
      case LeadStage.contacted:
        return const Color(0xFFD1FAE5);
      case LeadStage.qualified:
        return const Color(0xFFFEF3C7);
      case LeadStage.proposal:
        return const Color(0xFFEDE9FE);
      case LeadStage.negotiation:
        return const Color(0xFFFCE7F3);
      case LeadStage.won:
        return const Color(0xFFD1FAE5);
      case LeadStage.lost:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get pillTextColor {
    switch (this) {
      case LeadStage.newLead:
        return const Color(0xFF1E40AF);
      case LeadStage.contacted:
        return const Color(0xFF065F46);
      case LeadStage.qualified:
        return const Color(0xFF92400E);
      case LeadStage.proposal:
        return const Color(0xFF5B21B6);
      case LeadStage.negotiation:
        return const Color(0xFF9D174D);
      case LeadStage.won:
        return const Color(0xFF065F46);
      case LeadStage.lost:
        return const Color(0xFF991B1B);
    }
  }

  static LeadStage fromString(String value) {
    return LeadStage.values.firstWhere(
      (e) => e.name == value,
      orElse: () => LeadStage.newLead,
    );
  }
}

enum MarketingDivision {
  re,
  eng,
  sur,
  ben,
  ict,
  agr;

  String get label {
    switch (this) {
      case MarketingDivision.re:
        return 'Real Estate';
      case MarketingDivision.eng:
        return 'Engineering';
      case MarketingDivision.sur:
        return 'Surveying';
      case MarketingDivision.ben:
        return 'Benji';
      case MarketingDivision.ict:
        return 'ICT';
      case MarketingDivision.agr:
        return 'Agriculture';
    }
  }

  Color get pillColor {
    switch (this) {
      case MarketingDivision.re:
        return const Color(0xFFDBEAFE);
      case MarketingDivision.eng:
        return const Color(0xFFFEF3C7);
      case MarketingDivision.sur:
        return const Color(0xFFD1FAE5);
      case MarketingDivision.ben:
        return const Color(0xFFEDE9FE);
      case MarketingDivision.ict:
        return const Color(0xFFFCE7F3);
      case MarketingDivision.agr:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get pillTextColor {
    switch (this) {
      case MarketingDivision.re:
        return const Color(0xFF1E40AF);
      case MarketingDivision.eng:
        return const Color(0xFF92400E);
      case MarketingDivision.sur:
        return const Color(0xFF065F46);
      case MarketingDivision.ben:
        return const Color(0xFF5B21B6);
      case MarketingDivision.ict:
        return const Color(0xFF9D174D);
      case MarketingDivision.agr:
        return const Color(0xFF991B1B);
    }
  }

  static MarketingDivision fromString(String value) {
    return MarketingDivision.values.firstWhere(
      (e) => e.name == value,
      orElse: () => MarketingDivision.re,
    );
  }
}

class MarketingLead {
  final String id;
  final String name;
  final String phone;
  final MarketingDivision division;
  final String source;
  final String campaign;
  final String budget;
  final LeadStage stage;
  final String assignedTo;
  final String value;
  final bool isOverdue;
  final List<LeadActivity> activities;

  const MarketingLead({
    required this.id,
    required this.name,
    required this.phone,
    required this.division,
    required this.source,
    this.campaign = '—',
    this.budget = '—',
    required this.stage,
    required this.assignedTo,
    this.value = '—',
    this.isOverdue = false,
    this.activities = const [],
  });

  factory MarketingLead.fromJson(Map<String, dynamic> json) {
    return MarketingLead(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      division: MarketingDivision.fromString(json['div'] ?? 're'),
      source: json['source'] ?? '',
      campaign: json['campaign'] ?? '—',
      budget: json['budget'] ?? '—',
      stage: LeadStage.fromString(json['stage'] ?? 'new'),
      assignedTo: json['assigned'] ?? '',
      value: json['value'] ?? '—',
      isOverdue: json['overdue'] ?? false,
      activities: (json['activities'] as List<dynamic>?)
              ?.map((a) => LeadActivity.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String get initials {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, name.length.clamp(0, 2)).toUpperCase();
  }

  Color get avatarColor {
    switch (division) {
      case MarketingDivision.re:
        return const Color(0xFFDBEAFE);
      case MarketingDivision.eng:
        return const Color(0xFFFEF3C7);
      case MarketingDivision.sur:
        return const Color(0xFFD1FAE5);
      case MarketingDivision.ben:
        return const Color(0xFFEDE9FE);
      case MarketingDivision.ict:
        return const Color(0xFFFCE7F3);
      case MarketingDivision.agr:
        return const Color(0xFFFEE2E2);
    }
  }

  Color get avatarTextColor {
    switch (division) {
      case MarketingDivision.re:
        return const Color(0xFF1E40AF);
      case MarketingDivision.eng:
        return const Color(0xFF92400E);
      case MarketingDivision.sur:
        return const Color(0xFF065F46);
      case MarketingDivision.ben:
        return const Color(0xFF5B21B6);
      case MarketingDivision.ict:
        return const Color(0xFF9D174D);
      case MarketingDivision.agr:
        return const Color(0xFF991B1B);
    }
  }
}

class LeadActivity {
  final String title;
  final String meta;

  const LeadActivity({required this.title, required this.meta});

  factory LeadActivity.fromJson(Map<String, dynamic> json) {
    return LeadActivity(
      title: json['t'] ?? '',
      meta: json['m'] ?? '',
    );
  }
}
