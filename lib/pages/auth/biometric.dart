import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/scaffold/scaffold.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:get/get.dart';
import 'controller.dart'; // Import AuthController

class BiometricLoginScreen extends StatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen> {
  final AuthController authController = Get.find<AuthController>();
  final BiometricService _biometricService = BiometricService();

  bool isAuthenticating = false;
  String? errorMessage;
  bool isAuthenticated = false;

  @override
  void initState() {
    super.initState();
    _initBiometric();
  }

  Future<void> _initBiometric() async {
    // Auto-trigger biometric prompt on load
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (isAvailable && mounted) {
      _performBiometricAuth();
    } else {
      setState(() => errorMessage = "Biometric not available on device.");
    }
  }

  Future<void> _performBiometricAuth() async {
    if (isAuthenticating) return;

    setState(() {
      isAuthenticating = true;
      errorMessage = null;
    });

    try {
      final result = await _biometricService.authenticateWithDetails(
        reason: 'Authenticate to access Bomach OS',
      );

      if (!mounted) return;

      if (result.isAuthenticated) {
        setState(() {
          isAuthenticated = true;
          isAuthenticating = false;
        });

        // Verify stored token is still valid via AuthController
        await authController.checkAuthStatus();

        if (authController.currentUser.value != null) {
          // Token valid, go home
          if (mounted) context.go(RouteConstants.home);
        } else {
          // Token expired despite biometric success
          if (mounted) {
            setState(() {
              isAuthenticated = false;
              errorMessage = "Session expired. Please sign in with PIN.";
            });
          }
        }
      } else {
        setState(() {
          isAuthenticating = false;
          // Only show error if not cancelled by user
          if (result.errorCode != 'authentication_cancelled') {
            errorMessage = result.errorMessage ?? "Authentication Failed";
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          isAuthenticating = false;
          errorMessage = 'Error: ${e.toString()}';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MyScaffold(
      addPad: false,
      body: Container(
        alignment: Alignment.center,
        width: double.infinity,
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/image/login-bg.png"),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.grey7, width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Title
                const MyText(
                  'Biometric Login',
                  style: AppText.black_600_32,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                MyText(
                  isAuthenticated ? 'Success!' : 'Tap to unlock',
                  style: AppText.black_400_14,
                  color: AppColors.grey2,
                ),
                const SizedBox(height: 48),

                // Icon / Status
                GestureDetector(
                  onTap: _performBiometricAuth,
                  child: Container(
                    height: 160,
                    width: 160,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isAuthenticated
                            ? AppColors.green
                            : AppColors.darkBlue,
                        width: 4,
                      ),
                      color: isAuthenticated
                          ? AppColors.green.withOpacity(0.1)
                          : Colors.transparent,
                    ),
                    child: Center(
                      child: Icon(
                        isAuthenticated ? Icons.check : Icons.fingerprint,
                        size: 90,
                        color: isAuthenticated
                            ? AppColors.green
                            : AppColors.darkBlue,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                if (isAuthenticating)
                  const Text("Scanning...",
                      style: TextStyle(color: Colors.grey)),

                if (errorMessage != null && !isAuthenticated)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Text(
                      errorMessage!,
                      style: const TextStyle(color: Colors.red),
                      textAlign: TextAlign.center,
                    ),
                  ),

                if (!isAuthenticated)
                  SizedBox(
                    width: double.infinity,
                    child: MyElevatedButton(
                      onTap: () => context.go(RouteConstants.login),
                      child: 'Use Password Instead',
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
