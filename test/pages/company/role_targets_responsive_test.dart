import 'package:bomach_os/pages/company/controllers/targets_controller.dart';
import 'package:bomach_os/pages/company/widget/role_detail_tabs/targets_tab.dart';
import 'package:bomach_os/src/model/role_target_template_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

void main() {
  tearDown(Get.reset);

  testWidgets('role target cards and editor fit common widths', (tester) async {
    const viewports = [
      Size(320, 740),
      Size(390, 844),
      Size(768, 1024),
      Size(1440, 900),
    ];

    for (final viewport in viewports) {
      Get.reset();
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = viewport;
      final controller = TargetsController()..scopedRoleId = 7;
      controller.targets.assignAll([
        RoleTargetTemplate(
          id: 2,
          roleId: 7,
          title:
              'Complete customer onboarding and quality review documentation',
          description:
              'Review each active customer record and keep supporting documentation current.',
          targetValue: 9000,
          unit: 'approved customer records per review period',
          period: 'semi_annual',
          sequence: 1,
        ),
      ]);
      Get.put(controller, tag: 'role_detail_7');

      await tester.pumpWidget(
        const GetMaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(child: TargetsTab(roleId: 7)),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Shared role targets'), findsOneWidget);
      expect(tester.takeException(), isNull,
          reason: 'Role target tab should fit at $viewport');

      await tester.ensureVisible(find.text('Add target'));
      await tester.tap(find.text('Add target').first);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull,
          reason: 'Role target editor should fit at $viewport');
      await tester.tap(find.text('Cancel'));
      await tester.pumpAndSettle();
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pumpAndSettle();
    }

    tester.view.resetPhysicalSize();
    tester.view.resetDevicePixelRatio();
  });
}
