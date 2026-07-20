import 'package:flutter/material.dart';

class MarketingOKR {
  final String objective;
  final List<KeyResult> keyResults;

  const MarketingOKR({
    required this.objective,
    required this.keyResults,
  });

  factory MarketingOKR.fromJson(Map<String, dynamic> json) {
    return MarketingOKR(
      objective: json['obj'] ?? '',
      keyResults: (json['krs'] as List<dynamic>?)
              ?.map((kr) => KeyResult.fromJson(kr as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

class KeyResult {
  final String label;
  final double percentage;
  final Color color;

  const KeyResult({
    required this.label,
    required this.percentage,
    required this.color,
  });

  factory KeyResult.fromJson(Map<String, dynamic> json) {
    return KeyResult(
      label: json['l'] ?? '',
      percentage: (json['pct'] ?? 0).toDouble(),
      color: _parseColor(json['col']),
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF059669);
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}

class TargetRow {
  final String label;
  final String target;
  final String actual;
  final double percentage;
  final Color color;

  const TargetRow({
    required this.label,
    required this.target,
    required this.actual,
    required this.percentage,
    required this.color,
  });

  factory TargetRow.fromJson(Map<String, dynamic> json) {
    return TargetRow(
      label: json['label'] ?? '',
      target: json['target'] ?? '',
      actual: json['actual'] ?? '',
      percentage: (json['pct'] ?? 0).toDouble(),
      color: _parseColor(json['col']),
    );
  }

  static Color _parseColor(String? hex) {
    if (hex == null || hex.isEmpty) return const Color(0xFF059669);
    final clean = hex.replaceFirst('#', '');
    return Color(int.parse('FF$clean', radix: 16));
  }
}
