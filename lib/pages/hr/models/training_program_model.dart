class TrainingProgram {
  final String id;
  final String programName;
  final String provider;
  final String description;
  final DateTime? startDate;
  final DateTime? endDate;
  final double cost;
  final String targetAudience; // e.g., "Managers", "All Staff"
  final int durationDays;
  final String status; // e.g., "scheduled", "completed"
  final bool isMandatory;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TrainingProgram({
    required this.id,
    required this.programName,
    required this.provider,
    required this.description,
    this.startDate,
    this.endDate,
    required this.cost,
    required this.targetAudience,
    required this.durationDays,
    required this.status,
    required this.isMandatory,
    this.createdAt,
    this.updatedAt,
  });

  factory TrainingProgram.fromJson(Map<String, dynamic> json) {
    // Helper to safely parse doubles
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return TrainingProgram(
      id: json['id']?.toString() ?? '',
      programName: json['program_name'] ?? '',
      provider: json['provider'] ?? '',
      description: json['description'] ?? '',
      startDate: json['start_date'] != null ? DateTime.tryParse(json['start_date']) : null,
      endDate: json['end_date'] != null ? DateTime.tryParse(json['end_date']) : null,
      cost: parseDouble(json['cost']),
      targetAudience: json['target_audience'] ?? '',
      durationDays: json['duration_days'] is int 
          ? json['duration_days'] 
          : int.tryParse(json['duration_days']?.toString() ?? '0') ?? 0,
      status: json['status'] ?? 'scheduled',
      isMandatory: json['is_mandatory'] ?? false,
      createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
      updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'program_name': programName,
      'provider': provider,
      'description': description,
      'start_date': startDate?.toIso8601String().split('T').first,
      'end_date': endDate?.toIso8601String().split('T').first,
      'cost': cost,
      'target_audience': targetAudience,
      'duration_days': durationDays,
      'status': status,
      'is_mandatory': isMandatory,
    };
  }
}