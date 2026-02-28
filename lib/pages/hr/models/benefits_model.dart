class BenefitRecord {
  final String id;
  final String employeeName;
  final String employeeId;
  final String employeeRole;
  final String imageUrl; // For avatar
  final List<String> activeBenefits;
  final DateTime startDate;
  final String status; // 'Approved', 'Rejected', 'Pending'

  BenefitRecord({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    required this.employeeRole,
    this.imageUrl = '',
    required this.activeBenefits,
    required this.startDate,
    required this.status,
  });
}