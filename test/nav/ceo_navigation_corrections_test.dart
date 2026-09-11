import 'package:bomach_os/src/app_routes/app_route_constants.dart';
import 'package:bomach_os/src/app_routes/menu_structure.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

void main() {
  test('navigation uses Marketing & Sales and the retained client relationship entry', () {
    final allMenus = sidebarStructure.expand((section) => section.items);
    final marketing = allMenus.firstWhere((item) => item.id == MainMenuItem.marketingCrm);
    final crm = allMenus.firstWhere((item) => item.id == MainMenuItem.crm);

    expect(marketing.label, 'Marketing & Sales');
    expect(crm.children.map((item) => item.id), [SubMenuItem.crmClients]);
    expect(crm.children.single.label, 'Client Relationship Management');
    expect(marketing.children.map((item) => item.route), isNot(contains(RouteConstants.crmLeads)));
    expect(marketing.children.map((item) => item.route), isNot(contains(RouteConstants.crmInteractions)));
    expect(marketing.children.map((item) => item.route), isNot(contains(RouteConstants.crmAnalytics)));
  });

  test('Client Portal is not present in any sidebar section', () {
    final allMenus = sidebarStructure.expand((section) => section.items);
    expect(allMenus.map((item) => item.id), isNot(contains(MainMenuItem.clientPortal)));
    expect(
      allMenus.expand((item) => item.children).map((item) => item.route),
      everyElement(isNot(anyOf(
        equals(RouteConstants.clientAccess),
        equals(RouteConstants.documentSharing),
        equals(RouteConstants.communications),
        equals(RouteConstants.portalAnalytics),
      ))),
    );
  });

  test('retained clients page is labelled Client Relationship Management', () {
    final source = File('lib/pages/crm/clients.dart').readAsStringSync();
    expect(source, contains("title: 'Client Relationship Management'"));
    expect(source, contains("const Text('Client Relationship Management'"));
  });

  test('retired portal and CRM URLs redirect to the retained client page', () {
    final source = File('lib/src/app_routes/app_router.dart').readAsStringSync();
    expect(source, contains('retiredRoutes'));
    expect(source, contains('RouteConstants.crmClients'));
    expect(source, contains('RouteConstants.clientAccess'));
  });
}
