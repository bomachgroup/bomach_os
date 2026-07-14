class RoleReport {
  final int? id;
  final int roleId;
  final String roleName;
  final String reportName;
  final String? description;
  final String reportType; // daily | weekly | monthly | quarterly | annual | project | incident
  final String format; // pdf | excel | csv | web
  final String frequency; // how often to produce
  final List<String> recipients;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const RoleReport({
    this.id,
    required this.roleId,
    this.roleName = '',
    required this.reportName,
    this.description,
    this.reportType = 'monthly',
    this.format = 'pdf',
    this.frequency = 'monthly',
    this.recipients = const [],
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory RoleReport.fromJson(Map<String, dynamic> json) {
    final rawRecipients = json['recipients'];
    final recipientsList = rawRecipients is List
        ? List<String>.from(rawRecipients)
        : <String>[];

    return RoleReport(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      roleId: json['role_id'] is int
          ? json['role_id']
          : int.tryParse(json['role_id']?.toString() ?? '0') ?? 0,
      roleName: json['role_name'] ?? '',
      reportName: json['report_name'] ?? '',
      description: json['description'],
      reportType: json['report_type'] ?? 'monthly',
      format: json['format'] ?? 'pdf',
      frequency: json['frequency'] ?? 'monthly',
      recipients: recipientsList,
      isActive: json['is_active'] ?? true,
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
      'role_id': roleId,
      'report_name': reportName,
      'description': description,
      'report_type': reportType,
      'format': format,
      'frequency': frequency,
      'recipients': recipients,
      'is_active': isActive,
    };
  }

  RoleReport copyWith({
    int? id,
    int? roleId,
    String? roleName,
    String? reportName,
    String? description,
    String? reportType,
    String? format,
    String? frequency,
    List<String>? recipients,
    bool? isActive,
  }) {
    return RoleReport(
      id: id ?? this.id,
      roleId: roleId ?? this.roleId,
      roleName: roleName ?? this.roleName,
      reportName: reportName ?? this.reportName,
      description: description ?? this.description,
      reportType: reportType ?? this.reportType,
      format: format ?? this.format,
      frequency: frequency ?? this.frequency,
      recipients: recipients ?? this.recipients,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  static const List<String> reportTypeOptions = [
    'daily',
    'weekly',
    'monthly',
    'quarterly',
    'annual',
    'project',
    'incident',
  ];

  static const List<String> formatOptions = [
    'pdf',
    'excel',
    'csv',
    'web',
  ];
}
