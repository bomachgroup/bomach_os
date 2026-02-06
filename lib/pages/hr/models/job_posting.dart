class JobPosting {
  final String id;
  final String title;
  final String description;
  final String branchId;
  final String departmentId;
  final String jobType; // e.g., 'full_time', 'contract'
  final String status; // e.g., 'published', 'draft'
  final bool isActive;
  final String? requirements;
  final double? salaryRangeMin;
  final double? salaryRangeMax;
  final DateTime? postingDate;
  final DateTime? closingDate;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  JobPosting({
    required this.id,
    required this.title,
    required this.description,
    required this.branchId,
    required this.departmentId,
    required this.jobType,
    required this.status,
    required this.isActive,
    this.requirements,
    this.salaryRangeMin,
    this.salaryRangeMax,
    this.postingDate,
    this.closingDate,
    this.createdAt,
    this.updatedAt,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      branchId: json['branch_id'] ?? '',
      departmentId: json['department_id'] ?? '',
      jobType: json['job_type'] ?? '',
      status: json['status'] ?? '',
      isActive: json['is_active'] ?? false,
      requirements: json['requirements'],
      // Handle numbers safely as they might come as int or double
      salaryRangeMin: (json['salary_range_min'] as num?)?.toDouble(),
      salaryRangeMax: (json['salary_range_max'] as num?)?.toDouble(),
      postingDate: json['posting_date'] != null ? DateTime.tryParse(json['posting_date']) : null,
      closingDate: json['closing_date'] != null ? DateTime.tryParse(json['closing_date']) : null,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'branch_id': branchId,
      'department_id': departmentId,
      'job_type': jobType,
      'status': status,
      'is_active': isActive,
      'requirements': requirements,
      'salary_range_min': salaryRangeMin,
      'salary_range_max': salaryRangeMax,
      'posting_date': postingDate?.toIso8601String(),
      'closing_date': closingDate?.toIso8601String(),
    };
  }
}