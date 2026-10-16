import 'package:bomach_os/pages/hr/controller/leave_request_controller.dart';
import 'package:bomach_os/pages/hr/models/leave_request_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('leave create payload includes leave type and date range', () {
    final payload = LeaveRequest(
      id: null,
      employeeId: '',
      requestKind: 'leave',
      leaveType: 'annual_leave',
      startDate: DateTime(2026, 11, 2),
      endDate: DateTime(2026, 11, 4),
      reason: 'Annual time off',
    ).toCreateJson();

    expect(payload['request_kind'], 'leave');
    expect(payload['leave_type'], 'annual_leave');
    expect(payload['start_date'], '2026-11-02');
    expect(payload['end_date'], '2026-11-04');
  });

  test('absence create payload includes dates and omits leave type', () {
    final payload = LeaveRequest(
      id: null,
      employeeId: '',
      requestKind: 'absence',
      leaveType: '',
      startDate: DateTime(2026, 11, 2),
      endDate: DateTime(2026, 11, 2),
      reason: 'Unexpected illness',
    ).toCreateJson();

    expect(payload['request_kind'], 'absence');
    expect(payload.containsKey('leave_type'), isFalse);
    expect(payload['start_date'], '2026-11-02');
    expect(payload['end_date'], '2026-11-02');
  });

  test('running-late payload leaves date and type assignment to backend', () {
    final payload = LeaveRequest(
      id: null,
      employeeId: '',
      requestKind: 'running_late',
      leaveType: '',
      reason: 'Delayed by traffic',
    ).toCreateJson();

    expect(payload['request_kind'], 'running_late');
    expect(payload.containsKey('leave_type'), isFalse);
    expect(payload.containsKey('start_date'), isFalse);
    expect(payload.containsKey('end_date'), isFalse);
  });

  test('editing does not send a change to immutable request kind', () {
    final payload = LeaveRequest(
      id: 5,
      employeeId: '3',
      requestKind: 'leave',
      leaveType: 'annual_leave',
      startDate: DateTime(2026, 11, 2),
      endDate: DateTime(2026, 11, 3),
      reason: 'Annual leave',
    ).toUpdateJson();

    expect(payload.containsKey('request_kind'), isFalse);
  });

  test('switching to running late clears user-entered dates and type', () {
    final controller = LeaveRequestController()
      ..selectedLeaveType.value = 'annual_leave'
      ..selectedStartDate = DateTime(2026, 11, 2)
      ..selectedEndDate = DateTime(2026, 11, 3)
      ..startDateController.text = '02 Nov 2026'
      ..endDateController.text = '03 Nov 2026';
    addTearDown(controller.onClose);

    controller.updateCreateRequestKind('running_late');

    expect(controller.selectedCreateRequestKind.value, 'running_late');
    expect(controller.selectedLeaveType.value, isEmpty);
    expect(controller.selectedStartDate, isNull);
    expect(controller.selectedEndDate, isNull);
    expect(controller.startDateController.text, isEmpty);
    expect(controller.endDateController.text, isEmpty);
  });
}
