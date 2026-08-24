import 'package:bomach_os/components/feedback/app_toast.dart';
import 'package:flutter/material.dart';

/// Global ScaffoldMessenger key so tests can assert on snackbars emitted by
/// [AppToast] from anywhere in the tree (mirrors how the real app hosts a
/// scaffoldMessengerKey on MaterialApp).
final GlobalKey<ScaffoldMessengerState> testMessengerKey =
    GlobalKey<ScaffoldMessengerState>();
