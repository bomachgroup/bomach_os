// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:bms_front_end/src/constants/textstyle.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Welcome to Admin Dashboard,',
      style: AppText.black_600_32,
    );
  }
}
