class LoanRequest {
  final int? id;
  final String loanAmount;
  final String repaymentDate;
  final String reason;
  final String employeeName;
  final String jobTitle;
  final String status;
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String attachment;
  final String? createdAt;

  LoanRequest({
    this.id,
    required this.loanAmount,
    required this.repaymentDate,
    required this.reason,
    this.employeeName = '',
    this.jobTitle = '',
    this.status = 'pending',
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    this.attachment = '',
    this.createdAt,
  });

  factory LoanRequest.fromJson(Map<String, dynamic> json) {
    return LoanRequest(
      id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? ''),
      loanAmount: json['loan_amount']?.toString() ?? '0',
      repaymentDate: json['repayment_date']?.toString() ?? '',
      reason: json['reason']?.toString() ?? '',
      employeeName: json['employee_name']?.toString() ?? '',
      jobTitle: json['job_title']?.toString() ?? '',
      status: json['status']?.toString() ?? 'pending',
      emergencyContactName: json['emergency_contact_name']?.toString() ?? '',
      emergencyContactPhone: json['emergency_contact_phone']?.toString() ?? '',
      attachment: json['attachment']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'loan_amount': loanAmount,
      'repayment_date': repaymentDate,
      'reason': reason,
      'emergency_contact_name': emergencyContactName,
      'emergency_contact_phone': emergencyContactPhone,
      'attachment': attachment,
    };
  }
}
