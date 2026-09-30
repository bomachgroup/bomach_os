class ExpenseDepartment {
  final int id;
  final String name;

  ExpenseDepartment({
    required this.id,
    required this.name,
  });

  factory ExpenseDepartment.fromJson(Map<String, dynamic> json) {
    return ExpenseDepartment(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class Expense {
  final int id;
  final int userId;
  final ExpenseDepartment department;
  final String date;
  final String description;
  final String amount;
  final String category;
  final String status;
  final String? attachment;
  final String createdAt;
  final String updatedAt;
  final int? surveyExpenseLineId;
  final int? surveyReportVersion;

  Expense({
    required this.id,
    required this.userId,
    required this.department,
    required this.date,
    required this.description,
    required this.amount,
    required this.category,
    required this.status,
    this.attachment,
    required this.createdAt,
    required this.updatedAt,
    this.surveyExpenseLineId,
    this.surveyReportVersion,
  });

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      department: json['department'] != null
          ? ExpenseDepartment.fromJson(json['department'])
          : ExpenseDepartment(id: 0, name: ''),
      date: json['date'] ?? '',
      description: json['description'] ?? '',
      amount: json['amount']?.toString() ?? '0.00',
      category: json['category'] ?? '',
      status: json['status'] ?? '',
      attachment: json['attachment'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      surveyExpenseLineId:
          int.tryParse(json['survey_expense_line_id']?.toString() ?? ''),
      surveyReportVersion:
          int.tryParse(json['survey_report_version']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'department_id': department.id,
      'date': date,
      'description': description,
      'amount': amount,
      'category': category,
      'status': status,
      'attachment': attachment,
    };
  }
}
