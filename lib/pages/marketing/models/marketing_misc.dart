import 'package:flutter/material.dart';
import 'marketing_lead.dart';

class MarketingNotification {
  final String icon;
  final Color iconBg;
  final Color iconColor;
  final String text;
  final String time;
  final bool isRead;

  const MarketingNotification({
    required this.icon,
    required this.iconBg,
    required this.iconColor,
    required this.text,
    required this.time,
    this.isRead = false,
  });

  factory MarketingNotification.fromJson(Map<String, dynamic> json) {
    return MarketingNotification(
      icon: json['icon'] ?? '',
      iconBg: _parseColor(json['bg']),
      iconColor: _parseColor(json['col']),
      text: json['txt'] ?? '',
      time: json['time'] ?? '',
      isRead: json['read'] ?? false,
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF6B7280);
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class WhatsAppConversation {
  final String id;
  final String initials;
  final Color bgColor;
  final Color textColor;
  final String name;
  final String time;
  final bool isUnread;
  final List<WhatsAppMessage> thread;

  const WhatsAppConversation({
    required this.id,
    required this.initials,
    required this.bgColor,
    required this.textColor,
    required this.name,
    required this.time,
    this.isUnread = false,
    this.thread = const [],
  });

  factory WhatsAppConversation.fromJson(Map<String, dynamic> json) {
    return WhatsAppConversation(
      id: json['id'] ?? '',
      initials: json['init'] ?? '',
      bgColor: _parseColor(json['bg']),
      textColor: _parseColor(json['tc']),
      name: json['name'] ?? '',
      time: json['time'] ?? '',
      isUnread: json['unread'] ?? false,
      thread: (json['thread'] as List<dynamic>?)
              ?.map((m) => WhatsAppMessage.fromJson(m as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF6B7280);
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class WhatsAppMessage {
  final bool isOutgoing;
  final String text;
  final String time;

  const WhatsAppMessage({
    required this.isOutgoing,
    required this.text,
    required this.time,
  });

  factory WhatsAppMessage.fromJson(Map<String, dynamic> json) {
    return WhatsAppMessage(
      isOutgoing: json['out'] ?? false,
      text: json['text'] ?? '',
      time: json['time'] ?? '',
    );
  }
}

class MediaAsset {
  final String title;
  final String type;
  final Color bgColor;
  final String icon;
  final MarketingDivision division;
  final String size;

  const MediaAsset({
    required this.title,
    required this.type,
    required this.bgColor,
    required this.icon,
    required this.division,
    required this.size,
  });

  factory MediaAsset.fromJson(Map<String, dynamic> json) {
    return MediaAsset(
      title: json['title'] ?? '',
      type: json['type'] ?? '',
      bgColor: _parseColor(json['bg']),
      icon: json['icon'] ?? '',
      division: MarketingDivision.fromString(json['div'] ?? 're'),
      size: json['size'] ?? '',
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF6B7280);
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class BroadcastRecord {
  final String date;
  final String audience;
  final int sent;
  final int delivered;
  final int responses;
  final int generated;

  const BroadcastRecord({
    required this.date,
    required this.audience,
    required this.sent,
    required this.delivered,
    required this.responses,
    required this.generated,
  });

  factory BroadcastRecord.fromJson(Map<String, dynamic> json) {
    return BroadcastRecord(
      date: json['date'] ?? '',
      audience: json['audience'] ?? '',
      sent: json['sent'] ?? 0,
      delivered: json['delivered'] ?? 0,
      responses: json['resp'] ?? 0,
      generated: json['gen'] ?? 0,
    );
  }
}

class SupportTicket {
  final String id;
  final String customerName;
  final String issue;
  final MarketingDivision division;
  final String priority;
  final String time;
  final String assignedTo;
  final bool isResolved;

  const SupportTicket({
    required this.id,
    required this.customerName,
    required this.issue,
    required this.division,
    required this.priority,
    required this.time,
    required this.assignedTo,
    this.isResolved = false,
  });

  factory SupportTicket.fromJson(Map<String, dynamic> json) {
    return SupportTicket(
      id: json['id'] ?? '',
      customerName: json['name'] ?? '',
      issue: json['issue'] ?? '',
      division: MarketingDivision.fromString(json['div'] ?? 're'),
      priority: json['priority'] ?? 'medium',
      time: json['time'] ?? '',
      assignedTo: json['assigned'] ?? '',
      isResolved: json['resolved'] ?? false,
    );
  }
}

class RealtorPartner {
  final String initials;
  final Color bgColor;
  final Color textColor;
  final String name;
  final String since;
  final String commission;
  final String phone;
  final String referrals;
  final String status;

  const RealtorPartner({
    required this.initials,
    required this.bgColor,
    required this.textColor,
    required this.name,
    required this.since,
    required this.commission,
    required this.phone,
    required this.referrals,
    required this.status,
  });

  factory RealtorPartner.fromJson(Map<String, dynamic> json) {
    return RealtorPartner(
      initials: json['init'] ?? '',
      bgColor: _parseColor(json['bg']),
      textColor: _parseColor(json['tc']),
      name: json['name'] ?? '',
      since: json['since'] ?? '',
      commission: json['comm'] ?? '',
      phone: json['phone'] ?? '',
      referrals: json['referrals'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF6B7280);
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class InfluencerPartner {
  final String initials;
  final Color bgColor;
  final String name;
  final String handle;
  final String platform;
  final String followers;
  final String engagement;
  final String niche;
  final String rate;
  final String status;

  const InfluencerPartner({
    required this.initials,
    required this.bgColor,
    required this.name,
    required this.handle,
    required this.platform,
    required this.followers,
    required this.engagement,
    required this.niche,
    required this.rate,
    required this.status,
  });

  factory InfluencerPartner.fromJson(Map<String, dynamic> json) {
    return InfluencerPartner(
      initials: json['init'] ?? '',
      bgColor: _parseColor(json['bg']),
      name: json['name'] ?? '',
      handle: json['handle'] ?? '',
      platform: json['platform'] ?? '',
      followers: json['followers'] ?? '',
      engagement: json['eng'] ?? '',
      niche: json['niche'] ?? '',
      rate: json['rate'] ?? '',
      status: json['status'] ?? 'pending',
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF6B7280);
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
