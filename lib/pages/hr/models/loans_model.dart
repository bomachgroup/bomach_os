class LoanRequest {
  final String id;
  final String employeeName;
  final String employeeRole;
  final double amount;
  final DateTime repaymentDate;
  final String reason;
  final String status; // 'Approved', 'Rejected', 'Pending'
  final String imageUrl; // For dummy avatar

  LoanRequest({
    required this.id,
    required this.employeeName,
    required this.employeeRole,
    required this.amount,
    required this.repaymentDate,
    required this.reason,
    required this.status,
    this.imageUrl = '',
  });
}