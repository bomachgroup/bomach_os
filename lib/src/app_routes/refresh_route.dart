import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    log("DEBUG ROUTER: GoRouterRefreshStream created");
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen(
          (dynamic _) {
            log("DEBUG ROUTER: GoRouterRefreshStream received stream event! Notifying listeners...");
            notifyListeners();
          },
        );
  }

  late final StreamSubscription<dynamic> _subscription;

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}
