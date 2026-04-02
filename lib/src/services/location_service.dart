import 'dart:developer';

import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  Future<bool> ensurePermission() async {
    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return false;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return false;
      }
      if (permission == LocationPermission.deniedForever) return false;

      return true;
    } catch (e) {
      log('Location permission error: $e');
      return false;
    }
  }

  Future<Position> getCurrentPosition() async {
    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        timeLimit: Duration(seconds: 10),
      ),
    );
  }

  bool isWithinRadius(
    Position current,
    double targetLat,
    double targetLng,
    int radiusMeters,
  ) {
    final distance = Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      targetLat,
      targetLng,
    );
    return distance <= radiusMeters;
  }

  double getDistance(
    Position current,
    double targetLat,
    double targetLng,
  ) {
    return Geolocator.distanceBetween(
      current.latitude,
      current.longitude,
      targetLat,
      targetLng,
    );
  }
}
