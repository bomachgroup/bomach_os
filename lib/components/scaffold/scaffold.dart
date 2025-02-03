import 'package:flutter/material.dart';

class MyScaffold extends StatelessWidget {
  final Widget body;
  final bool addPad;
  const MyScaffold({super.key, required this.body, this.addPad = true});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: addPad ? 20 : 0),
        child: body,
      ),
    );
  }
}
