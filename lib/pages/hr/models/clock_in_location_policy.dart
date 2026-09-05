import 'location_verification_result.dart';

/// Backend-authoritative gate used before biometric capture.
class ClockInLocationPolicy {
  const ClockInLocationPolicy._();

  static bool canProceed(LocationVerificationResult verification) =>
      verification.isAllowed;
}
