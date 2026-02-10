class PerformanceReview {
  final String? id;
  final String employeeId;
  final String reviewerId;
  final DateTime? reviewDate;
  final String reviewPeriod; // e.g., "2024-Q1"
  final int overallRating;
  final String? strengths;
  final String? areasForImprovement;
  final String? feedback;
  final String? employeeComments;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PerformanceReview({
    this.id,
    required this.employeeId,
    required this.reviewerId,
    this.reviewDate,
    required this.reviewPeriod,
    required this.overallRating,
    this.strengths,
    this.areasForImprovement,
    this.feedback,
    this.employeeComments,
    this.createdAt,
    this.updatedAt,
  });

  factory PerformanceReview.fromJson(Map<String, dynamic> json) {
    return PerformanceReview(
      id: json['id']?.toString(),
      employeeId: json['employee_id']?.toString() ?? '',
      reviewerId: json['reviewer_id']?.toString() ?? '',
      reviewDate: json['review_date'] != null
          ? DateTime.tryParse(json['review_date'])
          : null,
      reviewPeriod: json['review_period'] ?? '',
      overallRating: json['overall_rating'] is int
          ? json['overall_rating']
          : int.tryParse(json['overall_rating']?.toString() ?? '0') ?? 0,
      strengths: json['strengths'],
      areasForImprovement: json['areas_for_improvement'],
      feedback: json['feedback'],
      employeeComments: json['employee_comments'],
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
      'reviewer_id': reviewerId,
      'review_date':
          reviewDate?.toIso8601String().split('T').first, // Format YYYY-MM-DD
      'review_period': reviewPeriod,
      'overall_rating': overallRating,
      'strengths': strengths,
      'areas_for_improvement': areasForImprovement,
      'feedback': feedback,
      'employee_comments': employeeComments,
    };
  }
}
