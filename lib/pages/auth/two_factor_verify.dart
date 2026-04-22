import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:bms_front_end/components/button/my_elevated_button.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/scaffold/scaffold.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';

import 'controller.dart';

class TwoFactorVerifyScreen extends StatelessWidget {
  const TwoFactorVerifyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthController authController = Get.find<AuthController>();

    // Clear any previous code when the screen is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authController.twoFactorCodeController.clear();
    });

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
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
            margin: const EdgeInsets.symmetric(horizontal: 20),
            constraints: const BoxConstraints(maxWidth: 500),
            decoration: BoxDecoration(
                border: Border.all(
                  color: const Color.fromARGB(255, 224, 222, 222),
                  width: 0.5,
                ),
                borderRadius: BorderRadius.circular(20)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(20)),
                  height: 120,
                  width: 140,
                  child: Image.asset("assets/logo/bomach.png"),
                ),
                kSizedBoxSM,
                const MyText(
                  "2FA Verification",
                  style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 24,
                      color: Colors.white),
                  textAlign: TextAlign.center,
                ),
                kSizedBoxSM,
                const MyText(
                  "A verification code has been sent to your registered email. Please enter it below to continue.",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                  textAlign: TextAlign.center,
                ),
                kSizedBox,

                // 2FA Code Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: MyTextFormField(
                    controller: authController.twoFactorCodeController,
                    title: "Verification Code",
                    hintText: "Enter 6-digit code",
                    textColor: AppColors.white,
                    borderRadius: BorderRadius.circular(30),
                    spaceBetweenText: 10,
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                  ),
                ),
                kSizedBox,

                // Verify Button
                Obx(() => MyElevatedButton(
                      width: double.infinity,
                      bgColor: AppColors.white,
                      textColor: AppColors.primary,
                      isLoading: authController.isLoading.value,
                      child: "Verify Code",
                      onTap: () {
                        authController.verify2Fa(context);
                      },
                    )),
                const SizedBox(height: 20),

                // Back to Login Link
                TextButton(
                  onPressed: () {
                    authController.currentSessionToken = null;
                    authController.twoFactorCodeController.clear();
                    context.go(RouteConstants.login);
                  },
                  child: const MyText(
                    "Back to Login",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w300),
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
