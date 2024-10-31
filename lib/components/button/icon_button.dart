import 'package:flutter/material.dart';

class IconHeaderButton extends StatelessWidget {
  final IconData icon;
  final Color colorBackground;
  final VoidCallback? onPressed;

  const IconHeaderButton(
      {super.key,
      required this.icon,
      required this.colorBackground,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      width: 30,
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: colorBackground,
      ),
      child: GestureDetector(
          child: Icon(
        icon,
        size: 20,
        color: const Color(0xFFFFFFFF),
      )),
    );
  }
}
