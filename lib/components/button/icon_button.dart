import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final Widget icon;
  final Color colorBackground;
  final VoidCallback? onPressed;

  const MyIconButton({
    super.key,
    required this.icon,
    required this.colorBackground,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      style: IconButton.styleFrom(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        backgroundColor: colorBackground,
      ),
      onPressed: onPressed,
      icon: icon,
    );
  }
}
