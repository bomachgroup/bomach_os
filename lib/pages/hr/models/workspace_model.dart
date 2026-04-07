class WorkspaceConfig {
  final int? id;
  final double latitude;
  final double longitude;
  final String workspaceName;
  final int radiusMeters;
  final bool isVerified;
  final String? createdAt;
  final String? updatedAt;

  WorkspaceConfig({
    this.id,
    required this.latitude,
    required this.longitude,
    required this.workspaceName,
    required this.radiusMeters,
    this.isVerified = false,
    this.createdAt,
    this.updatedAt,
  });

  factory WorkspaceConfig.fromJson(Map<String, dynamic> json) {
    return WorkspaceConfig(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      latitude: (json['latitude'] is num)
          ? json['latitude'].toDouble()
          : double.tryParse(json['latitude']?.toString() ?? '') ?? 0.0,
      longitude: (json['longitude'] is num)
          ? json['longitude'].toDouble()
          : double.tryParse(json['longitude']?.toString() ?? '') ?? 0.0,
      workspaceName: json['name']?.toString() ?? json['workspace_name']?.toString() ?? '',
      radiusMeters: json['radius_meters'] is int
          ? json['radius_meters']
          : int.tryParse(json['radius_meters']?.toString() ?? '') ?? 100,
      isVerified: json['is_verified'] ?? false,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'name': workspaceName,
      'radius_meters': radiusMeters,
    };
  }
}
