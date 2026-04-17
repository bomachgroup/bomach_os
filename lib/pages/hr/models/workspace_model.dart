/// Flutter mirror of the backend `WorkLocationSchema`.
/// Endpoint: `GET /api/v1/biometric/location/whitelisted`
///
/// Backend field names:
///   id, name, location_type, latitude, longitude, allowed_radius_meters,
///   branch_name, is_verified, verified_by_name, verified_at, expires_at,
///   is_active, is_expired, can_be_used, notes, created_at
class WorkspaceConfig {
  final int? id;
  final String workspaceName; // → name
  final String locationType; // → location_type (e.g. "office", "remote")
  final double latitude;
  final double longitude;
  final int radiusMeters; // → allowed_radius_meters
  final String? branchName;
  final bool isVerified;
  final String? verifiedByName;
  final String? verifiedAt;
  final String? expiresAt;
  final bool isActive;
  final bool isExpired;
  final bool canBeUsed;
  final String notes;
  final String? createdAt;
  final String? updatedAt;

  WorkspaceConfig({
    this.id,
    required this.workspaceName,
    this.locationType = 'office',
    required this.latitude,
    required this.longitude,
    required this.radiusMeters,
    this.branchName,
    this.isVerified = false,
    this.verifiedByName,
    this.verifiedAt,
    this.expiresAt,
    this.isActive = true,
    this.isExpired = false,
    this.canBeUsed = true,
    this.notes = '',
    this.createdAt,
    this.updatedAt,
  });

  factory WorkspaceConfig.fromJson(Map<String, dynamic> json) {
    int parseInt(dynamic v, {int fallback = 100}) {
      if (v == null) return fallback;
      if (v is int) return v;
      return int.tryParse(v.toString()) ?? fallback;
    }

    double parseDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return WorkspaceConfig(
      id: json['id'] is int
          ? json['id']
          : int.tryParse(json['id']?.toString() ?? ''),
      workspaceName: json['name']?.toString() ??
          json['workspace_name']?.toString() ??
          '',
      locationType: json['location_type']?.toString() ?? 'office',
      latitude: parseDouble(json['latitude']),
      longitude: parseDouble(json['longitude']),
      radiusMeters: parseInt(
        json['allowed_radius_meters'] ?? json['radius_meters'],
      ),
      branchName: json['branch_name']?.toString(),
      isVerified: json['is_verified'] == true,
      verifiedByName: json['verified_by_name']?.toString(),
      verifiedAt: json['verified_at']?.toString(),
      expiresAt: json['expires_at']?.toString(),
      isActive: json['is_active'] != false, // default true
      isExpired: json['is_expired'] == true,
      canBeUsed: json['can_be_used'] != false, // default true
      notes: json['notes']?.toString() ?? '',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  /// Payload for `POST /biometric/location/whitelisted`.
  /// Only emits fields the create endpoint accepts.
  Map<String, dynamic> toCreateJson() => {
        'name': workspaceName,
        'location_type': locationType,
        'latitude': latitude,
        'longitude': longitude,
        'allowed_radius_meters': radiusMeters,
        if (notes.isNotEmpty) 'notes': notes,
      };
}
