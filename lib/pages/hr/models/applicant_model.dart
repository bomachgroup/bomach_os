class Applicant {
  final String id;
  final String jobPostingId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? linkedinUrl;
  final String? portfolioUrl;
  final String? resumeUrl;
  final String? coverLetter;
  final String? notes;

  /// Status: ["applied", "shortlisted", "interviewed", "offered", "hired", "rejected"]
  final String status;

  /// Stage: ["applied", "screening", "interview", "offered", "rejected"]
  final String stage;
  final double rating;
  final DateTime? createdAt;

  Applicant({
    required this.id,
    required this.jobPostingId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.linkedinUrl,
    this.portfolioUrl,
    this.resumeUrl,
    this.coverLetter,
    this.notes,
    required this.status,
    required this.stage,
    this.rating = 0.0,
    this.createdAt,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    String parseJobId(dynamic val) {
      if (val is int) return val.toString();
      if (val is String) return val;
      if (val is Map && val.containsKey('id')) return val['id'].toString();
      return '';
    }

    double parseRating(dynamic val) {
      if (val is num) return val.toDouble();
      if (val is String) return double.tryParse(val) ?? 0.0;
      return 0.0;
    }

    return Applicant(
      id: json['id']?.toString() ?? '',
      jobPostingId: parseJobId(json['job_posting_id'] ?? json['job_posting']),
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      linkedinUrl: json['linkedin_url'],
      portfolioUrl: json['portolio_url'] ?? json['portfolio_url'],
      resumeUrl: json['resume'],
      coverLetter: json['cover_letter'],
      notes: json['notes'],
      status: json['status'] ?? 'new',
      stage: json['stage'] ?? '',
      rating: parseRating(json['rating']),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_posting_id': int.tryParse(jobPostingId) ?? 0,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'linkedin_url': linkedinUrl,
      'portolio_url': portfolioUrl,
      'resume': resumeUrl,
      'cover_letter': coverLetter,
      'notes': notes,
      'status': status,
    };
  }
}
