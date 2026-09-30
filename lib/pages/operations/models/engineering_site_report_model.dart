const engineeringActivityTypes = <String>{
  'concrete_work',
  'carpentry_work',
  'water_supply',
};

const engineeringExpenseCategories = <String>{'labour', 'material_equipment'};

bool isValidEngineeringAttachmentUrl(String value) {
  final uri = Uri.tryParse(value.trim());
  return uri != null &&
      uri.hasAuthority &&
      (uri.scheme == 'https' || uri.scheme == 'http');
}

bool hasValidEngineeringActivity(List<EngineeringReportActivity> activities) =>
    activities.any((activity) =>
        engineeringActivityTypes.contains(activity.activityType) &&
        activity.description.trim().isNotEmpty);

class EngineeringReportActivity {
  const EngineeringReportActivity({
    required this.activityType,
    required this.description,
  });

  final String activityType;
  final String description;

  factory EngineeringReportActivity.fromJson(Map<String, dynamic> json) =>
      EngineeringReportActivity(
        activityType: json['activity_type']?.toString() ?? '',
        description: json['description']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'activity_type': activityType,
        'description': description,
      };
}

class EngineeringReportExpense {
  const EngineeringReportExpense({
    required this.expenseCategory,
    required this.name,
    required this.amount,
    required this.description,
  });

  final String expenseCategory;
  final String name;
  final String amount;
  final String description;

  factory EngineeringReportExpense.fromJson(Map<String, dynamic> json) =>
      EngineeringReportExpense(
        expenseCategory: json['expense_category']?.toString() ?? '',
        name: json['name']?.toString() ?? '',
        amount: json['amount']?.toString() ?? '0.00',
        description: json['description']?.toString() ?? '',
      );

  Map<String, dynamic> toJson() => {
        'expense_category': expenseCategory,
        'name': name,
        'amount': amount,
        'description': description,
      };
}

class EngineeringReportMaterial {
  const EngineeringReportMaterial({
    required this.equipmentId,
    required this.quantityUsed,
    this.name = '',
    this.unit = '',
  });

  final int equipmentId;
  final String quantityUsed;
  final String name;
  final String unit;

  factory EngineeringReportMaterial.fromJson(Map<String, dynamic> json) =>
      EngineeringReportMaterial(
        equipmentId: int.tryParse(json['equipment_id']?.toString() ?? '') ?? 0,
        quantityUsed: json['quantity_used']?.toString() ?? '0.000',
        name: json['name']?.toString() ?? '',
        unit: json['unit']?.toString() ?? json['unit_value']?.toString() ?? '',
      );

  /// The server snapshots the inventory name and unit. Only these two fields
  /// are accepted for report material usage.
  Map<String, dynamic> toJson() => {
        'equipment_id': equipmentId,
        'quantity_used': quantityUsed,
      };
}

class EngineeringSiteReport {
  const EngineeringSiteReport({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.status,
    required this.worksiteId,
    required this.worksiteName,
    required this.date,
    required this.tomorrowActivities,
    required this.commentsSuggestions,
    required this.submissionVersion,
    required this.activities,
    required this.expenses,
    required this.materialsUsed,
    required this.attachments,
    required this.createdAt,
    required this.updatedAt,
    this.projectId,
    this.taskId,
    this.rating,
    this.reviewedById,
    this.reviewedAt,
  });

  final int id;
  final int employeeId;
  final String employeeName;
  final String status;
  final int? rating;
  final int? reviewedById;
  final String? reviewedAt;
  final int worksiteId;
  final String worksiteName;
  final int? projectId;
  final int? taskId;
  final String date;
  final String tomorrowActivities;
  final String commentsSuggestions;
  final int submissionVersion;
  final List<EngineeringReportActivity> activities;
  final List<EngineeringReportExpense> expenses;
  final List<EngineeringReportMaterial> materialsUsed;
  final List<String> attachments;
  final String createdAt;
  final String updatedAt;

  factory EngineeringSiteReport.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] is Map
        ? Map<String, dynamic>.from(json['payload'] as Map)
        : json;
    final activityRows = payload['activities'] is List
        ? payload['activities'] as List
        : const [];
    final expenseRows =
        payload['expenses'] is List ? payload['expenses'] as List : const [];
    final materialRows = payload['materials_used'] is List
        ? payload['materials_used'] as List
        : const [];
    final attachmentRows = payload['attachments'] is List
        ? payload['attachments'] as List
        : const [];

    return EngineeringSiteReport(
      id: _intValue(json['id']),
      employeeId: _intValue(json['employee_id']),
      employeeName: json['employee_name']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
      rating: _optionalInt(json['rating']),
      reviewedById: _optionalInt(json['reviewed_by_id']),
      reviewedAt: json['reviewed_at']?.toString(),
      worksiteId: _intValue(payload['worksite_id']),
      worksiteName: payload['worksite_name']?.toString() ??
          json['worksite_name']?.toString() ??
          '',
      projectId: _optionalInt(payload['project_id']),
      taskId: _optionalInt(payload['task_id']),
      date: payload['date']?.toString() ?? '',
      tomorrowActivities: payload['tomorrow_activities']?.toString() ?? '',
      commentsSuggestions: payload['comments_suggestions']?.toString() ?? '',
      submissionVersion: _intValue(payload['submission_version']),
      activities: activityRows
          .whereType<Map>()
          .map((row) => EngineeringReportActivity.fromJson(
                Map<String, dynamic>.from(row),
              ))
          .toList(growable: false),
      expenses: expenseRows
          .whereType<Map>()
          .map((row) => EngineeringReportExpense.fromJson(
                Map<String, dynamic>.from(row),
              ))
          .toList(growable: false),
      materialsUsed: materialRows
          .whereType<Map>()
          .map((row) => EngineeringReportMaterial.fromJson(
                Map<String, dynamic>.from(row),
              ))
          .toList(growable: false),
      attachments: attachmentRows.map((row) => row.toString()).toList(),
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'worksite_id': worksiteId,
        if (projectId != null) 'project_id': projectId,
        if (taskId != null) 'task_id': taskId,
        'date': date,
        'tomorrow_activities': tomorrowActivities,
        'comments_suggestions': commentsSuggestions,
        'activities': activities.map((item) => item.toJson()).toList(),
        'expenses': expenses.map((item) => item.toJson()).toList(),
        'materials_used': materialsUsed.map((item) => item.toJson()).toList(),
        'attachments': attachments,
      };

  static int _intValue(dynamic value) =>
      int.tryParse(value?.toString() ?? '') ?? 0;

  static int? _optionalInt(dynamic value) =>
      value == null ? null : int.tryParse(value.toString());
}

class UnifiedReportSummary {
  const UnifiedReportSummary({
    required this.id,
    required this.reportType,
    required this.status,
    required this.employeeId,
    required this.employeeName,
    required this.summary,
    required this.createdAt,
    required this.updatedAt,
    this.reviewedById,
    this.reviewedAt,
    this.rating,
    this.payload = const {},
  });

  final int id;
  final String reportType;
  final String status;
  final int employeeId;
  final String employeeName;
  final int? reviewedById;
  final String? reviewedAt;
  final int? rating;
  final String summary;
  final String createdAt;
  final String updatedAt;
  final Map<String, dynamic> payload;

  factory UnifiedReportSummary.fromJson(Map<String, dynamic> json) =>
      UnifiedReportSummary(
        id: int.tryParse(json['id']?.toString() ?? '') ?? 0,
        reportType: json['report_type']?.toString() ?? '',
        status: json['status']?.toString() ?? '',
        employeeId: int.tryParse(json['employee_id']?.toString() ?? '') ?? 0,
        employeeName: json['employee_name']?.toString() ?? '',
        reviewedById: json['reviewed_by_id'] == null
            ? null
            : int.tryParse(json['reviewed_by_id'].toString()),
        reviewedAt: json['reviewed_at']?.toString(),
        rating: json['rating'] == null
            ? null
            : int.tryParse(json['rating'].toString()),
        summary: json['summary']?.toString() ?? '',
        createdAt: json['created_at']?.toString() ?? '',
        updatedAt: json['updated_at']?.toString() ?? '',
        payload: json['payload'] is Map
            ? Map<String, dynamic>.from(json['payload'] as Map)
            : const {},
      );
}
