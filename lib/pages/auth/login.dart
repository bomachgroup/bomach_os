import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/icons.dart';
import 'package:bms_front_end/src/constants/radii.dart';
import 'package:bms_front_end/src/constants/shadows.dart';
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'controller.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final AuthController authController = Get.put(AuthController());

  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await authController.checkAuthStatus();
      if (mounted) {
        setState(() {
          _isCheckingAuth = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Obx(
        () {
          final bool showLoader =
              _isCheckingAuth || authController.isLoading.value;

          return Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/image/login-bg.png",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  color: AppColors.neutral900.withValues(alpha: 0.35),
                ),
              ),
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 32),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 440),
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        borderRadius: AppRadii.brLg,
                        boxShadow: AppShadows.lg,
                        border: Border.all(color: AppColors.borderSubtle),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: SizedBox(
                              height: 64,
                              child: Image.asset("assets/logo/bomach.png"),
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Welcome back',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.h1,
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Sign in to continue to Bomach OS',
                            textAlign: TextAlign.center,
                            style: AppTextStyles.bodyMd.copyWith(
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 28),
                          MyTextFormField(
                            controller: authController.emailController,
                            title: 'Username',
                            hintText: 'Enter your username',
                            spaceBetweenText: 8,
                            leading: const Padding(
                              padding: EdgeInsets.only(left: 12, right: 8),
                              child: Icon(
                                AppIcons.user,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          MyTextFormField(
                            controller: authController.passwordController,
                            title: 'Password',
                            hintText: 'Enter your password',
                            spaceBetweenText: 8,
                            obscureText: authController.obscurePassword.value,
                            leading: const Padding(
                              padding: EdgeInsets.only(left: 12, right: 8),
                              child: Icon(
                                AppIcons.lock,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                            ),
                            trailing: IconButton(
                              onPressed:
                                  authController.togglePasswordVisibility,
                              icon: Icon(
                                authController.obscurePassword.value
                                    ? AppIcons.eye
                                    : AppIcons.eyeSlash,
                                size: 18,
                                color: AppColors.textMuted,
                              ),
                              splashRadius: 18,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: showLoader
                                  ? null
                                  : () => context
                                      .push(RouteConstants.forgotPassword),
                              style: TextButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 4),
                                minimumSize: const Size(0, 32),
                                tapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                              ),
                              child: Text(
                                'Forgot password?',
                                style: AppTextStyles.label.copyWith(
                                  color: AppColors.primary,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            height: 48,
                            child: ElevatedButton(
                              onPressed: showLoader
                                  ? null
                                  : () => authController.login(context),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.textOnPrimary,
                                elevation: 0,
                                shape: const RoundedRectangleBorder(
                                  borderRadius: AppRadii.brMd,
                                ),
                                textStyle: AppTextStyles.bodyMd.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              child: showLoader
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: AppColors.textOnPrimary,
                                      ),
                                    )
                                  : const Text('Sign in'),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              const Expanded(
                                child: Divider(
                                  color: AppColors.borderSubtle,
                                  thickness: 1,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12),
                                child: Text(
                                  'or',
                                  style: AppTextStyles.caption.copyWith(
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ),
                              const Expanded(
                                child: Divider(
                                  color: AppColors.borderSubtle,
                                  thickness: 1,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          OutlinedButton.icon(
                            onPressed: () =>
                                context.push(RouteConstants.biometric),
                            icon: const Icon(
                              AppIcons.security,
                              size: 18,
                            ),
                            label: const Text('Use biometric'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: AppColors.textPrimary,
                              side: const BorderSide(
                                  color: AppColors.borderSubtle),
                              minimumSize: const Size.fromHeight(48),
                              shape: const RoundedRectangleBorder(
                                borderRadius: AppRadii.brMd,
                              ),
                              textStyle: AppTextStyles.bodyMd.copyWith(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
