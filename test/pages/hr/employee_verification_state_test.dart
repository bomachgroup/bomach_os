import 'package:bomach_os/pages/hr/employee_profile.dart';
import 'package:bomach_os/src/model/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('employee profile displays the backend verification state',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EmployeeProfile(
          e: Employee(
            id: '7',
            email: 'verified@bomach.com',
            firstName: 'Verified',
            lastName: 'Employee',
            isVerified: true,
          ),
        ),
      ),
    );

    expect(find.text('Verified'), findsOneWidget);
  });

  testWidgets('employee profile displays unverified when backend says false',
      (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: EmployeeProfile(
          e: Employee(
            id: '8',
            email: 'unverified@bomach.com',
            firstName: 'Unverified',
            lastName: 'Employee',
          ),
        ),
      ),
    );

    expect(find.text('Unverified'), findsOneWidget);
  });
}
