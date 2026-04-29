import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/components/input/my_textformfield.dart';
import 'package:bomach_os/components/scaffold/scaffold.dart';
import 'package:bomach_os/components/text/my_text.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'controller.dart';

class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    // Local controller for confirmation, main password uses authController
    final confirmPassCtrl = TextEditingController();

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
              border: Border.all(color: AppColors.neutral200, width: 0.5),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const MyText(
                  'Set New Password',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const MyText(
                  'Enter the code sent to your email and your new password.',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
                kSizedBox,

                // Code Input
                MyTextFormField(
                  controller: authController.resetCodeController,
                  title: "Reset Code",
                  hintText: "Enter 6-digit code",
                  borderRadius: BorderRadius.circular(30),
                  spaceBetweenText: 8,
                  keyboardType: TextInputType.number,
                ),
                kSizedBox,

                // New Password Input
                Obx(() => MyTextFormField(
                      controller: authController.newPasswordController,
                      title: "New Password",
                      hintText: "Enter new password",
                      borderRadius: BorderRadius.circular(30),
                      spaceBetweenText: 8,
                      obscureText: authController.obscurePassword.value,
                    )),
                kSizedBox,

                // Confirm Password Input
                Obx(() => MyTextFormField(
                      controller: confirmPassCtrl,
                      title: "Confirm Password",
                      hintText: "Re-enter password",
                      borderRadius: BorderRadius.circular(30),
                      spaceBetweenText: 8,
                      obscureText: authController.obscurePassword.value,
                    )),
                kSizedBox,

                // Reset Button
                Obx(() => SizedBox(
                      width: double.infinity,
                      child: MyElevatedButton(
                        height: 50,
                        onTap: authController.isLoading.value
                            ? () {}
                            : () async {
                                if (authController.newPasswordController.text !=
                                    confirmPassCtrl.text) {
                                  AppToast.error(context, 'Passwords do not match');
                                  return;
                                }
                                await authController.resetPassword(context);
                              },
                        child: authController.isLoading.value
                            ? 'loading...'
                            : "Reset Password",
                      ),
                    )),
                const SizedBox(height: 20),

                GestureDetector(
                  onTap: () => context.pop(),
                  child: const MyText("Back",
                      style: TextStyle(color: Colors.grey)),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
