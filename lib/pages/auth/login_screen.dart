import 'package:bms_front_end/components/button/signin_button.dart';
import 'package:bms_front_end/components/scaffold/scaffold.dart';
import 'package:flutter/material.dart';

import '../../components/input/login_textfield.dart';

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
              fit: BoxFit.cover),
        ),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 50),
          constraints: const BoxConstraints(maxWidth: 626),
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
                SizedBox(
                  height: 175,
                  width: 155,
                  child: Image.asset("assets/logo/bomach.png"),
                ),
                const SizedBox(
                  height: 9,
                ),
                const Text(
                  "Hey, welcome",
                  style: TextStyle(
                      fontSize: 9,
                      color: Colors.white,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(
                  height: 15,
                ),
                const Text(
                  "Sign In",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(
                  height: 20,
                ),
                const FormTextField(
                  title: "User ID",
                  hintText: "Enter User ID",
                ),
                const SizedBox(
                  height: 10,
                ),
                const FormTextField(
                  title: "PIN",
                  hintText: "Enter PIN/password",
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Row(
                    children: [
                      Checkbox(
                          // checkColor: Color.fromARGB(0, 37, 36, 36),
                          fillColor: const WidgetStatePropertyAll(
                              Color.fromRGBO(224, 222, 222, 1)),
                          value: true,
                          onChanged: (value) {}),
                      const SizedBox(
                        width: 10,
                      ),
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
                  onPressed: () {},
                ),
                const SizedBox(
                  height: 5,
                ),
                const Row(children: [
                  Text(
                    "Forgot password?",
                    style: TextStyle(color: Colors.white, fontSize: 10),
                  ),
                ])
              ],
            ),
          ),
        ),
      ),
    );
  }
}
