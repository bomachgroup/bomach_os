import 'package:bomach_os/pages/hr/controller/my_leaves_controller.dart';
import 'package:bomach_os/pages/hr/models/leave_request_model.dart';
import 'package:bomach_os/src/services/hr/leave_request_services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

class _RecordingLeaveRequestService extends LeaveRequestService {
  String? employeeId;
  int? requestId;
  String? requestKind;
  String? status;
  String? search;
  int? offset;
  String? statsEmployeeId;
  var listCalls = 0;

  @override
  Future<({List<LeaveRequest> items, int count})> getLeaveRequests(
    String token, {
    String? search,
    String? employeeId,
    int? requestId,
    String? requestKind,
    String? leaveType,
    String? status,
    String? startDateFrom,
    String? startDateTo,
    int limit = 100,
    int offset = 0,
  }) async {
    listCalls++;
    this.employeeId = employeeId;
    this.requestId = requestId;
    this.requestKind = requestKind;
    this.status = status;
    this.search = search;
    this.offset = offset;
    return (items: <LeaveRequest>[], count: 0);
  }

  @override
  Future<dynamic> getEmployeeLeaveStats(String token, String employeeId) async {
    statsEmployeeId = employeeId;
    return {'pending': 0};
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    Get.testMode = true;
    Get.reset();
  });

  tearDown(() => Get.reset());

  testWidgets('My Requests uses Employee ID for list and statistics',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({
      'access_token': 'test-token',
      'employee_record_id': '3',
      'user_id': '7',
    });
    final service = _RecordingLeaveRequestService();
    final controller = MyLeavesController(
      service: service,
    );
    addTearDown(controller.onClose);
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => const Scaffold(key: Key('host'))),
    ));

    controller
      ..currentPage.value = 4
      ..selectedRequestKind.value = 'running_late'
      ..selectedStatusFilter.value = 'Rejected'
      ..searchController.text = 'unrelated search';

    await controller.fetchMyLeaves(
      tester.element(find.byKey(const Key('host'))),
      requestId: 42,
    );

    expect(service.employeeId, '3');
    expect(service.requestId, 42);
    expect(service.requestKind, isNull);
    expect(service.status, isNull);
    expect(service.search, isNull);
    expect(service.offset, 0);
    expect(service.statsEmployeeId, '3');
    expect(controller.hasError.value, isFalse);
  });

  testWidgets('missing Employee ID never falls back to auth user ID',
      (tester) async {
    FlutterSecureStorage.setMockInitialValues({
      'access_token': 'test-token',
      'user_id': '7',
    });
    final service = _RecordingLeaveRequestService();
    final controller = MyLeavesController(
      service: service,
    );
    addTearDown(controller.onClose);
    await tester.pumpWidget(MaterialApp(
      home: Builder(builder: (context) => const Scaffold(key: Key('host'))),
    ));

    await controller.fetchMyLeaves(
      tester.element(find.byKey(const Key('host'))),
    );

    expect(service.listCalls, 0);
    expect(controller.hasError.value, isTrue);
    expect(controller.errorMessage.value, contains('employee profile'));
  });
}
