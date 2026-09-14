/// Result returned by `GET /biometric/location/verify`.
class LocationVerificationResult {
  final bool isAllowed;
  final double? distanceMeters;
  final String? locationName;
  final double? effectiveRadiusMeters;
  final String? hint;

  const LocationVerificationResult({
    required this.isAllowed,
    this.distanceMeters,
    this.locationName,
    this.effectiveRadiusMeters,
    this.hint,
  });

  factory LocationVerificationResult.fromJson(Map<String, dynamic> json) {
    double? parseDouble(dynamic v) {
      if (v == null) return null;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString());
    }

    return LocationVerificationResult(
      isAllowed: json['is_valid'] == true || json['location_verified'] == true,
      distanceMeters: parseDouble(json['distance_meters']) ??
          parseDouble(json['nearest_distance_meters']),
      locationName: json['location_name']?.toString() ??
          json['nearest_location']?.toString(),
      effectiveRadiusMeters: parseDouble(json['effective_radius_meters']),
      hint: json['hint']?.toString(),
    );
  }
}
