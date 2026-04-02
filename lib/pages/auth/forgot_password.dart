import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/scaffold/scaffold.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'controller.dart'; // Import your AuthController

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();
    final TextEditingController emailCtrl = TextEditingController();

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
                // Icon Header
                Container(
                  padding: const EdgeInsets.all(15),
                  decoration: BoxDecoration(
                    color: AppColors.blue.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.lock_reset,
                      size: 40, color: AppColors.blue),
                ),
                kSizedBox,

                const MyText(
                  'Forgot Password?',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const MyText(
                  'Enter your email address to receive a password reset code.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                kSizedBox,

                // Email Input
                MyTextFormField(
                  controller: emailCtrl,
                  title: "Email Address",
                  hintText: "Enter your email",
                  borderRadius: BorderRadius.circular(30),
                  spaceBetweenText: 8,
                ),
                kSizedBox,

                // Send Code Button
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: MyElevatedButton(
                        height: 50,
                        onTap: authController.isLoading.value
                            ? () {}
                            : () async {
                                if (emailCtrl.text.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text("Please enter email")),
                                  );
                                  return;
                                }
                                // Call controller logic
                                await authController.forgotPassword(
                                    context, emailCtrl.text.trim());

                                // Pre-fill email for next screen
                                authController.emailController.text =
                                    emailCtrl.text.trim();

                                // Navigate to Reset Screen if no error thrown inside controller
                                // Note: In a real app, check success before navigating
                                if (context.mounted) {
                                  context.push(RouteConstants.resetPassword);
                                }
                              },
                        child: authController.isLoading.value
                            ? 'loading...'
                            : "Send Reset Code",
                      ),
                    )),
                const SizedBox(height: 20),

                // Back to Login
                GestureDetector(
                  onTap: () => context.pop(),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.arrow_back, size: 16, color: Colors.grey),
                      SizedBox(width: 8),
                      MyText(
                        "Back to Login",
                        style: TextStyle(
                            color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
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
