import 'package:flutter/material.dart';

Widget buildServicesPlatformView({
  required String initialUrl,
  required String token,
  String refreshToken = '',
  required String currentRoute,
  bool hideSidebar = true,
  bool hideTopbar = false,
}) {
  return Center(
    child: Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.miscellaneous_services_outlined, size: 48, color: Colors.blueGrey),
          const SizedBox(height: 16),
          const Text(
            'Services Operations View',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Route: $currentRoute',
            style: const TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 16),
          const Text(
            'This view is fully available on Flutter Web.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
