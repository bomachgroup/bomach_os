import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:bomach_os/pages/marketing/marketing.dart';
import 'package:bomach_os/pages/marketing/widget/marketing_webview.dart';

void main() {
  testWidgets(
    'root Marketing page renders the embedded dashboard without duplicate navigation',
    (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: MarketingPage(),
        ),
      );
      await tester.pump();

      expect(MarketingPage.rootRoute, '/dashboard');
      expect(find.byType(MarketingWebView), findsOneWidget);
      expect(find.text('Marketing OS'), findsNothing);
      expect(find.text('Revenue Execution'), findsNothing);
    },
  );
}
