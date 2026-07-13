/// OKR models for C18 — Objectives and Key Results.
/// OKRs are defined at the role template level, with optional quarterly scoping.

class RoleOkr {
  final int? id;
  final int roleId;
  final String roleName;
  final String objective; // The "O" in OKR
  final String? description;
  final int quarter; // 1–4
  final int year;
  final String status; // 'draft' | 'active' | 'completed' | 'cancelled'
  final List<OkrKeyResult> keyResults;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleOkr({
    this.id,
    required this.roleId,
    this.roleName = '',
    required this.objective,
    this.description,
    required this.quarter,
    required this.year,
    this.status = 'active',
    this.keyResults = const [],
    this.createdAt,
    this.updatedAt,
  });

  /// Overall progress = average of all key result progress values.
  double get overallProgress {
    if (keyResults.isEmpty) return 0;
    final total = keyResults.fold<double>(0, (sum, kr) => sum + kr.progressPercent);
    return total / keyResults.length;
  }

  factory RoleOkr.fromJson(Map<String, dynamic> json) {
    final List<dynamic> krList = json['key_results'] ?? [];
    return RoleOkr(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      roleId: json['role_id'] is int
          ? json['role_id']
          : int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      roleName: json['role_name'] ?? '',
      objective: json['objective'] ?? '',
      description: json['description'],
      quarter: json['quarter'] is int
          ? json['quarter']
          : int.tryParse(json['quarter']?.toString() ?? '1') ?? 1,
      year: json['year'] is int
          ? json['year']
          : int.tryParse(json['year']?.toString() ?? '2026') ?? 2026,
      status: json['status'] ?? 'active',
      keyResults: krList.map((k) => OkrKeyResult.fromJson(k)).toList(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'role_id': roleId,
      'objective': objective,
      'description': description,
      'quarter': quarter,
      'year': year,
      'status': status,
    };
  }

  static const List<String> statusOptions = [
    'draft',
    'active',
    'completed',
    'cancelled',
  ];
}

class OkrKeyResult {
  final int? id;
  final int? okrId;
  final String title;
  final String? description;
  final double progressPercent; // 0–100
  final String? metricUnit; // optional unit for the KR value
  final double? currentValue;
  final double? targetValue;
  final DateTime? dueDate;

  const OkrKeyResult({
    this.id,
    this.okrId,
    required this.title,
    this.description,
    this.progressPercent = 0,
    this.metricUnit,
    this.currentValue,
    this.targetValue,
    this.dueDate,
  });

  factory OkrKeyResult.fromJson(Map<String, dynamic> json) {
    return OkrKeyResult(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      okrId: json['okr_id'] is int
          ? json['okr_id']
          : int.tryParse(json['okr_id']?.toString() ?? ''),
      title: json['title'] ?? '',
      description: json['description'],
      progressPercent:
          double.tryParse(json['progress_percent']?.toString() ?? '0') ?? 0,
      metricUnit: json['metric_unit'],
      currentValue:
          double.tryParse(json['current_value']?.toString() ?? ''),
      targetValue:
          double.tryParse(json['target_value']?.toString() ?? ''),
      dueDate: json['due_date'] != null
          ? DateTime.tryParse(json['due_date'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (okrId != null) 'okr_id': okrId,
      'title': title,
      'description': description,
      'progress_percent': progressPercent,
      'metric_unit': metricUnit,
      'current_value': currentValue,
      'target_value': targetValue,
      'due_date': dueDate?.toIso8601String().split('T').first,
    };
  }

  OkrKeyResult copyWith({
    String? title,
    String? description,
    double? progressPercent,
    String? metricUnit,
    double? currentValue,
    double? targetValue,
    DateTime? dueDate,
  }) {
    return OkrKeyResult(
      id: id,
      okrId: okrId,
      title: title ?? this.title,
      description: description ?? this.description,
      progressPercent: progressPercent ?? this.progressPercent,
      metricUnit: metricUnit ?? this.metricUnit,
      currentValue: currentValue ?? this.currentValue,
      targetValue: targetValue ?? this.targetValue,
      dueDate: dueDate ?? this.dueDate,
    );
  }
}
