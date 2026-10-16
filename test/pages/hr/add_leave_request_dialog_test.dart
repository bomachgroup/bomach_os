import 'package:bomach_os/pages/hr/controller/leave_request_controller.dart';
import 'package:bomach_os/pages/hr/widget/add_leave_request_dialog.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.reset();
    Get.put(PermissionService()
      ..testInjectPermissions(const {
        'leave_requests': {'create'},
      }));
  });

  tearDown(() => Get.reset());

  testWidgets('request kind controls expose only the relevant fields',
      (tester) async {
    final controller = Get.put(LeaveRequestController());
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(body: AddLeaveRequestDialog()),
    ));
    await tester.pumpAndSettle();

    expect(find.text('Leave type'), findsOneWidget);
    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('End date'), findsOneWidget);

    controller.updateCreateRequestKind('absence');
    await tester.pumpAndSettle();
    expect(find.text('Leave type'), findsNothing);
    expect(find.text('Start date'), findsOneWidget);
    expect(find.text('End date'), findsOneWidget);

    controller.updateCreateRequestKind('running_late');
    await tester.pumpAndSettle();
    expect(find.text('Start date'), findsNothing);
    expect(find.text('End date'), findsNothing);
    expect(find.textContaining('recorded for today'), findsOneWidget);
  });
}
