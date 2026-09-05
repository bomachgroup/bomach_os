import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:bomach_os/pages/employee/employee_directory.dart';
import 'package:bomach_os/src/services/permission_service.dart';

void main() {
  testWidgets('directory does not place Expanded inside the filter Wrap',
      (tester) async {
    Get.put(PermissionService()).loadSuperAdminPermissions();
    await tester.binding.setSurfaceSize(const Size(1440, 900));
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: EmployeeDirectoryPage()),
    ));

    expect(tester.takeException(), isNull);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('Add Employee'), findsNWidgets(2));
    expect(
      find.text('Manage active team members, alumni, and their employment details.'),
      findsOneWidget,
    );
    Get.reset();
  });
}
