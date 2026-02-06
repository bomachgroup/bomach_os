class Applicant {
  final String id;
  final String jobPostingId;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? resumeUrl;
  final String? coverLetter;
  final String? portfolioUrl;
  final String? linkedinUrl;
  final String stage; // e.g., 'applied', 'interview'
  final String status; // e.g., 'active', 'rejected'
  final int rating;
  final DateTime? appliedAt;
  final DateTime? updatedAt;

  Applicant({
    required this.id,
    required this.jobPostingId,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.resumeUrl,
    this.coverLetter,
    this.portfolioUrl,
    this.linkedinUrl,
    required this.stage,
    required this.status,
    required this.rating,
    this.appliedAt,
    this.updatedAt,
  });

  factory Applicant.fromJson(Map<String, dynamic> json) {
    return Applicant(
      id: json['id'] ?? '',
      jobPostingId: json['job_posting_id'] ?? '',
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      resumeUrl: json['resume_url'],
      coverLetter: json['cover_letter'],
      portfolioUrl: json['portfolio_url'],
      linkedinUrl: json['linkedin_url'],
      stage: json['stage'] ?? 'applied',
      status: json['status'] ?? 'active',
      rating: json['rating'] ?? 0,
      appliedAt: json['applied_at'] != null ? DateTime.tryParse(json['applied_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'job_posting_id': jobPostingId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'resume_url': resumeUrl,
      'cover_letter': coverLetter,
      'portfolio_url': portfolioUrl,
      'linkedin_url': linkedinUrl,
      'stage': stage,
      'status': status,
      'rating': rating,
    };
  }
}