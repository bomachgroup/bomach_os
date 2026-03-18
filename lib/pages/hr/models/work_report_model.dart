class WorkReportAttachment {
  final String fileUrl;

  WorkReportAttachment({required this.fileUrl});

  factory WorkReportAttachment.fromJson(Map<String, dynamic> json) {
    return WorkReportAttachment(fileUrl: json['file_url'] ?? '');
  }

  Map<String, dynamic> toJson() => {'file_url': fileUrl};
}

class WorkReport {
  final String id;
  final int employeeId;
  final DateTime? day;
  final double hoursWorked;
  final String? operationalBase;
  final String? workActivities;
  final String? taskDetails;
  final String? planNextDay;
  final String status;
  final String? feedback;
  final int? rating;
  final List<WorkReportAttachment> attachments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkReport({
    required this.id,
    required this.employeeId,
    this.day,
    required this.hoursWorked,
    this.operationalBase,
    this.workActivities,
    this.taskDetails,
    this.planNextDay,
    required this.status,
    this.feedback,
    this.rating,
    this.attachments = const [],
    this.createdAt,
    this.updatedAt,
  });

  factory WorkReport.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    final rawAttachments = json['attachments'];
    final attachmentsList = rawAttachments is List
        ? rawAttachments
            .map((a) =>
                WorkReportAttachment.fromJson(a as Map<String, dynamic>))
            .toList()
        : <WorkReportAttachment>[];

    return WorkReport(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id'] is int
          ? json['employee_id']
          : int.tryParse(json['employee_id']?.toString() ?? '0') ?? 0,
      day: json['day'] != null ? DateTime.tryParse(json['day']) : null,
      hoursWorked: parseDouble(json['hours_worked']),
      operationalBase: json['operational_base'],
      workActivities: json['work_activities'],
      taskDetails: json['task_details'],
      planNextDay: json['plan_next_day'],
      status: json['status'] ?? 'draft',
      feedback: json['feedback'],
      rating: json['rating'] is int
          ? json['rating']
          : int.tryParse(json['rating']?.toString() ?? '0'),
      attachments: attachmentsList,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  /// For POST /work-reports/ (create)
  Map<String, dynamic> toCreateJson() {
    return {
      'day': day?.toIso8601String().split('T').first,
      'hours_worked': hoursWorked,
      'operational_base': operationalBase,
      'work_activities': workActivities,
      'task_details': taskDetails,
      'plan_next_day': planNextDay,
      'status': status,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }

  /// For PUT /work-reports/{id} (update)
  Map<String, dynamic> toUpdateJson() {
    return {
      'day': day?.toIso8601String().split('T').first,
      'hours_worked': hoursWorked,
      'operational_base': operationalBase,
      'work_activities': workActivities,
      'task_details': taskDetails,
      'plan_next_day': planNextDay,
      'status': status,
      'feedback': feedback,
      'rating': rating,
      'attachments': attachments.map((a) => a.toJson()).toList(),
    };
  }
}
