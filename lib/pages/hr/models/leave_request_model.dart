class LeaveRequest {
  final String id;
  final String employeeId;
  final String leaveType; // e.g., 'sick', 'vacation'
  final String status; // e.g., 'pending', 'approved'
  final DateTime? startDate;
  final DateTime? endDate;
  final String? reason;
  final String? rejectionReason;
  final DateTime? createdAt;

  LeaveRequest({
    required this.id,
    required this.employeeId,
    required this.leaveType,
    required this.status,
    this.startDate,
    this.endDate,
    this.reason,
    this.rejectionReason,
    this.createdAt,
  });

  factory LeaveRequest.fromJson(Map<String, dynamic> json) {
    return LeaveRequest(
      id: json['id'] ?? '',
      employeeId: json['employee_id'] ?? '',
      leaveType: json['leave_type'] ?? '',
      status: json['status'] ?? 'pending',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      reason: json['reason'],
      rejectionReason: json['rejection_reason'],
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'leave_type': leaveType,
      'status': status,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'reason': reason,
      'rejection_reason': rejectionReason,
    };
  }
}