import 'package:bomach_os/src/services/location_service.dart';
import 'package:geolocator/geolocator.dart';

import 'attendance_reminder_contracts.dart';

AttendanceReminderLocationProvider createAttendanceReminderLocationProvider() =>
    _WebReminderLocationProvider();

class _WebReminderLocationProvider
    implements AttendanceReminderLocationProvider {
  final LocationService _location = LocationService();

  @override
  Future<Position> requestPermissionAndGetPosition() async {
    if (!await _location.ensurePermission()) {
      throw StateError('Location permission denied or unavailable');
    }
    return _location.getCurrentPosition().timeout(
          const Duration(seconds: 18),
        );
  }

  @override
  Future<bool> hasExistingPermission() async {
    final permission = await Geolocator.checkPermission();
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  @override
  Future<Position> getCurrentPosition() =>
      _location.getCurrentPosition().timeout(const Duration(seconds: 18));

  @override
  Stream<Position> watchPositions() => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 5,
        ),
      );
}
