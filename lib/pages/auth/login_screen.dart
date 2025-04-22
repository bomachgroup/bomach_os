import 'package:bms_front_end/components/button/signin_button.dart';
import 'package:bms_front_end/components/input/my_checkbox.dart';
import 'package:bms_front_end/components/input/my_textformfield.dart';
import 'package:bms_front_end/components/scaffold/scaffold.dart';
import 'package:bms_front_end/src/app_routes/app_route_constants.dart';
import 'package:bms_front_end/src/constants/colors.dart';
import 'package:bms_front_end/src/constants/spaces.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class LoginScreen extends StatelessWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final size = MediaQuery.of(context).size;
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
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 25),
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
                //bomach icon
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                      color: AppColors.whiteColor,
                      borderRadius: BorderRadius.circular(20)),
                  height: 155,
                  width: 175,
                  child: Image.asset("assets/logo/bomach.png"),
                ),
                kSizedBoxTiny,
                const Text(
                  "Hey, welcome",
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                kSizedBoxSM,
                const Text(
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
                    title: "User ID",
                    hintText: "Enter User ID",
                    textColor: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(30),
                    spaceBettwenText: 10,
                  ),
                ),
                kSizedBox,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: MyTextFormField(
                    title: "PIN",
                    hintText: "Enter PIN/password",
                    textColor: AppColors.whiteColor,
                    borderRadius: BorderRadius.circular(30),
                    spaceBettwenText: 10,
                  ),
                ),
                kSizedBoxSM,
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    children: [
                      MyCheckbox(
                        checkColor: AppColors.blueColor,
                        backgroundColor: AppColors.whiteColor,
                        isChecked: true,
                        onChanged: (val) {},
                      ),
                      kSizedBoxWidthSM,
                      const Text(
                        "Show Password",
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SigninButton(
                  onPressed: () {
                    context.go(RouteConstants.home);
                  },
                ),
                const SizedBox(
                  height: 5,
                ),
                const Row(
                  children: [
                    Text(
                      "Forgot password?",
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w300),
                    ),
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
