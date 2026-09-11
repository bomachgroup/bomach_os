import 'package:bomach_os/components/button/my_elevated_button.dart';
import 'package:bomach_os/pages/company/controllers/workspace_approvals_controller.dart';
import 'package:bomach_os/pages/company/workspace_approvals.dart';
import 'package:bomach_os/pages/hr/models/workspace_model.dart';
import 'package:bomach_os/src/constants/colors.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _FakeWorkspaceApprovalsController
    extends WorkspaceApprovalsController {
  @override
  Future<void> fetch() async {}
}

void main() {
  late _FakeWorkspaceApprovalsController controller;
  late PermissionService permissionService;

  setUp(() {
    Get.reset();

    controller = _FakeWorkspaceApprovalsController();
    controller.submissions.assign(WorkspaceConfig(
      id: 7,
      workspaceName: 'Head Office',
      latitude: 6.5244,
      longitude: 3.3792,
      status: WorkspaceStatus.pending,
      employeeName: 'Somtochukwu Ukaegbe',
    ));
    Get.put<WorkspaceApprovalsController>(controller);

    permissionService = Get.put(PermissionService());
  });

  tearDown(Get.reset);

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: ThemeData(splashFactory: NoSplash.splashFactory),
        home: const Material(child: WorkspaceApprovalsPage()),
      ),
    );
    await tester.pump();
  }

  Finder approveButton() {
    return find.byWidgetPredicate(
      (widget) => widget is MyElevatedButton && widget.child == 'Approve',
    );
  }

  testWidgets(
      'shows the Approve workspace button when the user can approve work locations',
      (tester) async {
    permissionService.testInjectPermissions({
      'work_locations': {'list'},
      'work_location_approvals': {'approve'},
    });

    await pumpPage(tester);

    expect(approveButton(), findsOneWidget);
    expect(
      (approveButton().evaluate().single.widget as MyElevatedButton).bgColor,
      AppColors.primary,
    );
  });

  testWidgets(
      'hides the Approve workspace button when the user cannot approve work locations',
      (tester) async {
    permissionService.testInjectPermissions({
      'work_locations': {'list'},
    });

    await pumpPage(tester);

    expect(approveButton(), findsNothing);
  });

  testWidgets('uses the primary color for the approval confirmation action',
      (tester) async {
    permissionService.testInjectPermissions({
      'work_locations': {'list'},
      'work_location_approvals': {'approve'},
    });

    await pumpPage(tester);
    await tester.ensureVisible(approveButton());
    await tester.tap(approveButton());
    await tester.pumpAndSettle();

    final approveActions = approveButton().evaluate().toList();
    expect(approveActions, hasLength(2));
    expect(
      (approveActions.last.widget as MyElevatedButton).bgColor,
      AppColors.primary,
    );
  });
}
