import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/scaffold/scaffold.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:bms_front_end/src/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class BiometricLoginScreen extends StatefulWidget {
  const BiometricLoginScreen({super.key});

  @override
  State<BiometricLoginScreen> createState() => _BiometricLoginScreenState();
}

class _BiometricLoginScreenState extends State<BiometricLoginScreen> {
  bool rememberDevice = false;
  bool isAuthenticating = false;
  String? errorMessage;
  bool isAuthenticated = false;
  final BiometricService _biometricService = BiometricService();

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await _biometricService.isBiometricAvailable();
    if (!isAvailable && mounted) {
      setState(() {
        errorMessage = 'Biometric authentication is not available on this device';
      });
    }
  }

  Future<void> _performBiometricAuth() async {
    setState(() {
      isAuthenticating = true;
      errorMessage = null;
    });

    try {
      final result = await _biometricService.authenticateWithDetails(
        reason: 'Authenticate to log in to your account',
      );

      if (mounted) {
        if (result.isAuthenticated) {
          // Successful authentication
          setState(() {
            isAuthenticated = true;
            isAuthenticating = false;
          });

          // Navigate to home after successful authentication
          if (mounted) {
            await Future.delayed(const Duration(milliseconds: 500));
            if (mounted) {
              context.go(RouteConstants.home);
            }
          }
        } else {
          // Authentication failed
          setState(() {
            errorMessage = result.errorMessage;
            isAuthenticating = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          errorMessage = 'Authentication failed: ${e.toString()}';
          isAuthenticating = false;
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
              border: Border.all(
                color: AppColors.grey7,
                width: 0.5,
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.greyBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  height: 70,
                  width: 90,
                  child: Image.asset("assets/logo/bomach.png"),
                ),
                const SizedBox(height: 40),

                // Title
                const MyText(
                  'Biometric Login',
                  style: AppText.black_600_32,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),

                // Subtitle
                MyText(
                  'Use your fingerprint to log in.',
                  style: AppText.black_400_14,
                  textAlign: TextAlign.center,
                  color: AppColors.grey2,
                ),
                const SizedBox(height: 48),

                // Fingerprint Icon
                if (!isAuthenticated)
                  GestureDetector(
                    onTap: isAuthenticating ? null : _performBiometricAuth,
                    child: Container(
                      height: 200,
                      width: 200,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppColors.darkBlue,
                          width: 4,
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.fingerprint,
                          size: 120,
                          color: AppColors.darkBlue,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 48),

                // Error Message
                if (errorMessage != null && !isAuthenticated)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFEBEE),
                      border: Border.all(color: AppColors.red, width: 1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: MyText(
                      errorMessage!,
                      style: const TextStyle(
                        color: AppColors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                if (errorMessage != null && !isAuthenticated)
                  const SizedBox(height: 24),

                // Remember Device Toggle
                if (!isAuthenticated)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const MyText(
                          'Remember this device',
                          style: AppText.black_400_14,
                        ),
                        Switch(
                          value: rememberDevice,
                          onChanged: (value) {
                            setState(() {
                              rememberDevice = value;
                            });
                          },
                          activeColor: AppColors.blue,
                          inactiveThumbColor: AppColors.grey5,
                        ),
                      ],
                    ),
                  ),
                if (!isAuthenticated) const SizedBox(height: 32),

                // Verify/Retry Button
                if (!isAuthenticated)
                  SizedBox(
                    width: double.infinity,
                    child: MyElevatedButton(
                      child: isAuthenticating ? 'Verifying...' : 'Verify Biometric',
                      onTap: isAuthenticating ? null : _performBiometricAuth,
                    ),
                  ),
                if (!isAuthenticated) const SizedBox(height: 16),

                // Use PIN Button
                if (!isAuthenticated)
                  SizedBox(
                    width: double.infinity,
                    child: MyElevatedButton(
                      child: 'Use PIN',
                      onTap: () {
                        context.go(RouteConstants.login);
                      },
                    ),
                  ),
                if (!isAuthenticated) const SizedBox(height: 32),

                // Success Message
                if (isAuthenticated)
                  Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.green,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 40,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      const MyText(
                        'Authentication Successful',
                        style: AppText.black_600_16,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      const MyText(
                        'You will be redirected shortly...',
                        style: AppText.black_400_14,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),

                // Security Policy Link
                if (!isAuthenticated)
                  GestureDetector(
                    onTap: () {
                      // Navigate to security policy
                    },
                    child: MyText(
                      'Bomach Security Policy',
                      style: AppText.black_400_14,
                      textAlign: TextAlign.center,
                      color: AppColors.darkGrey1,
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
