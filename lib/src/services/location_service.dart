import 'dart:async';
import 'dart:developer';
import 'dart:io';
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

  /// Extra sampling after the target is first hit, to build the median
  /// cluster instead of trusting one lucky fix.
  static const Duration settleGrace = Duration(milliseconds: 2500);

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
          // Request GPS hardware; reject cached positions; allow 15 s for GPS lock.
          web.PositionOptions(
            enableHighAccuracy: true,
            maximumAge: 0,
            timeout: 15000,
          ),
        );
        return await completer.future;
      } catch (e) {
        throw Exception(
            "Geolocation is not supported by this browser. Error: $e");
      }
    }
    // Native (Android / iOS / Windows): request maximum GPS precision.
    final LocationSettings locationSettings;
    if (!kIsWeb && Platform.isAndroid) {
      locationSettings = AndroidSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        // Use Google Fused Location Provider (higher accuracy than legacy LocationManager).
        forceLocationManager: false,
      );
    } else if ((!kIsWeb && Platform.isIOS) || Platform.isMacOS) {
      locationSettings = AppleSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        activityType: ActivityType.other,
      );
    } else {
      locationSettings = const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
      );
    }
    return await Geolocator.getCurrentPosition(
      locationSettings: locationSettings,
    );
  }

  /// Settled fix: samples until accuracy converges instead of trusting the
  /// first (often network/cached) fix. Returns the median of the good-fix
  /// cluster, which kills single-sample jitter indoors.
  ///
  /// - Samples until [timeout]; once a fix hits [targetAccuracy] it keeps
  ///   sampling for [settleGrace] to build the median cluster, then returns.
  /// - Otherwise returns the median of whatever was collected (caller gates
  ///   on its accuracy).
  /// - [onUpdate] fires on every new best so UI can show live `±Xm`.
  /// - [onProgress] ticks 0→1 over [timeout] so UI can show a determinate
  ///   loader (ring/bar) that finishes when capture finishes.
  ///
  /// Accuracy note: no setting beats physics indoors — the phone fuses
  /// GPS + Wi-Fi + sensors, so keep device Wi-Fi ON (even unconnected) and
  /// capture where staff actually stand. Anything the radio can't resolve
  /// is absorbed by the backend's 25m fence floor, not by sampling longer.
  Future<Position> getSettledPosition({
    double targetAccuracy = clockInTargetAccuracy,
    Duration timeout = const Duration(seconds: 12),
    void Function(Position best)? onUpdate,
    void Function(double progress)? onProgress,
  }) async {
    final start = DateTime.now();
    final deadline = start.add(timeout);
    final totalMs = timeout.inMilliseconds;
    final samples = <Position>[];
    Position? best;
    DateTime? targetHitAt;

    double currentProgress() {
      final elapsed = DateTime.now().difference(start).inMilliseconds;
      return (elapsed / totalMs).clamp(0.0, 1.0);
    }

    final ticker = Timer.periodic(
      const Duration(milliseconds: 200),
      (_) => onProgress?.call(currentProgress()),
    );
    try {
      void consider(Position p) {
        samples.add(p);
        if (best == null || p.accuracy < best!.accuracy) {
          best = p;
          onUpdate?.call(p);
        }
        targetHitAt ??= p.accuracy <= targetAccuracy ? DateTime.now() : null;
      }

      // Grace sampling after the target is hit — a couple of extra fixes
      // turn one lucky sample into a trustworthy median cluster.
      bool settled() {
        if (DateTime.now().isAfter(deadline)) return true;
        final hit = targetHitAt;
        return hit != null &&
            DateTime.now().difference(hit) >= settleGrace;
      }

      if (kIsWeb) {
        // Web: poll single-shot fixes (watchPosition interop is brittle).
        // Each poll is high-accuracy + fresh; accuracy drops over 5-10s.
        while (!settled()) {
          try {
            final p = await getCurrentPosition().timeout(
              const Duration(seconds: 6),
            );
            consider(p);
          } catch (_) {
            // Ignore single poll failures, keep sampling until deadline.
          }
          if (!settled()) {
            await Future.delayed(const Duration(milliseconds: 1200));
          }
        }
      } else {
        // Mobile: nav-grade stream until the cluster settles or timeout.
        final completer = Completer<Position?>();
        StreamSubscription<Position>? sub;
        try {
          sub = Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.bestForNavigation,
              distanceFilter: 0,
            ),
          ).listen(
            (p) {
              consider(p);
              if (settled() && !completer.isCompleted) {
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
            final p = await Geolocator.getCurrentPosition(
              desiredAccuracy: LocationAccuracy.best,
            ).timeout(const Duration(seconds: 8));
            consider(p);
          } catch (_) {}
        }
      }

      if (best == null) throw Exception('Unable to get your location.');
      return _medianFix(samples);
    } finally {
      ticker.cancel();
      // Settle the loader at full so the UI never sticks mid-way.
      onProgress?.call(1.0);
    }
  }

  /// Median of the good-fix cluster: samples within 1.5x of the best
  /// accuracy (capped at 40m) so one flyer can't drag the pin. Falls back
  /// to all samples when nothing qualifies. Position is immutable, so the
  /// merged fix reuses the most accurate sample's metadata.
  Position _medianFix(List<Position> samples) {
    final bestAcc =
        samples.map((s) => s.accuracy).reduce((a, b) => a < b ? a : b);
    final cutoff = bestAcc * 1.5 < 40.0 ? bestAcc * 1.5 : 40.0;
    final good = samples.where((s) => s.accuracy <= cutoff).toList();
    final pool = good.isNotEmpty ? good : samples;

    double median(Iterable<double> values) {
      final sorted = values.toList()..sort();
      final mid = sorted.length ~/ 2;
      return sorted.length.isOdd
          ? sorted[mid]
          : (sorted[mid - 1] + sorted[mid]) / 2;
    }

    final base = pool.reduce((a, b) => a.accuracy <= b.accuracy ? a : b);
    return Position(
      latitude: median(pool.map((s) => s.latitude)),
      longitude: median(pool.map((s) => s.longitude)),
      timestamp: base.timestamp,
      accuracy: median(pool.map((s) => s.accuracy)),
      altitude: base.altitude,
      altitudeAccuracy: base.altitudeAccuracy,
      heading: base.heading,
      headingAccuracy: base.headingAccuracy,
      speed: base.speed,
      speedAccuracy: base.speedAccuracy,
    );
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
