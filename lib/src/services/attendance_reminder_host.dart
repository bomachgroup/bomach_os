import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:get/get.dart';

import '../../pages/auth/controller.dart';
import '../../src/model/user_model.dart';
import 'attendance_reminder_coordinator.dart';

/// Keeps an existing reminder opt-in running across the signed-in app shell
/// and pauses it whenever the application is backgrounded.
class AttendanceReminderHost extends StatefulWidget {
  const AttendanceReminderHost({
    required this.child,
    super.key,
  });

  final Widget child;

  @override
  State<AttendanceReminderHost> createState() => _AttendanceReminderHostState();
}

class _AttendanceReminderHostState extends State<AttendanceReminderHost>
    with WidgetsBindingObserver {
  late final AuthController? _auth =
      Get.isRegistered<AuthController>() ? Get.find<AuthController>() : null;
  late final AttendanceReminderCoordinator? _coordinator =
      Get.isRegistered<AttendanceReminderCoordinator>()
          ? Get.find<AttendanceReminderCoordinator>()
          : null;
  Worker? _userWorker;
  int? _activeUserId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final auth = _auth;
    if (auth == null || _coordinator == null) return;
    _userWorker = ever<User?>(auth.currentUser, _onUserChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _onUserChanged(auth.currentUser.value);
    });
  }

  void _onUserChanged(User? user) {
    final userId = user?.userId;
    final coordinator = _coordinator;
    if (coordinator == null) return;
    if (userId == null || userId <= 0) {
      _activeUserId = null;
      unawaited(coordinator.stop());
      return;
    }
    if (_activeUserId == userId) return;
    _activeUserId = userId;
    unawaited(coordinator.resumeForUser(userId));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      final auth = _auth;
      final coordinator = _coordinator;
      final userId = auth?.currentUser.value?.userId;
      if (userId != null && userId > 0) {
        _activeUserId = userId;
        unawaited(coordinator?.resumeForUser(userId));
      }
    } else if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.detached) {
      unawaited(_coordinator?.pause());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _userWorker?.dispose();
    unawaited(_coordinator?.stop());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
