import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:local_auth/local_auth.dart';

class BiometricService {
  static final BiometricService _instance = BiometricService._internal();
  late final LocalAuthentication? _auth;

  factory BiometricService() {
    return _instance;
  }

  BiometricService._internal() {
    // Only initialize LocalAuthentication on mobile platforms
    if (!kIsWeb) {
      _auth = LocalAuthentication();
    } else {
      _auth = null;
    }
  }

  /// Check if device supports biometric authentication
  Future<bool> isBiometricAvailable() async {
    try {
      if (kIsWeb || _auth == null) {
        return false;
      }
      return await _auth.canCheckBiometrics;
    } catch (e) {
      debugPrint('Error checking biometric availability: $e');
      return false;
    }
  }

  /// Check if device has biometric enrolled
  Future<bool> hasBiometricEnrolled() async {
    try {
      if (kIsWeb || _auth == null) {
        return false;
      }
      final isAvailable = await _auth.canCheckBiometrics;
      final isDeviceSupported = await _auth.isDeviceSupported();
      return isAvailable || isDeviceSupported;
    } catch (e) {
      debugPrint('Error checking biometric enrollment: $e');
      return false;
    }
  }

  /// Get available biometric types
  Future<List<BiometricType>> getAvailableBiometrics() async {
    try {
      if (kIsWeb || _auth == null) {
        return [];
      }
      return await _auth.getAvailableBiometrics();
    } catch (e) {
      debugPrint('Error getting available biometrics: $e');
      return [];
    }
  }

  /// Authenticate using biometric
  Future<bool> authenticate({
    required String reason,
    required bool useErrorDialogs,
  }) async {
    try {
      // Check if biometric is available
      final isBiometricAvailable = await this.isBiometricAvailable();
      if (!isBiometricAvailable || _auth == null) {
        debugPrint('Biometric authentication not available');
        return false;
      }

      // Perform authentication
      final isAuthenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      return isAuthenticated;
    } catch (e) {
      debugPrint('Biometric authentication error: $e');
      return false;
    }
  }

  /// Authenticate with detailed error handling
  Future<BiometricResult> authenticateWithDetails({
    required String reason,
  }) async {
    try {
      // Check if biometric is available
      final isBiometricAvailable = await this.isBiometricAvailable();
      if (!isBiometricAvailable || _auth == null) {
        return BiometricResult(
          isAuthenticated: false,
          errorMessage:
              'Biometric authentication is not available on this device',
          errorCode: 'biometric_not_available',
        );
      }

      // Get available biometrics
      final availableBiometrics = await getAvailableBiometrics();
      if (availableBiometrics.isEmpty) {
        return BiometricResult(
          isAuthenticated: false,
          errorMessage:
              'No biometric enrolled. Please enroll a biometric first.',
          errorCode: 'no_biometric_enrolled',
        );
      }

      // Perform authentication
      final isAuthenticated = await _auth.authenticate(
        localizedReason: reason,
        options: const AuthenticationOptions(
          stickyAuth: true,
          biometricOnly: true,
        ),
      );

      if (isAuthenticated) {
        return BiometricResult(
          isAuthenticated: true,
          biometricType: availableBiometrics.first.name,
        );
      } else {
        return BiometricResult(
          isAuthenticated: false,
          errorMessage: 'Biometric authentication was cancelled',
          errorCode: 'authentication_cancelled',
        );
      }
    } on Exception catch (e) {
      return BiometricResult(
        isAuthenticated: false,
        errorMessage: 'Biometric authentication failed: ${e.toString()}',
        errorCode: 'authentication_error',
      );
    }
  }

  /// Stop authentication
  Future<void> stopAuthentication() async {
    try {
      if (_auth != null) {
        await _auth.stopAuthentication();
      }
    } catch (e) {
      debugPrint('Error stopping authentication: $e');
    }
  }
}

class BiometricResult {
  final bool isAuthenticated;
  final String? errorMessage;
  final String? errorCode;
  final String? biometricType;

  BiometricResult({
    required this.isAuthenticated,
    this.errorMessage,
    this.errorCode,
    this.biometricType,
  });
}
