import 'package:flutter/material.dart';

class SigninButton extends StatelessWidget {
  final VoidCallback onPressed;
  const SigninButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: const Size(double.infinity, 50),
        maximumSize: const Size(double.infinity, 50),
        backgroundColor: const Color(0xFFFFFFFF),
      ),
      child: const Text(
        "Sign in",
        style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Color(0xFF3E4095)),
      ),
    );
  }
}
