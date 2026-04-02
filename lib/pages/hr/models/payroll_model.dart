class Payroll {
  final String id;
  final String employeeId;
  final String payrollPeriod; // e.g., "2024-01"
  final String status; // e.g., "pending", "paid"
  final double grossSalary;
  final double netSalary;
  final double totalDeductions;
  final double totalAllowances;
  final DateTime? disbursementDate;
  final Map<String, dynamic>? deductions; // JSON object
  final Map<String, dynamic>? additions; // JSON object
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Payroll({
    required this.id,
    required this.employeeId,
    required this.payrollPeriod,
    required this.status,
    required this.grossSalary,
    required this.netSalary,
    required this.totalDeductions,
    required this.totalAllowances,
    this.disbursementDate,
    this.deductions,
    this.additions,
    this.createdAt,
    this.updatedAt,
  });

  factory Payroll.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse doubles from String or Number
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return Payroll(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      payrollPeriod: json['payroll_period'] ?? '',
      status: json['status'] ?? 'pending',
      grossSalary: parseDouble(json['gross_salary']),
      netSalary: parseDouble(json['net_salary']),
      totalDeductions: parseDouble(json['total_deductions']),
      totalAllowances: parseDouble(json['total_allowances']),
      disbursementDate: json['disbursement_date'] != null
          ? DateTime.tryParse(json['disbursement_date'])
          : null,
      deductions: json['deductions'],
      additions: json['additions'], // Map<String, dynamic>
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
      'employee_id': employeeId,
      'payroll_period': payrollPeriod,
      'status': status,
      'gross_salary': grossSalary,
      'net_salary': netSalary,
      'total_deductions': totalDeductions,
      'total_allowances': totalAllowances,
      'disbursement_date': disbursementDate?.toIso8601String().split('T').first,
      'deductions': deductions,
      'additions': additions,
    };
  }
}
