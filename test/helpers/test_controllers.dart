import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:bomach_os/pages/hr/controller/associate_controller.dart';
import 'package:bomach_os/pages/hr/controller/employees_controller.dart';
import 'package:bomach_os/src/model/employees_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

/// Global messenger key handed to MaterialApp in tests so [AppToast]
/// snackbars are assertable.
final GlobalKey<ScaffoldMessengerState> testMessengerKey =
    GlobalKey<ScaffoldMessengerState>();

/// Registers a fake controller for the widget under test. GetX keys
/// instances by the STATIC generic on [Get.put], so each fake gets an
/// explicitly typed registration under its base class.
void registerTestController(Object controller) {
  if (controller is EmployeeController) {
    Get.put<EmployeeController>(controller, permanent: false);
  } else if (controller is AssociatesController) {
    Get.put<AssociatesController>(controller, permanent: false);
  } else {
    Get.put(controller as dynamic, permanent: false);
  }
}

void unregisterTestControllers() {
  Get.reset();
}

/// Fake EmployeeController overriding every network-touching method used by
/// the suspend/exit dialogs. The real class's methods are virtual; this
/// subclass records calls and returns scripted results. Signatures match the
/// Batch 7b target contract (`Future<bool>`, no BuildContext).
class FakeEmployeeController extends EmployeeController {
  bool nextResult = true;

  String? lastSuspendedUserId;
  String? lastSuspendReason;
  String? lastExitedUserId;
  String? lastExitDate;
  String? lastExitReason;

  @override
  Future<bool> suspendEmployee(
    dynamic context,
    String userId, {
    String? reason,
  }) async {
    lastSuspendedUserId = userId;
    lastSuspendReason = reason;
    // Mirror the real controller's contract: a clean message is set on
    // failure so dialogs can surface it via AppToast.
    errorMessage.value = nextResult ? '' : 'Could not suspend employee.';
    return nextResult;
  }

  @override
  Future<bool> exitEmployee(
    dynamic context,
    String userId, {
    required String exitDate,
    required String reason,
  }) async {
    lastExitedUserId = userId;
    lastExitDate = exitDate;
    lastExitReason = reason;
    errorMessage.value = nextResult ? '' : 'Could not offboard employee.';
    return nextResult;
  }
}

/// Fake AssociatesController recording the password handed to
/// createAssociate (V2: must be a generated value, never hardcoded).
class FakeAssociatesController extends AssociatesController {
  bool nextResult = true;
  Employee? createdAssociate;
  String? lastGeneratedPassword;

  @override
  Future<bool> createAssociate(String token, Employee employee,
      {String? password}) async {
    createdAssociate = employee;
    lastGeneratedPassword = password;
    return nextResult;
  }
}

