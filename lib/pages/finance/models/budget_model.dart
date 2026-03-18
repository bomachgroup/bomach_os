class Budget {
  final int id;
  final String branchName;
  final String departmentName;
  final String fiscalPeriod;
  final String amount;
  final String currentSpend;
  final String remainingBudget;

  Budget({
    required this.id,
    required this.branchName,
    required this.departmentName,
    required this.fiscalPeriod,
    required this.amount,
    required this.currentSpend,
    required this.remainingBudget,
  });

  factory Budget.fromJson(Map<String, dynamic> json) {
    return Budget(
      id: json['id'] ?? 0,
      branchName: json['branch_name'] ?? '',
      departmentName: json['department_name'] ?? '',
      fiscalPeriod: json['fiscal_period'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      currentSpend: json['current_spend']?.toString() ?? '0.00',
      remainingBudget: json['remaining_budget']?.toString() ?? '0.00',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_name': branchName,
      'department_name': departmentName,
      'fiscal_period': fiscalPeriod,
      'amount': amount,
    };
  }

  /// Create payload for POST/PUT (uses IDs instead of names)
  static Map<String, dynamic> createPayload({
    required int branchId,
    required int departmentId,
    required String fiscalPeriod,
    required String amount,
  }) {
    return {
      'branch_id': branchId,
      'department_id': departmentId,
      'fiscal_period': fiscalPeriod,
      'amount': amount,
    };
  }
}
