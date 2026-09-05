import 'package:flutter/material.dart';

import '../hr/employee_database.dart';

/// API-backed employee directory route retained for existing navigation.
class EmployeeDirectoryPage extends StatelessWidget {
  const EmployeeDirectoryPage({super.key});

  @override
  Widget build(BuildContext context) => const EmployeeDatabase();
}
