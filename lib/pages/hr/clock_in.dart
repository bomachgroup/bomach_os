import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/services/biometric_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ClockInScreen extends StatefulWidget {
  const ClockInScreen({super.key});

  @override
  State<ClockInScreen> createState() => _ClockInScreenState();
}

class _ClockInScreenState extends State<ClockInScreen> {
  String selectedLocation = 'Site';
  bool isBiometricVerified = false;
  bool isAuthenticating = false;
  String? errorMessage;
  String? clockInTime;
  String? endOfDayTime;
  final List<String> locations = ['Site', 'Office', 'Home', 'Virtual'];
  final String locationName = 'Inside Site (ISU, Isi-Uzo)';
  final BiometricService _biometricService = BiometricService();
  DateTime? _clockInDateTime;

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
        reason: 'Authenticate to clock in',
      );

      if (mounted) {
        if (result.isAuthenticated) {
          // Successful authentication
          setState(() {
            isBiometricVerified = true;
            isAuthenticating = false;
            _clockInDateTime = DateTime.now();
            clockInTime = DateFormat('hh:mm a').format(_clockInDateTime!);
            // Set end of day (5:00 PM)
            endOfDayTime = '05:00 PM';
          });
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

  void _handleClockOut() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const MyText('Clock Out'),
        content: const MyText(
          'Are you sure you want to clock out?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const MyText('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                isBiometricVerified = false;
                clockInTime = null;
                endOfDayTime = null;
                errorMessage = null;
                _clockInDateTime = null;
              });
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: MyText('Clocked out successfully'),
                  backgroundColor: Colors.green,
                ),
              );
            },
            child: const MyText('Clock Out'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.darkBlue,
            AppColors.darkBlue2,
          ],
        ),
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Logo
              Container(
                height: 50,
                width: 150,
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  "assets/logo/bomach.png",
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 40),

              // Clock-In Title
              const MyText(
                'CLOCK-IN',
                style: TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 2,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // Location Selection Buttons
              if (!isBiometricVerified)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: locations.map((location) {
                      final isSelected = selectedLocation == location;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedLocation = location;
                            });
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Colors.transparent,
                              border: Border.all(
                                color: isSelected
                                    ? Colors.transparent
                                    : Colors.white,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: MyText(
                              location,
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: isSelected
                                    ? AppColors.darkBlue
                                    : Colors.white,
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              if (!isBiometricVerified) const SizedBox(height: 32),

              // Location Info with checkmark
              if (!isBiometricVerified)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.2),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 28,
                        width: 28,
                        decoration: const BoxDecoration(
                          color: AppColors.green,
                          shape: BoxShape.circle,
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.check,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: MyText(
                          locationName,
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              if (!isBiometricVerified) const SizedBox(height: 32),

              // Biometric Section
              if (!isBiometricVerified)
                Column(
                  children: [
                    // Fingerprint Icon
                    GestureDetector(
                      onTap:
                          isAuthenticating ? null : _performBiometricAuth,
                      child: Container(
                        height: 180,
                        width: 180,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white.withValues(alpha: 0.1),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 3,
                          ),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.fingerprint,
                            size: 100,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const MyText(
                      'Tap to Verify with\nBiometric',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                        height: 1.4,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Error Message
                    if (errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEBEE),
                          border: Border.all(
                            color: AppColors.red,
                            width: 1,
                          ),
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
                    if (errorMessage != null) const SizedBox(height: 16),
                    // Verify Button
                    SizedBox(
                      width: double.infinity,
                      child: MyElevatedButton(
                        child: isAuthenticating
                            ? 'Verifying...'
                            : 'Verify Biometric',
                        onTap: isAuthenticating ? null : _performBiometricAuth,
                      ),
                    ),
                  ],
                )
              else
                Column(
                  children: [
                    // Clock In Time Display
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.2),
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const MyText(
                                'Clocked in',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              MyText(
                                clockInTime ?? '09:08 AM',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const MyText(
                                'End of day',
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                ),
                              ),
                              MyText(
                                endOfDayTime ?? '05:00 PM',
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Clock Out Button
                    SizedBox(
                      width: double.infinity,
                      child: MyElevatedButton(
                        child: 'Clock Out',
                        onTap: _handleClockOut,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Sync Notification
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: const MyText(
                  'Attendance will sync when online',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.white,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
