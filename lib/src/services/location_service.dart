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

  /// Mirrors backend `MIN_EFFECTIVE_RADIUS_METERS`. Single source of truth
  /// for the client-side soft check so both sides agree.
  static const int minEffectiveRadiusMeters = 25;

  /// Client hard-blocks before backend only when clearly far (saves the
  /// face-capture step). Anything closer goes to backend as authoritative.
  static const double farBlockThresholdMeters = 200;

  /// Frontend accuracy gates (frontend owns accuracy, backend is floor-only).
  static const double clockInTargetAccuracy = 25;
  static const double clockInMaxAccuracy = 50;
  static const double setupTargetAccuracy = 20;
  static const double setupMaxAccuracy = 30;

  /// Effective fence used by the client soft check: max(admin, 25m floor).
  int effectiveRadius(int adminRadiusMeters) =>
      adminRadiusMeters < minEffectiveRadiusMeters
          ? minEffectiveRadiusMeters
          : adminRadiusMeters;

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
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );
  }

  /// Settled fix: samples until accuracy converges instead of trusting the
  /// first (often network/cached) fix. Returns the best fix seen.
  ///
  /// - Completes early once `best.accuracy <= targetAccuracy`.
  /// - Otherwise returns best-effort at [timeout] (caller gates on accuracy).
  /// - [onUpdate] fires on every new best so UI can show live `±Xm`.
  Future<Position> getSettledPosition({
    double targetAccuracy = clockInTargetAccuracy,
    Duration timeout = const Duration(seconds: 12),
    void Function(Position best)? onUpdate,
  }) async {
    final deadline = DateTime.now().add(timeout);
    Position? best;

    void consider(Position p) {
      if (best == null || p.accuracy < best!.accuracy) {
        best = p;
        onUpdate?.call(p);
      }
    }

    if (kIsWeb) {
      // Web: poll single-shot fixes (watchPosition interop is brittle).
      // Each poll is a fresh fix; accuracy typically drops over 5-10s.
      while (DateTime.now().isBefore(deadline)) {
        try {
          final p = await getCurrentPosition().timeout(
            const Duration(seconds: 6),
          );
          consider(p);
          if (p.accuracy <= targetAccuracy) break;
        } catch (_) {
          // Ignore single poll failures, keep sampling until deadline.
        }
        if (DateTime.now().isBefore(deadline)) {
          await Future.delayed(const Duration(milliseconds: 1200));
        }
      }
    } else {
      // Mobile: stream high-accuracy fixes until converged or timeout.
      final completer = Completer<Position?>();
      StreamSubscription<Position>? sub;
      try {
        sub = Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.best,
            distanceFilter: 0,
          ),
        ).listen(
          (p) {
            consider(p);
            if (p.accuracy <= targetAccuracy && !completer.isCompleted) {
              completer.complete(p);
            }
          },
          onError: (_) {},
        );
        await Future.any([
          completer.future,
          Future.delayed(timeout, () => null),
        ]);
        await sub.cancel();
      } catch (_) {
        try {
          await sub?.cancel();
        } catch (_) {}
      }
      // Fallback to single-shot if stream yielded nothing (e.g. emulator).
      if (best == null) {
        try {
          best = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.best,
          ).timeout(const Duration(seconds: 8));
        } catch (_) {}
      }
    }

    final result = best;
    if (result == null) throw Exception('Unable to get your location.');
    return result;
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
