class WorkReport {
  final String id;
  final String employeeId;
  final DateTime? day; // The specific date of the report
  final double hoursWorked;
  final String mood; // e.g., "Good", "Neutral", "Bad"
  final String? challenges;
  final String? achievements;
  final String? planNextDay;
  final String status; // e.g., "draft", "submitted"
  final String? feedback; // Manager feedback
  final int rating;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  WorkReport({
    required this.id,
    required this.employeeId,
    this.day,
    required this.hoursWorked,
    required this.mood,
    this.challenges,
    this.achievements,
    this.planNextDay,
    required this.status,
    this.feedback,
    required this.rating,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkReport.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse doubles
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return WorkReport(
      id: json['id']?.toString() ?? '',
      employeeId: json['employee_id']?.toString() ?? '',
      day: json['day'] != null ? DateTime.tryParse(json['day']) : null,
      hoursWorked: parseDouble(json['hours_worked']),
      mood: json['mood'] ?? '',
      challenges: json['challenges'],
      achievements: json['achievements'],
      planNextDay: json['plan_next_day'],
      status: json['status'] ?? 'draft',
      feedback: json['feedback'],
      rating: json['rating'] is int 
          ? json['rating'] 
          : int.tryParse(json['rating']?.toString() ?? '0') ?? 0,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'employee_id': employeeId,
      'day': day?.toIso8601String().split('T').first, // Format YYYY-MM-DD
      'hours_worked': hoursWorked,
      'mood': mood,
      'challenges': challenges,
      'achievements': achievements,
      'plan_next_day': planNextDay,
      'status': status,
      'feedback': feedback,
      'rating': rating,
    };
  }
}