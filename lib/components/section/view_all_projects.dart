import 'package:flutter/material.dart';

class ViewAllProjectsPage extends StatelessWidget {
  const ViewAllProjectsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DataTable(columns: const [], rows: const []),
    );
  }
}