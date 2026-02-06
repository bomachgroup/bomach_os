import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';

import 'package:bms_front_end/components/button/signin_button.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/scaffold/scaffold.dart';
import 'package:bms_front_end/components/text/my_text.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';

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
    return MyScaffold(
      addPad: false,
      body: Obx(
        () {
          final bool showLoader =
              _isCheckingAuth || authController.isLoading.value;

          return Stack(
            children: [
              Container(
                alignment: Alignment.center,
                width: double.infinity,
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage("assets/image/login-bg.png"),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  constraints: const BoxConstraints(maxWidth: 500),
                  decoration: BoxDecoration(
                      border: Border.all(
                        color: const Color.fromARGB(255, 224, 222, 222),
                        width: 0.5,
                      ),
                      borderRadius: BorderRadius.circular(20)),
                  child: SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(20)),
                          height: 155,
                          width: 175,
                          child: Image.asset("assets/logo/bomach.png"),
                        ),
                        kSizedBoxTiny,
                        const MyText(
                          "Hey, welcome",
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        kSizedBoxSM,
                        const MyText(
                          "Sign In",
                          style: TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 32,
                              color: Colors.white),
                        ),
                        kSizedBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: MyTextFormField(
                            controller: authController.emailController,
                            title: "User ID",
                            hintText: "Enter User ID",
                            textColor: AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                            spaceBetweenText: 10,
                          ),
                        ),
                        kSizedBox,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: MyTextFormField(
                            controller: authController.passwordController,
                            title: "PIN",
                            hintText: "Enter PIN/password",
                            textColor: AppColors.white,
                            borderRadius: BorderRadius.circular(30),
                            spaceBetweenText: 10,
                            // obscureText: authController.obscurePassword.value,
                          ),
                        ),
                        kSizedBoxSM,
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30.0),
                          child: Row(
                            children: [
                              MyCheckbox(
                                checkColor: AppColors.blue,
                                backgroundColor: AppColors.white,
                                isChecked:
                                    !authController.obscurePassword.value,
                                onChanged: (val) {
                                  authController.togglePasswordVisibility();
                                },
                              ),
                              kSizedBoxWidthSM,
                              const MyText(
                                "Show Password",
                                style: TextStyle(
                                    color: Colors.white, fontSize: 12),
                              )
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                        SigninButton(
                          onPressed: showLoader
                              ? null
                              : () {
                                  authController.login(context);
                                },
                        ),
                        const SizedBox(height: 5),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            GestureDetector(
                              onTap: showLoader
                                  ? null
                                  : () {
                                      authController.forgotPassword(context,
                                          authController.emailController.text);
                                    },
                              child: const MyText(
                                "Forgot password?",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                context.go(RouteConstants.biometric);
                              },
                              child: const MyText(
                                "Use Biometric",
                                style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w300),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
              if (showLoader)
                Container(
                  color: Colors.black.withValues(alpha: 0.5),
                  height: double.infinity,
                  width: double.infinity,
                  child: const Center(
                    child: CircularProgressIndicator(
                        color: AppColors.white, strokeWidth: 2),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
