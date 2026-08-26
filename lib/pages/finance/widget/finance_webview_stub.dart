import 'package:flutter/material.dart';

Widget buildFinancePlatformView({
  required String initialUrl,
  required String token,
  String refreshToken = '',
  String fullName = '',
  String email = '',
  required String currentRoute,
  bool hideSidebar = true,
  bool hideTopbar = false,
}) {
  return const Center(
    child: Text('Finance web platform view is only supported on Web.'),
  );
}
