import 'package:bomach_os/pages/hr/employee_profile.dart';
import 'package:bomach_os/src/model/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('desktop employee profile follows the employee database design',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    final employee = Employee(
      id: '42',
      email: 'ada@bomach.com',
      firstName: 'Ada',
      lastName: 'Okafor',
      designation: 'Product Designer',
      employeeId: 'EMP-42',
      departmentName: 'Product',
      branchName: 'Lagos',
      isVerified: true,
    );

    await tester.pumpWidget(
      MaterialApp(
        home: EmployeeDesktopProfileLayout(employee: employee),
      ),
    );

    expect(find.text("Employee's Database"), findsOneWidget);
    expect(find.text('Ada Okafor'), findsOneWidget);
    expect(find.text('Product Designer'), findsOneWidget);
    expect(find.text('ada@bomach.com'), findsAtLeastNWidgets(1));
    expect(find.text('Edit Profile'), findsOneWidget);
    expect(find.text('Profile'), findsOneWidget);
    expect(find.text('Activity'), findsOneWidget);
    expect(find.text('Tasks'), findsOneWidget);
    expect(find.text('Work Reports'), findsOneWidget);
    expect(find.text('Projects'), findsNothing);
    expect(find.text('Reports Files'), findsNothing);
    expect(find.text('Personal Information'), findsOneWidget);
    expect(find.text('Professional Information'), findsOneWidget);
    expect(find.text('Documents'), findsOneWidget);
  });

  testWidgets('desktop employee page uses the primary edit action',
      (tester) async {
    await tester.binding.setSurfaceSize(const Size(1440, 1024));
    addTearDown(() => tester.binding.setSurfaceSize(null));

    await tester.pumpWidget(
      MaterialApp(
        home: MediaQuery(
          data: const MediaQueryData(size: Size(1440, 1024)),
          child: EmployeeProfile(
            e: Employee(
              id: '42',
              email: 'ada@bomach.com',
              firstName: 'Ada',
              lastName: 'Okafor',
            ),
          ),
        ),
      ),
    );

    final editLabel = find.text('Edit Profile');
    expect(
      find.ancestor(of: editLabel, matching: find.byType(ElevatedButton)),
      findsOneWidget,
    );
    expect(
      find.ancestor(of: editLabel, matching: find.byType(OutlinedButton)),
      findsNothing,
    );
  });
}
