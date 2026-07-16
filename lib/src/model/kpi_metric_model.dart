class KPIMetric {
  final int id;
  final String name;
  final String description;
  final String unit;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const KPIMetric({
    required this.id,
    required this.name,
    required this.description,
    required this.unit,
    this.createdAt,
    this.updatedAt,
  });

  factory KPIMetric.fromJson(Map<String, dynamic> json) => KPIMetric(
    id: json['id'] is int ? json['id'] : int.tryParse(json['id']?.toString() ?? '0') ?? 0,
    name: json['name'] ?? '',
    description: json['description'] ?? '',
    unit: json['unit'] ?? 'percentage',
    createdAt: json['created_at'] != null ? DateTime.tryParse(json['created_at']) : null,
    updatedAt: json['updated_at'] != null ? DateTime.tryParse(json['updated_at']) : null,
  );

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'unit': unit,
  };
}
