import 'package:bomach_os/components/nav/side_menu.dart';
import 'package:bomach_os/pages/auth/controller.dart';
import 'package:bomach_os/src/constants/permissions.dart';
import 'package:bomach_os/src/services/permission_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _TestAuthController extends AuthController {
  @override
  // Skip AuthController's startup network/session check in this isolated
  // sidebar test; it deliberately tests only router-driven selection.
  // ignore: must_call_super
  void onInit() {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sidebar selection follows routes changed outside the sidebar',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    Get.reset();
    Get.put(PermissionService()
      ..testInjectPermissions({
        PermissionConstants.resDashboard: {'view'},
        PermissionConstants.resEmployees: {'view', 'view_own'},
      }));
    Get.put<AuthController>(_TestAuthController());

    final router = GoRouter(
      initialLocation: '/dashboard',
      routes: [
        ShellRoute(
          builder: (context, state, child) => Scaffold(
            body: Row(
              children: [
                SizedBox(
                  width: 300,
                  child: SideMenu(
                    router: GoRouter.of(context),
                    preferences: preferences,
                  ),
                ),
                Expanded(child: child),
              ],
            ),
          ),
          routes: [
            GoRoute(
              path: '/dashboard',
              builder: (context, state) => Center(
                child: ElevatedButton(
                  onPressed: () => context.go('/dashboard/my-profile'),
                  child: const Text('Open profile without sidebar'),
                ),
              ),
            ),
            GoRoute(
              path: '/dashboard/my-profile',
              builder: (context, state) =>
                  const Center(child: Text('Profile page')),
            ),
          ],
        ),
      ],
    );
    addTearDown(router.dispose);
    addTearDown(Get.reset);

    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();

    expect(_isSidebarRowSelected(tester, 'Overview'), isTrue);
    expect(_isSidebarRowSelected(tester, 'Profile'), isFalse);

    await tester.tap(find.text('Open profile without sidebar'));
    await tester.pumpAndSettle();

    expect(find.text('Profile page'), findsOneWidget);
    expect(_isSidebarRowSelected(tester, 'Profile'), isTrue);
    expect(_isSidebarRowSelected(tester, 'Overview'), isFalse);
  });
}

bool _isSidebarRowSelected(WidgetTester tester, String label) {
  final text = tester.widget<Text>(find.text(label));
  return text.style?.fontWeight == FontWeight.w600;
}
