import 'package:flutter/material.dart';

class SigninButton extends StatelessWidget {
  const SigninButton({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: const EdgeInsets.symmetric(horizontal: 32,vertical: 24),
        decoration:  BoxDecoration(
          borderRadius: BorderRadius.circular(73)
        ),
      ),
    );
  }
}