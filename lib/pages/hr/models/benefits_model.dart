import 'payroll_model.dart';

class BenefitRecord {
  final String id;
  final String employeeName;
  final String employeeId;
  final String employeeRole;
  final String imageUrl;
  final List<String> activeBenefits;
  final DateTime startDate;
  final String status;
  final double grossSalary;
  final double netSalary;
  final double totalAllowances;
  final double totalDeductions;

  BenefitRecord({
    required this.id,
    required this.employeeName,
    required this.employeeId,
    this.employeeRole = '',
    this.imageUrl = '',
    required this.activeBenefits,
    required this.startDate,
    required this.status,
    this.grossSalary = 0.0,
    this.netSalary = 0.0,
    this.totalAllowances = 0.0,
    this.totalDeductions = 0.0,
  });

  /// Construct a BenefitRecord from a Payroll model instance.
  /// The payroll additions map keys are treated as active benefit names.
  factory BenefitRecord.fromPayroll(Payroll payroll) {
    // Extract benefit names from the additions/allowances map
    final benefits = <String>[];
    if (payroll.additions != null) {
      benefits
          .addAll(payroll.additions!.keys.map((k) => _formatBenefitName(k)));
    }

    return BenefitRecord(
      id: payroll.id,
      employeeName: '', // Will be populated from employee data if available
      employeeId: payroll.employeeId,
      activeBenefits: benefits,
      startDate: payroll.createdAt ?? DateTime.now(),
      status: payroll.status,
      grossSalary: payroll.grossSalary,
      netSalary: payroll.netSalary,
      totalAllowances: payroll.totalAllowances,
      totalDeductions: payroll.totalDeductions,
    );
  }

  /// Convert snake_case key to Title Case display name.
  static String _formatBenefitName(String key) {
    return key
        .split('_')
        .map((word) => word.isNotEmpty
            ? '${word[0].toUpperCase()}${word.substring(1)}'
            : '')
        .join(' ');
  }
}
