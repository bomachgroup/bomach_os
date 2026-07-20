import 'package:flutter/material.dart';

class MarketingTeamMember {
  final String name;
  final String role;
  final String initials;
  final Color backgroundColor;
  final String status;
  final String phone;
  final String stat;
  final double kpiPercentage;
  final Color kpiColor;
  final String kpiStatus;

  const MarketingTeamMember({
    required this.name,
    required this.role,
    required this.initials,
    required this.backgroundColor,
    this.status = 'online',
    this.phone = '',
    this.stat = '',
    this.kpiPercentage = 0,
    this.kpiColor = const Color(0xFF059669),
    this.kpiStatus = '',
  });

  factory MarketingTeamMember.fromJson(Map<String, dynamic> json) {
    return MarketingTeamMember(
      name: json['name'] ?? '',
      role: json['role'] ?? '',
      initials: json['init'] ?? '',
      backgroundColor: _parseColor(json['bg']),
      status: json['status'] ?? 'online',
      phone: json['phone'] ?? '',
      stat: json['stat'] ?? '',
      kpiPercentage: (json['pct'] ?? 0).toDouble(),
      kpiColor: _parseColor(json['col']),
      kpiStatus: json['st'] ?? '',
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF6B7280);
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }

  Color get statusColor {
    switch (status) {
      case 'online':
        return const Color(0xFF10B981);
      case 'away':
        return const Color(0xFFF59E0B);
      default:
        return const Color(0xFF9CA3AF);
    }
  }
}
