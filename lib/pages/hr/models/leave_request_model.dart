class LeaveRequest {
  final int? id;
  final String employeeId;
  final String requestKind;
  final String leaveType; // e.g., 'sick_leave'
  final String? employeeName;
  final String? employeeCode;
  final String? branchName;
  final String? status; // e.g., 'pending', 'approved'
  final DateTime? startDate;
  final DateTime? endDate;
  final String? reason;
  final String? approverId;
  final String? approverName;
  final DateTime? approvalDate;
  final String? rejectionReason;
  final int? durationDays;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    this.requestKind = 'leave',
    required this.leaveType,
    this.employeeName,
    this.employeeCode,
    this.branchName,
    this.status,
    this.startDate,
    this.endDate,
    this.reason,
    this.approverId,
    this.approverName,
    this.approvalDate,
    this.rejectionReason,
    this.durationDays,
    this.createdAt,
    this.updatedAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic v) {
      if (v == null) return null;
      if (v is String && v.isNotEmpty) {
        // accept date-only or ISO strings
        try {
          return DateTime.parse(v);
        } catch (_) {
          // try yyyy-MM-dd
          try {
            return DateTime.parse("${v}T00:00:00");
          } catch (_) {
            return null;
          }
        }
      }
      return null;
    }

    return LeaveRequest(
      id: json['id'] is int
          ? json['id']
          : (json['id'] is String ? int.tryParse(json['id']) : null),
      employeeId: json['employee_id']?.toString() ?? '',
      requestKind: json['request_kind']?.toString() ?? 'leave',
      leaveType: json['leave_type']?.toString() ?? '',
      employeeName: json['employee_name']?.toString(),
      employeeCode: json['employee_code']?.toString(),
      branchName: json['branch_name']?.toString(),
      status: json['status']?.toString(),
      startDate: parseDate(json['start_date']),
      endDate: parseDate(json['end_date']),
      reason: json['reason']?.toString(),
      approverId: json['approver_id']?.toString(),
      approverName: json['approver_name']?.toString(),
      approvalDate: parseDate(json['approval_date']),
      rejectionReason: json['rejection_reason']?.toString(),
      durationDays: json['duration_days'] is int
          ? json['duration_days']
          : (json['duration_days'] is String
              ? int.tryParse(json['duration_days'])
              : null),
      createdAt: parseDate(json['created_at']),
      updatedAt: parseDate(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    // payload for create/update
    return {
      'employee_id': employeeId,
      'leave_type': leaveType,
      'start_date': startDate?.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'reason': reason,
    }..removeWhere((key, value) => value == null);
  }
}
