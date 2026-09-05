import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

import 'package:bomach_os/pages/auth/splash_screen.dart';

void main() {
  testWidgets('splash screen explains that the workspace is loading',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(home: SplashScreen()));

    expect(find.text('Loading your workspace...'), findsOneWidget);
  });
}
