class JobPosting {
  final String id;
  final String title;
  final String departmentId; 
  final String branchId;
  final String jobType;
  final String status;
  final String description;
  final String requirements;
  final String responsibilities;
  final String salaryRange; 
  final DateTime? deadline; 
  final bool isActive; 
  final int applicantsCount;
  final DateTime? createdAt;

  JobPosting({
    required this.id,
    required this.title,
    required this.departmentId,
    required this.branchId,
    required this.jobType,
    required this.status,
    required this.description,
    required this.requirements,
    required this.responsibilities,
    required this.salaryRange,
    this.deadline,
    this.isActive = true,
    this.applicantsCount = 0,
    this.createdAt,
  });

  factory JobPosting.fromJson(Map<String, dynamic> json) {
    return JobPosting(
      id: json['id']?.toString() ?? '',
      title: json['job_title'] ?? '',
      departmentId: json['department_id']?.toString() ?? '',
      branchId: json['branch_id']?.toString() ?? '',
      jobType: json['job_type'] ?? '',
      status: json['status'] ?? '',
      description: json['description'] ?? '',
      requirements: json['requirements'] ?? '',
      responsibilities: json['responsibilities'] ?? '',
      salaryRange: json['salary_range'] ?? '',
      deadline: json['deadline'] != null ? DateTime.tryParse(json['deadline']) : null,
      isActive: json['is_active'] ?? true,
      applicantsCount: json['applicants_count'] is int 
          ? json['applicants_count'] 
          : int.tryParse(json['applicants_count']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_title': title,
      'department_id': departmentId,
      'branch_id': branchId,
      'job_type': jobType,
      'status': status,
      'description': description,
      'requirements': requirements,
      'responsibilities': responsibilities,
      'salary_range': salaryRange,
      'deadline': deadline?.toIso8601String(),
      'is_active': isActive,
    };
  }
}