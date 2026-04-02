class Award {
  final String id;
  final String title;
  final String category; // e.g., "Employee of the Month"
  final DateTime? dateAwarded;
  final String rankLevel; // e.g., "Gold", "Silver", "1"
  final String description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  Award({
    required this.id,
    required this.title,
    required this.category,
    this.dateAwarded,
    required this.rankLevel,
    required this.description,
    this.createdAt,
    this.updatedAt,
  });

  factory Award.fromJson(Map<String, dynamic> json) {
    return Award(
      id: json['id']?.toString() ?? '',
      title: json['title'] ?? '',
      category: json['category'] ?? '',
      dateAwarded: json['date_awarded'] != null
          ? DateTime.tryParse(json['date_awarded'])
          : null,
      rankLevel: json['rank_level']?.toString() ?? '',
      description: json['description'] ?? '',
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
      'title': title,
      'category': category,
      'date_awarded':
          dateAwarded?.toIso8601String().split('T').first, // Format YYYY-MM-DD
      'rank_level': rankLevel,
      'description': description,
    };
  }
}
