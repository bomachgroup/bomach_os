import 'dart:async';
import 'dart:developer';
import 'dart:js_interop';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:web/web.dart' as web;

class LocationService {
  static final LocationService _instance = LocationService._internal();

  factory LocationService() => _instance;

  LocationService._internal();

  Future<bool> ensurePermission() async {
    if (kIsWeb) {
      try {
        // Just verify geolocation is available in the navigator
        // ignore: unnecessary_null_comparison
        return web.window.navigator.geolocation != null;
      } catch (e) {
        return false;
      }
    }

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
    if (kIsWeb) {
      final completer = Completer<Position>();
      try {
        web.window.navigator.geolocation.getCurrentPosition(
          (web.GeolocationPosition pos) {
            final coords = pos.coords;
            completer.complete(Position(
              longitude: coords.longitude.toDouble(),
              latitude: coords.latitude.toDouble(),
              timestamp: DateTime.now(),
              accuracy: coords.accuracy.toDouble(),
              altitude: coords.altitude?.toDouble() ?? 0.0,
              altitudeAccuracy: 0,
              heading: coords.heading?.toDouble() ?? 0.0,
              headingAccuracy: 0,
              speed: coords.speed?.toDouble() ?? 0.0,
              speedAccuracy: 0,
            ));
          }.toJS,
          (web.GeolocationPositionError err) {
            completer.completeError(
              Exception("Geolocation error: ${err.message}"),
            );
          }.toJS,
        );
        return await completer.future;
      } catch (e) {
        throw Exception(
            "Geolocation is not supported by this browser. Error: $e");
      }
    }
    return await Geolocator.getCurrentPosition();
  }

  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000.0; // meters
    final double dLat = _degreesToRadians(lat2 - lat1);
    final double dLon = _degreesToRadians(lon2 - lon1);

    final double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_degreesToRadians(lat1)) *
            math.cos(_degreesToRadians(lat2)) *
            math.sin(dLon / 2) *
            math.sin(dLon / 2);

    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  double _degreesToRadians(double degrees) {
    return degrees * math.pi / 180;
  }

  bool isWithinRadius(
    Position current,
    double targetLat,
    double targetLng,
    int radiusMeters,
  ) {
    final distance = _calculateDistance(
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
    return _calculateDistance(
      current.latitude,
      current.longitude,
      targetLat,
      targetLng,
    );
  }
}
