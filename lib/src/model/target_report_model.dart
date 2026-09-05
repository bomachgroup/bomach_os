class TargetReport {
  final int id;
  final int employeeTargetId;
  final String summary;
  final double progressValue;
  final String status;
  final String rejectionReason;
  final String targetTitle;
  final double? targetValue;
  final String targetUnit;
  final String targetPeriod;
  final String employeeCode;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? reviewedAt;

  const TargetReport({
    required this.id,
    required this.employeeTargetId,
    required this.summary,
    required this.progressValue,
    required this.status,
    required this.rejectionReason,
    required this.targetTitle,
    required this.targetValue,
    required this.targetUnit,
    required this.targetPeriod,
    required this.employeeCode,
    required this.createdAt,
    required this.updatedAt,
    required this.reviewedAt,
  });

  factory TargetReport.fromJson(Map<String, dynamic> json) {
    final target = json['employee_target'] is Map
        ? Map<String, dynamic>.from(json['employee_target'] as Map)
        : const <String, dynamic>{};
    final employee = json['employee'] is Map
        ? Map<String, dynamic>.from(json['employee'] as Map)
        : const <String, dynamic>{};

    return TargetReport(
      id: _toInt(json['id']),
      employeeTargetId: _toInt(json['employee_target_id']),
      summary: json['summary']?.toString() ?? '',
      progressValue: _toDouble(json['progress_value']),
      status: json['status']?.toString() ?? '',
      rejectionReason: json['rejection_reason']?.toString() ?? '',
      targetTitle: target['title']?.toString() ??
          'Target #${_toInt(json['employee_target_id'])}',
      targetValue: target['target_value'] == null
          ? null
          : _toDouble(target['target_value']),
      targetUnit: target['unit']?.toString() ?? '',
      targetPeriod: target['period']?.toString() ?? '',
      employeeCode: employee['employee_id']?.toString() ?? '',
      createdAt: _toDateTime(json['created_at']),
      updatedAt: _toDateTime(json['updated_at']),
      reviewedAt: _toDateTime(json['reviewed_at']),
    );
  }

  static int _toInt(dynamic value) =>
      value is num ? value.toInt() : int.tryParse(value?.toString() ?? '') ?? 0;

  static double _toDouble(dynamic value) => value is num
      ? value.toDouble()
      : double.tryParse(value?.toString() ?? '') ?? 0;

  static DateTime? _toDateTime(dynamic value) =>
      value == null ? null : DateTime.tryParse(value.toString());
}
