/// Result returned by `GET /biometric/location/verify`.
class LocationVerificationResult {
  final bool isAllowed;
  final double? distanceMeters;
  final String? locationName;

  const LocationVerificationResult({
    required this.isAllowed,
    this.distanceMeters,
    this.locationName,
  });

  factory LocationVerificationResult.fromJson(Map<String, dynamic> json) {
    final distance = json['distance_meters'];
    return LocationVerificationResult(
      isAllowed: json['is_valid'] == true || json['location_verified'] == true,
      distanceMeters: distance is num
          ? distance.toDouble()
          : double.tryParse(distance?.toString() ?? ''),
      locationName: json['location_name']?.toString(),
    );
  }
}
